//
//  OCAPredicate+UIEdgeInsets.m
//  Objective-Chain
//
//  Created by Martin Kiss on 28.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAPredicate+UIEdgeInsets.h"
#import "OCAGeometry+Functions.h"










#if OCA_iOS


@implementation OCAPredicate (UIEdgeInsets)





+ (NSPredicate *)predicateForEdgeInsets:(BOOL(^)(UIEdgeInsets insets))block {
    return [OCAPredicate predicateForClass:[NSValue class] block:^BOOL(NSValue *value) {
        UIEdgeInsets insets;
        BOOL success = [value unboxValue:&insets objCType:@encode(UIEdgeInsets)];
        if ( ! success) return NO;
        
        return block(insets);
    }];
}


+ (NSPredicate *)isEdgeInsetsEqualTo:(UIEdgeInsets)otherInsets {
    return [OCAPredicate predicateForEdgeInsets:^BOOL(UIEdgeInsets insets) {
        return UIEdgeInsetsEqualToEdgeInsets(insets, otherInsets);
    }];
}


+ (NSPredicate *)isEdgeInsetsZero {
    return [OCAPredicate predicateForEdgeInsets:^BOOL(UIEdgeInsets insets) {
        return UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero);
    }];
}





@end


#endif


