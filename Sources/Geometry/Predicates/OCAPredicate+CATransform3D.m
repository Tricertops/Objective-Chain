//
//  OCAPredicate+CATransform3D.m
//  Objective-Chain
//
//  Created by Martin Kiss on 28.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAPredicate+CATransform3D.h"
#import "OCAGeometry+Functions.h"










@implementation OCAPredicate (CATransform3D)





+ (NSPredicate *)predicateForTransform3D:(BOOL(^)(CATransform3D t))block {
    return [OCAPredicate predicateForClass:[NSValue class] block:^BOOL(NSValue *value) {
        CATransform3D t;
        BOOL success = [value unboxValue:&t objCType:@encode(CATransform3D)];
        if ( ! success) return NO;
        
        return block(t);
    }];
}


+ (NSPredicate *)isTransform3DEqualTo:(CATransform3D)otherTransform3D {
    return [OCAPredicate predicateForTransform3D:^BOOL(CATransform3D t) {
        return CATransform3DEqualToTransform(t, otherTransform3D);
    }];
}


+ (NSPredicate *)isTransform3DIdentity {
    return [OCAPredicate predicateForTransform3D:^BOOL(CATransform3D t) {
        return CATransform3DIsIdentity(t);
    }];
}


+ (NSPredicate *)isTransform3DAffineTransform {
    return [OCAPredicate predicateForTransform3D:^BOOL(CATransform3D t) {
        return CATransform3DIsAffine(t);
    }];
}





@end


