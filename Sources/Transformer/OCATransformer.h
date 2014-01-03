//
//  OCATransformer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCAObject.h"


typedef id (^OCATransformerBlock)(id input);





@interface NSValueTransformer (OCATransformerCompatibility)

+ (Class)valueClass;

- (NSValueTransformer *)reversed;

@end





@interface OCATransformer : NSValueTransformer



#pragma mark Class Info

+ (Class)valueClass;
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;



#pragma mark Transformation

- (id)transformedValue:(id)value;
- (id)reverseTransformedValue:(id)value;



#pragma mark Describing

@property (OCA_atomic, readonly, copy) NSString *description;
@property (OCA_atomic, readonly, copy) NSString *reverseDescription;
- (instancetype)describe:(NSString *)description;
- (instancetype)describe:(NSString *)description reverse:(NSString *)reverseDescription;



#pragma mark Deriving Transformers

- (OCATransformer *)reversed;
- (OCATransformer *)specializeFromClass:(Class)fromClass toClass:(Class)toClass;



#pragma mark Customizing Using Blocks

+ (Class)subclassForInputClass:(Class)inputClass outputClass:(Class)outputClass reversible:(BOOL)isReversible;
- (OCATransformer *)initWithBlock:(OCATransformerBlock)block reverseBlock:(OCATransformerBlock)reverseBlock;

+ (OCATransformer *)fromClass:(Class)fromClass toClass:(Class)toClass symetric:(OCATransformerBlock)symetric;
+ (OCATransformer *)fromClass:(Class)fromClass toClass:(Class)toClass asymetric:(OCATransformerBlock)asymetric;
+ (OCATransformer *)fromClass:(Class)fromClass toClass:(Class)toClass transform:(OCATransformerBlock)transform reverse:(OCATransformerBlock)reverse;


+ (Class)valueClassForClasses:(NSArray *)classes;



@end




extern OCATransformerBlock const OCATransformationNil;
extern OCATransformerBlock const OCATransformationPass;




