//
//  OCAPredicate+CGAffineTransform.m
//  Objective-Chain
//
//  Created by Martin Kiss on 28.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAPredicate+CGAffineTransform.h"
#import "OCAGeometry+Functions.h"










@implementation OCAPredicate (CGAffineTransform)





+ (NSPredicate *)predicateForAffineTransform:(BOOL(^)(CGAffineTransform t))block {
    return [OCAPredicate predicateForClass:[NSValue class] block:^BOOL(NSValue *value) {
        CGAffineTransform t;
        BOOL success = [value unboxValue:&t objCType:@encode(CGAffineTransform)];
        if ( ! success)  return NO;
        
        return block(t);
    }];
}


+ (NSPredicate *)isAffineTransformIdentity {
    return [OCAPredicate predicateForAffineTransform:^BOOL(CGAffineTransform t) {
        return CGAffineTransformIsIdentity(t);
    }];
}


+ (NSPredicate *)isAffineTransformEqualTo:(CGAffineTransform)otherAffineTransform {
    return [OCAPredicate predicateForAffineTransform:^BOOL(CGAffineTransform t) {
        return CGAffineTransformEqualToTransform(t, otherAffineTransform);
    }];
}





@end
