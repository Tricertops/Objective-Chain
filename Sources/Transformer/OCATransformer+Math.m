//
//  OCATransformer+Math.m
//  Objective-Chain
//
//  Created by Martin Kiss on 2.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Math.h"





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
                               if (transformBlock) return @( transformBlock(input.doubleValue) );
                               else return input;
                               
                           } reverse:^NSNumber *(NSNumber *input) {
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
    return [[self integerTransform:^OCAInteger(OCAInteger x) {
        return x % value;
    } reverse:^OCAInteger(OCAInteger y) {
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
        return log(y) / log(value);
    }]
            describe:[NSString stringWithFormat:@"exponent of %@", @(value)]
            reverse:[NSString stringWithFormat:@"log with base %@", @(value)]];
}


+ (OCATransformer *)logarithmWithBase:(OCAReal)value {
    return [[self exponentOf:value] reversed];
}






//TODO: Implement operations.





@end


