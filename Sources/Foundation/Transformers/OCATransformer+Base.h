//
//  OCATransformer+Base.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
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

@property (nonatomic, readonly, copy) NSString *reverseDescription;
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

+ (OCATransformer *)there:(NSValueTransformer *)forward back:(NSValueTransformer *)backward;



@end





extern OCATransformerBlock const OCATransformationDiscard;
extern OCATransformerBlock const OCATransformationPass;





@interface NSObject (NSValueTransformer)

- (id)transform:(NSValueTransformer *)transformer __deprecated;

@end


