//
//  OCATransformer+Base.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Base.h"
#import "OCAObject.h"
#import <objc/runtime.h>





@interface OCATransformer ()


@property (atomic, readonly, copy) OCATransformerBlock transformationBlock;
@property (atomic, readonly, copy) OCATransformerBlock reverseTransformationBlock;

@property (nonatomic, readwrite, copy) NSString *description;
@property (nonatomic, readwrite, copy) NSString *reverseDescription;


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


- (id)transformedValue:(NSObject *)value {
    return [self transformValue:value ofClass:[self.class valueClass] usingBlock:self.transformationBlock toClass:[self.class transformedValueClass]];
}


- (id)reverseTransformedValue:(NSObject *)value {
    if ([self.class allowsReverseTransformation]) {
        return [self transformValue:value ofClass:[self.class transformedValueClass] usingBlock:self.reverseTransformationBlock toClass:[self.class valueClass]];
    }
    else {
        return nil;
    }
}


- (id)transformValue:(NSObject *)value ofClass:(Class)inClass usingBlock:(OCATransformerBlock)block toClass:(Class)outClass {
    BOOL inputValid = [OCAObject validateObject:&value ofClass:inClass];
    if ( ! inputValid) return nil;
    
    id transformedValue = (block? block(value) : nil);
    
    BOOL outputValid = [OCAObject validateObject:&transformedValue ofClass:outClass];
    if ( ! outputValid) return nil;
    
    return transformedValue;
}





#pragma mark Description


- (instancetype)describe:(NSString *)description {
    return [self describe:description reverse:description];
}


- (instancetype)describe:(NSString *)description reverse:(NSString *)reverseDescription {
#if DEBUG
    if (description.length) self.description = description;
    
    if ( ! self.reverseTransformationBlock) {
        self.reverseDescription = @"<undefined>";
    }
    else if (reverseDescription.length) {
        self.reverseDescription = reverseDescription;
    }
#endif
    return self;
}


@synthesize description = _description;
- (NSString *)description {
    return self->_description ?: @"";
}


- (NSString *)reverseDescription {
    return self->_reverseDescription ?: @"";
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
    // This is much faster than +stringWithFormat: and since this piece of code is called a pretty often, it makes difference.
    char genericClassName[128];
    snprintf(genericClassName, 128, "OCA%sTo%s%sTransformer",
             (inputClass? class_getName(inputClass) : "Anything"),
             (outputClass? class_getName(outputClass) : "Anything"),
             (isReversible? "Reversible" : ""));
    
    Class genericClass = [OCATransformer subclassWithName:@(genericClassName)
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
        
#if DEBUG
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
#endif
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


+ (OCATransformer *)there:(NSValueTransformer *)forward back:(NSValueTransformer *)backward {
    Class inputClass = [OCAObject valueClassForClasses:@[ [forward.class valueClass] ?: [NSNull null],
                                                          [backward.class transformedValueClass] ?: [NSNull null] ]];
    Class outputClass = [OCAObject valueClassForClasses:@[ [forward.class transformedValueClass] ?: [NSNull null],
                                                           [backward.class valueClass] ?: [NSNull null] ]];
    Class genericClass = [OCATransformer subclassForInputClass:inputClass outputClass:outputClass reversible:YES];
    return [[[genericClass alloc] initWithBlock:^id(id input) {
        return [forward transformedValue:input];
    } reverseBlock:^id(id input) {
        return [backward transformedValue:input];
    }]
            describe:forward.description
            reverse:backward.description];
}





@end










OCATransformerBlock const OCATransformationDiscard = ^id(id x) {
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









@implementation NSObject (NSValueTransformer)

- (id)transform:(NSValueTransformer *)transformer {
    return [transformer transformedValue:self];
}

@end




