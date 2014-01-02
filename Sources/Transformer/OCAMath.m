//
//  OCAMath.m
//  Objective-Chain
//
//  Created by Martin Kiss on 2.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMath.h"





@implementation OCAMath





+ (OCATransformer *)integerTransform:(OCAIntegerTransformBlock)transform {
    return [self integerTransform:transform reverse:nil];
}


+ (OCATransformer *)integerTransform:(OCAIntegerTransformBlock)transformBlock reverse:(OCAIntegerTransformBlock)reverseBlock {
    return [OCATransformer fromClass:[NSNumber class] toClass:[NSNumber class]
            
                           transform:^NSNumber *(NSNumber *input) {
                               if (transformBlock) return @( transformBlock(input.longValue) );
                               else return input;
                               
                           } reverse:^NSNumber *(NSNumber *input) {
                               if (reverseBlock) return @( reverseBlock(input.longValue) );
                               else return input;
                           }];
}


+ (OCATransformer *)transform:(OCARealTransformBlock)transform {
    return [self transform:transform reverse:nil];
}


+ (OCATransformer *)transform:(OCARealTransformBlock)transformBlock reverse:(OCARealTransformBlock)reverseBlock {
    return [OCATransformer fromClass:[NSNumber class] toClass:[NSNumber class]
            
                           transform:^NSNumber *(NSNumber *input) {
                               if (transformBlock) return @( transformBlock(input.doubleValue) );
                               else return input;
                               
                           } reverse:^NSNumber *(NSNumber *input) {
                               if (reverseBlock) return @( reverseBlock(input.doubleValue) );
                               else return input;
                           }];
}





//TODO: Implement operations.





@end
