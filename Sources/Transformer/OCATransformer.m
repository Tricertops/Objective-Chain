//
//  OCATransformer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer.h"
#import <objc/runtime.h>





@interface OCATransformer ()


@property (OCA_atomic, readonly, copy) OCATransformerBlock transformationBlock;
@property (OCA_atomic, readonly, copy) OCATransformerBlock reverseTransformationBlock;

@property (OCA_atomic, readwrite, copy) NSString *description;
@property (OCA_atomic, readwrite, copy) NSString *reverseDescription;


@end










@implementation OCATransformer





#pragma mark Class Info


+ (Class)valueClass {
    return nil;
}


+ (Class)transformedValueClass {
    return nil;
}


+ (BOOL)allowsReverseTransformation {
    return NO;
}




#pragma mark Transformation


- (id)transformedValue:(id)value {
    BOOL validInput = OCAValidateClass(value, [self.class valueClass]);
    if ( ! validInput) return nil;
    
    id transformedValue = (self->_transformationBlock
                           ? self->_transformationBlock(value)
                           : nil);
    
    BOOL validOutput = OCAValidateClass(transformedValue, [self.class transformedValueClass]);
    if ( ! validOutput) return nil;
    
    return transformedValue;
}


- (id)reverseTransformedValue:(id)value {
    if ([self.class allowsReverseTransformation]) {
        BOOL validInput = OCAValidateClass(value, [self.class transformedValueClass]);
        if ( ! validInput) return nil;
        
        id transformedValue = (self->_reverseTransformationBlock
                               ? self->_reverseTransformationBlock(value)
                               : nil);
        
        BOOL validOutput = OCAValidateClass(transformedValue, [self.class valueClass]);
        if ( ! validOutput) return nil;
        
        return transformedValue;
    }
    else {
        return nil;
    }
}





#pragma mark Description


- (instancetype)describe:(NSString *)description {
    return [self describe:description reverse:description];
}


- (instancetype)describe:(NSString *)description reverse:(NSString *)reverseDescription {
    if (description.length) self.description = description;
    
    if ( ! self.reverseTransformationBlock) {
        self.reverseDescription = @"<undefined>";
    }
    else if (reverseDescription.length) {
        self.reverseDescription = reverseDescription;
    }
    return self;
}


- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ %p; %@>", self.class, self, self.description];
}





#pragma mark Deriving Transformers


- (OCATransformer *)reversed {
    // My reverse is fully reversible only, if I am. Got it?
    BOOL isReverseReversible = (self.transformationBlock != nil);
    
    Class class = [OCATransformer subclassForInputClass:[self.class transformedValueClass]
                                            outputClass:[self.class valueClass]
                                             reversible:isReverseReversible];
    
    OCATransformer *reverse = [[class alloc] initWithBlock:self.reverseTransformationBlock
                                              reverseBlock:self.transformationBlock];
    return [reverse describe:self.reverseDescription reverse:self.description];
}


- (OCATransformer *)specializeFromClass:(Class)inputClass toClass:(Class)outputClass {
    Class existingInputClass = [self.class valueClass];
    Class existingOutputClass = [self.class transformedValueClass];
    OCAAssert(existingInputClass == nil || [inputClass isSubclassOfClass:existingInputClass], @"Must provide a subclass.") return self;
    OCAAssert(existingOutputClass == nil || [outputClass isSubclassOfClass:existingOutputClass], @"Must provide a subclass.") return self;
    
    Class class = [OCATransformer subclassForInputClass:inputClass
                                            outputClass:outputClass
                                             reversible:[self.class allowsReverseTransformation]];
    
    OCATransformer *reverse = [[class alloc] initWithBlock:self.transformationBlock
                                              reverseBlock:self.reverseTransformationBlock];
    return [reverse describe:self.description reverse:self.reverseDescription];
}





#pragma mark Customizing Using Blocks


+ (Class)subclassForInputClass:(Class)inputClass outputClass:(Class)outputClass reversible:(BOOL)isReversible {
    // OCAAnythingToAnythingReversibleTransformer
    NSString *genericClassName = [NSString stringWithFormat:@"OCA%@To%@%@Transformer",
                                  inputClass ?: @"Anything",
                                  outputClass ?: @"Anything",
                                  (isReversible? @"Reversible" : @"")];
    
    Class genericClass = [OCATransformer subclassWithName:genericClassName
                                            customization:^(Class subclass) {
                                                [subclass setValueClass:inputClass];
                                                [subclass setTransformedValueClass:outputClass];
                                                [subclass setAllowsReverseTransformation:isReversible];
                                            }];
    return genericClass;
}


+ (Class)subclassWithName:(NSString *)name customization:(void(^)(Class subclass))block {
    if ( ! name.length) return nil;
    
    Class subclass = NSClassFromString(name);
    if ( ! subclass) {
        subclass = objc_allocateClassPair(self, name.UTF8String, 0);
        if (block) block(subclass);
        objc_registerClassPair(subclass);
    }
    else {
        OCAAssert([subclass isSubclassOfClass:self], @"Found existing class %@, but it's not subclassed from %@!", subclass, self) return nil;
    }
    return subclass;
}


+ (void)overrideSelector:(SEL)selector withImplementation:(IMP)implementation {
    Method superMethod = class_getClassMethod(self, selector);
    Class metaClass = (class_isMetaClass(self)? self : object_getClass(self));
    class_addMethod(metaClass, selector, implementation, method_getTypeEncoding(superMethod));
}


+ (void)setValueClass:(Class)valueClass {
    Class (^implementationBlock)(id) = ^Class(id self){
        return valueClass;
    };
    [self overrideSelector:@selector(valueClass) withImplementation:imp_implementationWithBlock(implementationBlock)];
}


+ (void)setTransformedValueClass:(Class)transformedValueClass {
    Class (^implementationBlock)(id) = ^Class(id self){
        return transformedValueClass;
    };
    [self overrideSelector:@selector(transformedValueClass) withImplementation:imp_implementationWithBlock(implementationBlock)];
}


+ (void)setAllowsReverseTransformation:(BOOL)allowsReverseTransformation {
    BOOL (^implementationBlock)(id) = ^BOOL(id self){
        return allowsReverseTransformation;
    };
    [self overrideSelector:@selector(allowsReverseTransformation) withImplementation:imp_implementationWithBlock(implementationBlock)];
}


- (OCATransformer *)init {
    return [self initWithBlock:nil reverseBlock:nil];
}


- (OCATransformer *)initWithBlock:(OCATransformerBlock)transformationBlock reverseBlock:(OCATransformerBlock)reverseTransformationBlock {
    self = [super init];
    if (self) {
        self->_transformationBlock = transformationBlock;
        self->_reverseTransformationBlock = reverseTransformationBlock;
        
        NSString *inputClassName = NSStringFromClass([self.class valueClass]) ?: @"anything";
        NSString *outputClassName = NSStringFromClass([self.class transformedValueClass]) ?: @"anything";
        BOOL preservesClass = [inputClassName isEqualToString:outputClassName];
        if (preservesClass) {
            NSString *description = [NSString stringWithFormat:@"transform %@", outputClassName];
            [self describe:description reverse:description];
        }
        else {
            [self describe:[NSString stringWithFormat:@"convert %@ to %@", inputClassName, outputClassName]
                   reverse:[NSString stringWithFormat:@"convert %@ to %@", outputClassName, inputClassName]];
        }
        
    }
    return self;
}


+ (OCATransformer *)fromClass:(Class)inputClass toClass:(Class)outputClass symetric:(OCATransformerBlock)transform {
    Class genericClass = [OCATransformer subclassForInputClass:inputClass outputClass:outputClass reversible:YES];
    return [[genericClass alloc] initWithBlock:transform reverseBlock:transform];
}


+ (OCATransformer *)fromClass:(Class)inputClass toClass:(Class)outputClass asymetric:(OCATransformerBlock)transform {
    Class genericClass = [OCATransformer subclassForInputClass:inputClass outputClass:outputClass reversible:NO];
    return [[genericClass alloc] initWithBlock:transform reverseBlock:nil];
}


+ (OCATransformer *)fromClass:(Class)inputClass toClass:(Class)outputClass transform:(OCATransformerBlock)transform reverse:(OCATransformerBlock)reverse {
    Class genericClass = [OCATransformer subclassForInputClass:inputClass outputClass:outputClass reversible:YES];
    return [[genericClass alloc] initWithBlock:transform reverseBlock:reverse];
}


+ (Class)valueClassForClasses:(NSArray *)classes {
    NSMutableArray *concreteClasses = [[NSMutableArray alloc] init];
    for (Class class in classes) {
        if (class != NSNull.null && class != [NSObject class]) {
            [concreteClasses addObject:class];
        }
    }
    
    Class finalClass = concreteClasses.firstObject;
    while (finalClass) {
        BOOL isCommonToAll = YES;
        for (Class class in concreteClasses) {
            BOOL isSuperclass = [class isSubclassOfClass:finalClass];
            isCommonToAll &= isSuperclass;
            if ( ! isCommonToAll) break;
        }
        if (isCommonToAll) break;
        finalClass = finalClass.superclass;
    }
    return finalClass;
}





@end





OCATransformerBlock const OCATransformationNil = ^id(id x) {
    return nil;
};


OCATransformerBlock const OCATransformationPass = ^id(id x) {
    return x;
};










@implementation NSValueTransformer (OCATransformerCompatibility)


+ (Class)valueClass {
    return nil;
}


- (NSValueTransformer *)reversed {
    return [[OCATransformer fromClass:[self.class transformedValueClass] toClass:[self.class valueClass] transform:^id(id input) {
        return [self reverseTransformedValue:input];
    } reverse:^id(id input) {
        return [self transformedValue:input];
    }]
            describe:[NSString stringWithFormat:@"reverse of %@", self]
            reverse:self.description];
}


@end




