//
//  OCATransformer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer.h"
#import "OCAObject.h"
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
    
    id transformedValue = (validInput && self->_transformationBlock
                           ? self->_transformationBlock(value)
                           : [super transformedValue:value]);
    
    BOOL validOutput = OCAValidateClass(transformedValue, [self.class transformedValueClass]);
    if ( ! validOutput) return nil;
    
    return transformedValue;
}


- (id)reverseTransformedValue:(id)value {
    if (self->_reverseTransformationBlock) {
        BOOL validInput = OCAValidateClass(value, [self.class transformedValueClass]);
        if ( ! validInput) return nil;
        
        id transformedValue = self->_reverseTransformationBlock(value);
        
        BOOL validOutput = OCAValidateClass(transformedValue, [self.class valueClass]);
        if ( ! validOutput) return nil;
        
        return transformedValue;
    }
    else {
        return [self transformedValue:value];
    }
}





#pragma mark Description


- (instancetype)describe:(NSString *)description {
    self.description = description;
    self.reverseDescription = description;
    return self;
}


- (instancetype)describe:(NSString *)description reverse:(NSString *)reverseDescription {
    self.description = description;
    self.reverseDescription = reverseDescription;
    return self;
}


- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ %p; %@>", self.class, self, self.description];
}





#pragma mark Deriving Transformers


- (OCATransformer *)reversed {
    if ( ! [self.class allowsReverseTransformation]) return self;
    
    return [[OCATransformer fromClass:[self.class transformedValueClass]
                             toClass:[self.class valueClass]
                      transformation:self.reverseTransformationBlock
               reverseTransformation:self.transformationBlock]
            describe:self.reverseDescription
            reverse:self.description];
}





#pragma mark Customizing Using Blocks


+ (Class)subclassForInputClass:(Class)inputClass outputClass:(Class)outputClass reversible:(BOOL)isReversible name:(NSString *)subclassName {
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
    if (subclassName) {
        return [genericClass subclassWithName:subclassName customization:nil];
    }
    else {
        return genericClass;
    }
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


- (OCATransformer *)initWithBlock:(OCATransformerBlock)transformationBlock reverseBlock:(OCATransformerBlock)reverseTransformationBlock {
    self = [super init];
    if (self) {
        self->_transformationBlock = transformationBlock;
        self->_reverseTransformationBlock = reverseTransformationBlock;
    }
    return self;
}


+ (OCATransformer *)fromClass:(Class)inputClass toClass:(Class)outputClass transformation:(OCATransformerBlock)transformationBlock {
    Class genericClass = [OCATransformer subclassForInputClass:inputClass outputClass:outputClass reversible:NO name:nil];
    return [[genericClass alloc] initWithBlock:transformationBlock reverseBlock:nil];
}


+ (OCATransformer *)fromClass:(Class)inputClass toClass:(Class)outputClass transformation:(OCATransformerBlock)transformationBlock reverseTransformation:(OCATransformerBlock)reverseTransformationBlock {
    Class genericClass = [OCATransformer subclassForInputClass:inputClass outputClass:outputClass reversible:YES name:nil];
    return [[genericClass alloc] initWithBlock:transformationBlock reverseBlock:reverseTransformationBlock];
}





@end










@implementation NSValueTransformer (valueClass)


+ (Class)valueClass {
    return nil;
}


@end




