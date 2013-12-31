//
//  OCATransformer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//
//

#import <Foundation/Foundation.h>


typedef id (^OCATransformerBlock)(id input);





@interface OCATransformer : NSValueTransformer



#pragma mark Methods To Override In Subclass

+ (Class)valueClass;
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;

- (id)transformedValue:(id)value;
- (id)reverseTransformedValue:(id)value;



#pragma mark Customizing Using Blocks

+ (instancetype)subclassTransformerWithName:(NSString *)name
                                 inputClass:(Class)inputClass
                                outputClass:(Class)outputClass
                             transformation:(OCATransformerBlock)transformation
                                 reversible:(BOOL)allowsReversedTransformtion
                      reverseTransformation:(OCATransformerBlock)reverseTransformation;

+ (instancetype)fromClass:(Class)inputClass
                  toClass:(Class)outputClass
           transformation:(OCATransformerBlock)transformation;

+ (instancetype)fromClass:(Class)inputClass
                  toClass:(Class)outputClass
           transformation:(OCATransformerBlock)transformation
    reverseTransformation:(OCATransformerBlock)reverseTransformation;



@end


