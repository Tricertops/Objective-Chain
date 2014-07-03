//
//  OCAMath.m
//  Objective-Chain
//
//  Created by Martin Kiss on 2.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMath.h"
#import "OCAPredicate.h"





@implementation OCAMath





#pragma mark Generic


+ (OCATransformer *)integerTransform:(OCAIntegerTransformBlock)transform {
    return [self integerTransform:transform reverse:nil];
}


+ (OCATransformer *)integerTransform:(OCAIntegerTransformBlock)transformBlock reverse:(OCAIntegerTransformBlock)reverseBlock {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSNumber class]
            
                           transform:^NSNumber *(NSNumber *input) {
                               if (transformBlock) return @( transformBlock(input.longValue) );
                               else return input;
                               
                           } reverse:^NSNumber *(NSNumber *input) {
                               if (reverseBlock) return @( reverseBlock(input.longValue) );
                               else return input;
                               
                           }] describe:@"integer operation"];
}


+ (OCATransformer *)transform:(OCARealTransformBlock)transform {
    return [self transform:transform reverse:nil];
}


+ (OCATransformer *)transform:(OCARealTransformBlock)transformBlock reverse:(OCARealTransformBlock)reverseBlock {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSNumber class]
            
                           transform:^NSNumber *(NSNumber *input) {
                               if ( ! input) return nil;
                               if (transformBlock) return @( transformBlock(input.doubleValue) );
                               else return input;
                               
                           } reverse:^NSNumber *(NSNumber *input) {
                               if ( ! input) return nil;
                               if (reverseBlock) return @( reverseBlock(input.doubleValue) );
                               else return input;
                               
                           }] describe:@"math operation"];
}


+ (OCATransformer *)function:(OCAReal(*)(OCAReal))function {
    return [self function:function reverse:nil];
}


+ (OCATransformer *)function:(OCAReal(*)(OCAReal))function reverse:(OCAReal (*)(OCAReal))reverse {
    return [self transform:^OCAReal(OCAReal x) {
        return (function? function(x) : NAN);
    } reverse:^OCAReal(OCAReal y) {
        return (reverse? reverse(y) : NAN);
    }];
}





#pragma mark Basic


+ (OCATransformer *)add:(OCAReal)value {
    return [[self transform:^OCAReal(OCAReal x) {
        return x + value;
    } reverse:^OCAReal(OCAReal y) {
        return y - value;
    }]
            describe:[NSString stringWithFormat:@"add %@", @(value)]
            reverse:[NSString stringWithFormat:@"subtract %@", @(value)]];
}


+ (OCATransformer *)subtract:(OCAReal)value {
    return [[self add:value] reversed];
}


+ (OCATransformer *)subtractFrom:(OCAReal)value {
    return [[self transform:^OCAReal(OCAReal x) {
        return value - x;
    } reverse:^OCAReal(OCAReal y) {
        return value - y;
    }]
            describe:[NSString stringWithFormat:@"subtract from %@", @(value)]];
}


+ (OCATransformer *)multiplyBy:(OCAReal)value {
    return [[self transform:^OCAReal(OCAReal x) {
        return x * value;
    } reverse:^OCAReal(OCAReal y) {
        return y / value;
    }]
            describe:[NSString stringWithFormat:@"multiply by %@", @(value)]
            reverse:[NSString stringWithFormat:@"divide by %@", @(value)]];
}


+ (OCATransformer *)divideBy:(OCAReal)value {
    return [[self multiplyBy:value] reversed];
}


+ (OCATransformer *)modulus:(OCAInteger)value {
    return [[self transform:^OCAReal(OCAReal x) {
        OCAInteger integer = floor(x / value);
        return x - integer * value;
    } reverse:^OCAReal(OCAReal y) {
        return y;
    }]
            describe:[NSString stringWithFormat:@"modulus %@", @(value)]
            reverse:@"pass integer"];
}


+ (OCATransformer *)absoluteValue {
    return [[self transform:^OCAReal(OCAReal x) {
        return ABS(x);
    } reverse:^OCAReal(OCAReal y) {
        return ABS(y);
    }]
            describe:@"absolute value"];
}


+ (OCATransformer *)inversedValue {
    return [[self transform:^OCAReal(OCAReal x) {
        return 1/x;
    } reverse:^OCAReal(OCAReal y) {
        return 1/y;
    }]
            describe:@"inversed value"];
}


+ (OCATransformer *)relativeBetween:(OCAReal)lower and:(OCAReal)upper {
    OCAReal delta = upper - lower;
    return [[self transform:^OCAReal(OCAReal x) {
        return (x - lower) / delta;
    } reverse:^OCAReal(OCAReal y) {
        return lower + (delta * y);
    }]
            describe:[NSString stringWithFormat:@"relative between %@ and %@", @(lower), @(upper)]
            reverse:[NSString stringWithFormat:@"absolute between %@ and %@", @(lower), @(upper)]];
}


+ (OCATransformer *)absoluteBetween:(OCAReal)lower and:(OCAReal)upper {
    return [[OCAMath relativeBetween:lower and:upper] reversed];
}





#pragma mark Advanced


+ (OCATransformer *)powerBy:(OCAReal)value {
    return [[self transform:^OCAReal(OCAReal x) {
        return pow(x, value);
    } reverse:^OCAReal(OCAReal y) {
        return pow(y, 1/value);
    }]
            describe:[NSString stringWithFormat:@"power by %@", @(value)]
            reverse:[NSString stringWithFormat:@"root of %@", @(value)]];
}


+ (OCATransformer *)rootOf:(OCAReal)value {
    return [[self powerBy:value] reversed];
}


+ (OCATransformer *)exponentOf:(OCAReal)value {
    return [[self transform:^OCAReal(OCAReal x) {
        return pow(value, x);
    } reverse:^OCAReal(OCAReal y) {
        return OCALogarithm(y, value);
    }]
            describe:[NSString stringWithFormat:@"exponent of %@", @(value)]
            reverse:[NSString stringWithFormat:@"log with base %@", @(value)]];
}


+ (OCATransformer *)logarithmWithBase:(OCAReal)base {
    return [[self exponentOf:base] reversed];
}





#pragma mark Rounding


+ (OCATransformer *)roundTo:(OCAReal)scale {
    return [[OCAMath transform:^OCAReal(OCAReal x) {
        return OCARound(x, scale);
    } reverse:^OCAReal(OCAReal y) {
        return y;
    }]
            describe:[NSString stringWithFormat:@"round to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)ceilTo:(OCAReal)scale {
    return [[OCAMath transform:^OCAReal(OCAReal x) {
        return OCACeil(x, scale);
    } reverse:^OCAReal(OCAReal y) {
        return y;
    }]
            describe:[NSString stringWithFormat:@"round up to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)floorTo:(OCAReal)scale {
    return [[OCAMath transform:^OCAReal(OCAReal x) {
        return OCAFloor(x, scale);
    } reverse:^OCAReal(OCAReal y) {
        return y;
    }]
            describe:[NSString stringWithFormat:@"round down to %@", @(scale)]
            reverse:@"pass"];
}





#pragma mark Limits


+ (OCATransformer *)maximumOf:(OCAReal)max {
    return [[OCAMath transform:^OCAReal(OCAReal x) {
        return MIN(x, max); // This is not a mistake. MIN will clamp the value from top.
    } reverse:^OCAReal(OCAReal y) {
        return y;
    }]
            describe:[NSString stringWithFormat:@"max %@", @(max)]
            reverse:@"pass"];
}


+ (OCATransformer *)minimumOf:(OCAReal)min {
    return [[OCAMath transform:^OCAReal(OCAReal x) {
        return MAX(x, min); // This is not a mistake. MAX will clamp the value from bottom.
    } reverse:^OCAReal(OCAReal y) {
        return y;
    }]
            describe:[NSString stringWithFormat:@"min %@", @(min)]
            reverse:@"pass"];
}


+ (OCATransformer *)clampFrom:(OCAReal)min to:(OCAReal)max {
    OCAAssert(min <= max, @"What is this supposed to do return, when minimum (%@) is greater than maximum (%@)?!", @(min), @(max)) return [OCATransformer discard];
    return [[OCAMath transform:^OCAReal(OCAReal x) {
        return OCAClamp(min, x, max);
    } reverse:^OCAReal(OCAReal y) {
        return y;
    }]
            describe:[NSString stringWithFormat:@"between %@ and %@", @(min), @(max)]
            reverse:@"pass"];
}





#pragma mark Trigonometry


+ (OCATransformer *)sine {
    return [[OCAMath function:&sin reverse:&asin] describe:@"sine" reverse:@"arc sine"];
}


+ (OCATransformer *)cosine {
    return [[OCAMath function:&cos reverse:&acos] describe:@"cosine" reverse:@"arc cosine"];
}


+ (OCATransformer *)tangent {
    return [[OCAMath function:&tan reverse:&atan] describe:@"tangent" reverse:@"arc tangent"];
}


+ (OCATransformer *)arcSine {
    return [[OCAMath sine] reversed];
}


+ (OCATransformer *)arcCosine {
    return [[OCAMath cosine] reversed];
}


+ (OCATransformer *)arcTangent {
    return [[OCAMath tangent] reversed];
}


+ (OCATransformer *)toDegrees {
    return [[OCATransformer sequence:@[ [OCAMath divideBy:M_PI],
                                        [OCAMath multiplyBy:180] ]]
            describe:@"to degrees" reverse:@"to radians"];
}


+ (OCATransformer *)toRadians {
    return [[OCAMath toDegrees] reversed];
}





#pragma mark Array


+ (OCATransformer *)sum {
    return [[[OCATransformer access:OCAKeyPathUnsafe(@"@sum.self")]
             specializeFromClass:[NSArray class] toClass:[NSNumber class]]
            describe:@"sum up"];
}


+ (OCATransformer *)average {
    return [[[OCATransformer access:OCAKeyPathUnsafe(@"@avg.self")]
             specializeFromClass:[NSArray class] toClass:[NSNumber class]]
            describe:@"average"];
}


+ (OCATransformer *)minimum {
    return [[[OCATransformer access:OCAKeyPathUnsafe(@"@min.self")]
             specializeFromClass:[NSArray class] toClass:[NSNumber class]]
            describe:@"find minimum"];
}


+ (OCATransformer *)maximum {
    return [[[OCATransformer access:OCAKeyPathUnsafe(@"@max.self")]
             specializeFromClass:[NSArray class] toClass:[NSNumber class]]
            describe:@"find maximum"];
}


+ (OCATransformer *)randomUpTo:(NSUInteger)bound {
    return [[OCAMath transform:^OCAReal(OCAReal x) {
        if (bound == NSUIntegerMax) return arc4random();
        else return arc4random_uniform((u_int32_t)bound);
    } reverse:^OCAReal(OCAReal y) {
        return y;
    }]
            describe:[NSString stringWithFormat:@"random up to %@", @(bound)]
            reverse:@"pass"];
}





#pragma mark Logic


+ (OCATransformer *)allTrue {
    return [OCATransformer sequence:
            @[
              [OCATransformer transformArray:[OCATransformer replaceNil:@NO]],
              [OCAMath minimum],
              [OCATransformer evaluatePredicate:[OCAPredicate isGreaterThan:@0]],
              ]];
}


+ (OCATransformer *)anyTrue {
    return [OCATransformer sequence:
            @[
              [OCATransformer transformArray:[OCATransformer replaceNil:@NO]],
              [OCAMath maximum],
              [OCATransformer evaluatePredicate:[OCAPredicate isGreaterThan:@0]],
              ]];
}





@end










#pragma mark Functions


OCAReal OCALogarithm(OCAReal x, OCAReal base) {
    return log(x) / log(base);
}


OCAReal OCARound(OCAReal x, OCAReal scale) {
    if ( ! scale) return x;
    return round(x / scale) * scale;
}


OCAReal OCACeil(OCAReal x, OCAReal scale) {
    if ( ! scale) return x;
    return ceil(x / scale) * scale;
}


extern OCAReal OCAFloor(OCAReal x, OCAReal scale) {
    if ( ! scale) return x;
    return floor(x / scale) * scale;
}


extern OCAReal OCAClamp(OCAReal lower, OCAReal value, OCAReal upper) {
    return (value > upper ? upper
            : (value < lower ? lower
               : value));
}


