//
//  OCATransformer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//
//

#import "OCATransformer.h"
#import "OCAObject.h"
#import <objc/runtime.h>





@interface OCATransformer ()


@property (OCA_atomic, readonly, copy) OCATransformerBlock transformationBlock;
@property (OCA_atomic, readonly, copy) OCATransformerBlock reverseTransformationBlock;


@end










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
    if (self->_transformationBlock) return self->_transformationBlock(value);
    else return [super transformedValue:value];
}


- (id)reverseTransformedValue:(id)value {
    if (self->_reverseTransformationBlock) return self->_reverseTransformationBlock(value);
    else return [super reverseTransformedValue:value];
}





#pragma mark Customizing Using Blocks


+ (Class)transformerClassFromClass:(Class)inputClass toClass:(Class)outputClass isReverse:(BOOL)isReverse {
    NSString *transformerClassName = [NSString stringWithFormat:@"OCA%@To%@%@Transformer", inputClass ?: @"Any", outputClass ?: @"Any", (isReverse? @"Reversible" : @"")];
    
    Class subclass = NSClassFromString(transformerClassName);
    if ( ! subclass) {
        subclass = objc_allocateClassPair(self, transformerClassName.UTF8String, 0);
        
        [self inSubclass:subclass overrideSelector:@selector(valueClass) withImplementation:
         imp_implementationWithBlock(^Class(id self){
            return inputClass;
        })];
        [self inSubclass:subclass overrideSelector:@selector(transformedValueClass) withImplementation:
         imp_implementationWithBlock(^Class(id self){
            return outputClass;
        })];
        [self inSubclass:subclass overrideSelector:@selector(allowsReverseTransformation) withImplementation:
         imp_implementationWithBlock(^BOOL(id self){
            return isReverse;
        })];
        
        objc_registerClassPair(subclass);
    }
    else {
        OCAAssert([subclass isSubclassOfClass:self], @"Found existing class '%@', but it's not subclassed from '%@'!", subclass, self) return nil;
        
        OCAAssert([subclass valueClass] == inputClass, @"Found existing transformer class %@, but class of input value doesn't match. Requested %@ and got %@.", subclass, inputClass, [subclass valueClass]);
        OCAAssert([subclass transformedValueClass] == outputClass, @"Found existing transformer class %@, but class of output value doesn't match. Requested %@ and got %@.", subclass, outputClass, [subclass transformedValueClass]);
        OCAAssert([subclass allowsReverseTransformation] == isReverse, @"Found existing transformer class %@, but %@ reversible.", subclass, (isReverse? @"it's not" : @"it's" ));
    }
    
    return subclass ?: self;
}


+ (void)inSubclass:(Class)subclass overrideSelector:(SEL)selector withImplementation:(IMP)implementation {
    Method method = class_getClassMethod(subclass, selector);
    method_setImplementation(method, implementation);
}


+ (instancetype)fromClass:(Class)inputClass toClass:(Class)outputClass transformation:(OCATransformerBlock)transformation {
    return [self fromClass:inputClass toClass:outputClass transformation:transformation reverseTransformation:nil];
}


+ (instancetype)fromClass:(Class)inputClass toClass:(Class)outputClass transformation:(OCATransformerBlock)transformationBlock reverseTransformation:(OCATransformerBlock)reverseTransformationBlock {
    BOOL hasReversingBlock = (reverseTransformationBlock != nil);
    BOOL preservesClass = (inputClass == outputClass);
    Class class = [self transformerClassFromClass:inputClass toClass:outputClass isReverse:(hasReversingBlock || preservesClass)];
    
    OCATransformer *transformer = [[class alloc] init];
    transformer->_transformationBlock = transformationBlock;
    transformer->_reverseTransformationBlock = reverseTransformationBlock;
    return transformer;
}





@end



