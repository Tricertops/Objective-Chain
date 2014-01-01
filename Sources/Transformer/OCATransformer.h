//
//  OCATransformer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef id (^OCATransformerBlock)(id input);





@interface NSValueTransformer (valueClass)

+ (Class)valueClass;

@end





@interface OCATransformer : NSValueTransformer



#pragma mark Methods To Override In Subclass

+ (Class)valueClass;
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;

- (id)transformedValue:(id)value;
- (id)reverseTransformedValue:(id)value;



#pragma mark Deriving Transformers

- (OCATransformer *)reversed;



#pragma mark Customizing Using Blocks

+ (Class)subclassForInputClass:(Class)inputClass outputClass:(Class)outputClass reversible:(BOOL)isReversible name:(NSString *)subclassName;
- (instancetype)initWithBlock:(OCATransformerBlock)transformationBlock reverseBlock:(OCATransformerBlock)reverseTransformationBlock;

+ (instancetype)fromClass:(Class)inputClass toClass:(Class)outputClass transformation:(OCATransformerBlock)transformationBlock;
+ (instancetype)fromClass:(Class)inputClass toClass:(Class)outputClass transformation:(OCATransformerBlock)transformationBlock reverseTransformation:(OCATransformerBlock)reverseTransformationBlock;



@end


