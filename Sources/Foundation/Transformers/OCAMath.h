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

+ (OCATransformer *)transform:(OCARealTransformBlock)transform;
+ (OCATransformer *)transform:(OCARealTransformBlock)transform reverse:(OCARealTransformBlock)reverse;

+ (OCATransformer *)function:(OCAReal(*)(OCAReal))function;
+ (OCATransformer *)function:(OCAReal(*)(OCAReal))function reverse:(OCAReal(*)(OCAReal))reverse;


#pragma mark Basic

+ (OCATransformer *)add:(OCAReal)add;
+ (OCATransformer *)subtract:(OCAReal)substract;
+ (OCATransformer *)subtractFrom:(OCAReal)value;
+ (OCATransformer *)multiplyBy:(OCAReal)multiplier;
+ (OCATransformer *)divideBy:(OCAReal)divisor;
+ (OCATransformer *)modulus:(OCAInteger)value;
+ (OCATransformer *)absoluteValue;
+ (OCATransformer *)inversedValue;

+ (OCATransformer *)relativeBetween:(OCAReal)lower and:(OCAReal)upper;
+ (OCATransformer *)absoluteBetween:(OCAReal)lower and:(OCAReal)upper;


#pragma mark Advanced

+ (OCATransformer *)powerBy:(OCAReal)value;
+ (OCATransformer *)rootOf:(OCAReal)value;
+ (OCATransformer *)exponentOf:(OCAReal)value;
+ (OCATransformer *)logarithmWithBase:(OCAReal)base;


#pragma mark Rounding

+ (OCATransformer *)roundTo:(OCAReal)scale;
+ (OCATransformer *)floorTo:(OCAReal)scale;
+ (OCATransformer *)ceilTo:(OCAReal)scale;


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

+ (OCATransformer *)toDegrees;
+ (OCATransformer *)toRadians;


#pragma mark Array

+ (OCATransformer *)sum;
+ (OCATransformer *)average;
+ (OCATransformer *)minimum;
+ (OCATransformer *)maximum;


#pragma mark Random

+ (OCATransformer *)randomUpTo:(NSUInteger)bound;


#pragma mark Logic

+ (OCATransformer *)allTrue;
+ (OCATransformer *)anyTrue;



@end





#pragma mark Functions

extern OCAReal OCALogarithm(OCAReal x, OCAReal base);
extern OCAReal OCARound(OCAReal x, OCAReal scale);
extern OCAReal OCACeil(OCAReal x, OCAReal scale);
extern OCAReal OCAFloor(OCAReal x, OCAReal scale);
extern OCAReal OCAClamp(OCAReal lower, OCAReal value, OCAReal upper);


