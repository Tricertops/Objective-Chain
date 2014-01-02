//
//  OCAMath.h
//  Objective-Chain
//
//  Created by Martin Kiss on 2.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCATransformer.h"
#import <math.h>



typedef long OCAInteger;
typedef double OCAReal;
typedef OCAInteger(^OCAIntegerTransformBlock)(OCAInteger x);
typedef OCAReal(^OCARealTransformBlock)(OCAReal x);





@interface OCAMath : OCAObject



#pragma mark Generic

+ (OCATransformer *)integerTransform:(OCAIntegerTransformBlock)transform;
+ (OCATransformer *)integerTransform:(OCAIntegerTransformBlock)transform reverse:(OCAIntegerTransformBlock)reverse;
+ (OCATransformer *)transform:(OCARealTransformBlock)transform;
+ (OCATransformer *)transform:(OCARealTransformBlock)transform reverse:(OCARealTransformBlock)reverse;
+ (OCATransformer *)function:(OCAReal(*)(OCAReal))function;
+ (OCATransformer *)function:(OCAReal(*)(OCAReal))function reverse:(OCAReal(*)(OCAReal))reverse;



#pragma mark Basic

+ (OCATransformer *)add:(OCAReal)value;
+ (OCATransformer *)subtract:(OCAReal)value;
+ (OCATransformer *)multiplyBy:(OCAReal)value;
+ (OCATransformer *)divideBy:(OCAReal)value;
+ (OCATransformer *)modulus:(OCAReal)value;
+ (OCATransformer *)absoluteValue;


+ (OCATransformer *)greaterThan:(OCAReal)value;
+ (OCATransformer *)greaterOrEqualThan:(OCAReal)value;
+ (OCATransformer *)lowerThan:(OCAReal)value;
+ (OCATransformer *)lowerOrEqualThan:(OCAReal)value;
+ (OCATransformer *)equals:(OCAReal)value;


#pragma mark Advanced

+ (OCATransformer *)powerBy:(OCAReal)value;
+ (OCATransformer *)rootOf:(OCAReal)value;
+ (OCATransformer *)logarithmWithBase:(OCAReal)value;


#pragma mark Rounding

+ (OCATransformer *)roundToClosest:(OCAReal)value;
+ (OCATransformer *)roundUpToClosest:(OCAReal)value;
+ (OCATransformer *)roundDownToClosest:(OCAReal)value;


#pragma mark Limits

+ (OCATransformer *)maximumOf:(OCAReal)value;
+ (OCATransformer *)minimumOf:(OCAReal)value;
+ (OCATransformer *)clampFrom:(OCAReal)minimum to:(OCAReal)maximum;


#pragma mark Trigonometry

+ (OCATransformer *)sine;
+ (OCATransformer *)cosine;
+ (OCATransformer *)tangent;
+ (OCATransformer *)arcSine;
+ (OCATransformer *)arcCosine;
+ (OCATransformer *)arcTangent;
+ (OCATransformer *)arcTangentOfTwo;

+ (OCATransformer *)toDegrees;
+ (OCATransformer *)toRadians;


@end


