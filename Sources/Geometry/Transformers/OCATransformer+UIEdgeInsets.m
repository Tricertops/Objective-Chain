//
//  OCATransformer+UIEdgeInsets.m
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+UIEdgeInsets.h"
#import "OCAGeometry+Functions.h"


#if OCA_iOS










@implementation OCATransformer (UIEdgeInsets)





#pragma mark Creating Edge Insets


+ (OCATransformer *)edgeInsetsFromEdges:(UIRectEdge)edges {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSValue class]
                           asymetric:^NSValue *(NSNumber *input) {
                               
                               CGFloat value = input.doubleValue;
                               UIEdgeInsets insets = UIEdgeInsetsZero;
                               if (edges & UIRectEdgeTop) insets.top = value;
                               if (edges & UIRectEdgeLeft) insets.left = value;
                               if (edges & UIRectEdgeRight) insets.right = value;
                               if (edges & UIRectEdgeBottom) insets.bottom = value;
                               return OCABox(insets);
                           }]
            describe:@"edge insets from edges"];
}


+ (OCATransformer *)edgeInsetsFromString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSValue class]
                           transform:^NSValue *(NSString *input) {
                               
                               return OCABox(UIEdgeInsetsFromString(input));
                               
                           } reverse:^NSString *(NSValue *input) {
                               
                               UIEdgeInsets insets = OCAUnbox(input, UIEdgeInsets, UIEdgeInsetsZero);
                               return NSStringFromUIEdgeInsets(insets);
                           }]
            describe:@"edge insets from string"
            reverse:@"string from edge insets"];
}





#pragma mark Modifying Edge Insets


+ (OCATransformer *)modifyEdgeInsets:(UIEdgeInsets(^)(UIEdgeInsets insets))block {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            asymetric:^NSValue *(NSValue *input) {
                                
                                UIEdgeInsets insets = OCAUnbox(input, UIEdgeInsets, UIEdgeInsetsZero);
                                insets = block(insets);
                                return OCABox(insets);
                            }]
            describe:@"modify edge insets"];
}


+ (OCATransformer *)modifyEdgeInsets:(UIEdgeInsets(^)(UIEdgeInsets insets))block reverse:(UIEdgeInsets(^)(UIEdgeInsets insets))reverseBlock {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            transform:^NSValue *(NSValue *input) {
                                
                                UIEdgeInsets insets = OCAUnbox(input, UIEdgeInsets, UIEdgeInsetsZero);
                                insets = block(insets);
                                return OCABox(insets);
                                
                            } reverse:^NSValue *(NSValue *input) {
                                
                                UIEdgeInsets insets = OCAUnbox(input, UIEdgeInsets, UIEdgeInsetsZero);
                                insets = reverseBlock(insets);
                                return OCABox(insets);
                            }]
            describe:@"modify edge insets"];
}


+ (OCATransformer *)addEdgeInsets:(UIEdgeInsets)otherInsets {
    return [[OCATransformer modifyEdgeInsets:^UIEdgeInsets(UIEdgeInsets insets) {
        
        return OCAEdgeInsetsAddEdgeInsets(insets, otherInsets);
        
    } reverse:^UIEdgeInsets(UIEdgeInsets insets) {
        
        return OCAEdgeInsetsSubtractEdgeInsets(insets, otherInsets);
    }]
            describe:[NSString stringWithFormat:@"add edge insets %@", NSStringFromUIEdgeInsets(otherInsets)]
            reverse:[NSString stringWithFormat:@"subtract edge insets %@", NSStringFromUIEdgeInsets(otherInsets)]];
}


+ (OCATransformer *)subtractEdgeInsets:(UIEdgeInsets)otherInsets {
    return [[OCATransformer addEdgeInsets:otherInsets] reversed];
}


+ (OCATransformer *)multiplyEdgeInsets:(CGFloat)multiplier {
    return [[OCATransformer modifyEdgeInsets:^UIEdgeInsets(UIEdgeInsets insets) {
        
        return OCAEdgeInsetsMultiply(insets, multiplier);
        
    } reverse:^UIEdgeInsets(UIEdgeInsets insets) {
        
        return OCAEdgeInsetsMultiply(insets, 1 / multiplier);
    }]
            describe:[NSString stringWithFormat:@"multiply edge insets by %@", @(multiplier)]
            reverse:[NSString stringWithFormat:@"multiply edge insets by %@", @(1 / multiplier)]];
}


+ (OCATransformer *)roundEdgeInsetsTo:(CGFloat)scale {
    return [[OCATransformer modifyEdgeInsets:^UIEdgeInsets(UIEdgeInsets insets) {
        
        return OCAEdgeInsetsRound(insets, scale);
        
    } reverse:^UIEdgeInsets(UIEdgeInsets insets) {
        return insets;
    }]
            describe:[NSString stringWithFormat:@"round edge insets to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)ceilEdgeInsetsTo:(CGFloat)scale {
    return [[OCATransformer modifyEdgeInsets:^UIEdgeInsets(UIEdgeInsets insets) {
        
        return OCAEdgeInsetsCeil(insets, scale);
        
    } reverse:^UIEdgeInsets(UIEdgeInsets insets) {
        return insets;
    }]
            describe:[NSString stringWithFormat:@"ceil edge insets to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)floorEdgeInsetsTo:(CGFloat)scale {
    return [[OCATransformer modifyEdgeInsets:^UIEdgeInsets(UIEdgeInsets insets) {
        
        return OCAEdgeInsetsFloor(insets, scale);
        
    } reverse:^UIEdgeInsets(UIEdgeInsets insets) {
        return insets;
    }]
            describe:[NSString stringWithFormat:@"floor edge insets to %@", @(scale)]
            reverse:@"pass"];
}





#pragma mark Disposing Edge Insets


+ (OCATransformer *)stringFromEdgeInsets {
    return [[OCATransformer edgeInsetsFromString] reversed];
}


+ (OCATransformer *)edgeInsetsGetHorizontal {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSNumber class]
                           asymetric:^NSNumber *(NSValue *input) {
                               
                               UIEdgeInsets insets = OCAUnbox(input, UIEdgeInsets, UIEdgeInsetsZero);
                               return @( insets.left + insets.right);
                           }]
            describe:@"get horizontal edge insets"];
}


+ (OCATransformer *)edgeInsetsGetVertical {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSNumber class]
                            asymetric:^NSNumber *(NSValue *input) {
                                
                                UIEdgeInsets insets = OCAUnbox(input, UIEdgeInsets, UIEdgeInsetsZero);
                                return @( insets.top + insets.bottom);
                            }]
            describe:@"get vertical edge insets"];
}





@end


#endif // OCA_iOS


