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


@end



// These functions were once class methods, but they were mistakenly modifying different subclasses, because of the receiver was not yet registered with the runtime.
void OCATransformerSubclassSetValueClass(Class subclass, Class valueClass);
void OCATransformerSubclassSetTransformedValueClass(Class subclass, Class transformedValueClass);
void OCATransformerSubclassSetAllowsReverseTransformation(Class subclass, BOOL allowsReverseTransformation);
void OCATransformerSubclassOverrideMethod(Class, SEL, IMP);










@implementation OCATransformer





#pragma mark Default Values


+ (Class)valueClass {
    return nil;
}


+ (Class)transformedValueClass {
    return nil;
}


+ (BOOL)allowsReverseTransformation {
    return NO;
}


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





#pragma mark Deriving Transformers


- (OCATransformer *)reversed {
    if ( ! [self.class allowsReverseTransformation]) return self;
    
    return [OCATransformer fromClass:[self.class transformedValueClass]
                             toClass:[self.class valueClass]
                      transformation:self.reverseTransformationBlock
               reverseTransformation:self.transformationBlock];
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
                                                OCATransformerSubclassSetValueClass(subclass, inputClass);
                                                OCATransformerSubclassSetTransformedValueClass(subclass, outputClass);
                                                OCATransformerSubclassSetAllowsReverseTransformation(subclass, isReversible);
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










void OCATransformerSubclassSetValueClass(Class subclass, Class valueClass) {
    Class (^implementationBlock)(id) = ^Class(id self){
        return valueClass;
    };
    OCATransformerSubclassOverrideMethod(subclass, @selector(valueClass), imp_implementationWithBlock(implementationBlock));
}


void OCATransformerSubclassSetTransformedValueClass(Class subclass, Class transformedValueClass) {
    Class (^implementationBlock)(id) = ^Class(id self){
        return transformedValueClass;
    };
    OCATransformerSubclassOverrideMethod(subclass, @selector(transformedValueClass), imp_implementationWithBlock(implementationBlock));
}


void OCATransformerSubclassSetAllowsReverseTransformation(Class subclass, BOOL allowsReverseTransformation) {
    BOOL (^implementationBlock)(id) = ^BOOL(id self){
        return allowsReverseTransformation;
    };
    OCATransformerSubclassOverrideMethod(subclass, @selector(allowsReverseTransformation), imp_implementationWithBlock(implementationBlock));
}


void OCATransformerSubclassOverrideMethod(Class class, SEL selector, IMP implementation) {
    Method superMethod = class_getClassMethod(class, selector);
    Class metaClass = (class_isMetaClass(class)? class : object_getClass(class));
    class_addMethod(metaClass, selector, implementation, method_getTypeEncoding(superMethod));
}




