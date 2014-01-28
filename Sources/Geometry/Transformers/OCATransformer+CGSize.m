//
//  OCATransformer+CGSize.m
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+CGSize.h"
#import "OCAGeometry+Functions.h"
#import "NSArray+Ordinals.h"










@implementation OCATransformer (CGSize)





#pragma mark Creating Sizes


+ (OCATransformer *)sizeFromString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSValue class]
                            transform:^NSValue *(NSString *input) {
                                
                                return OCABox(OCASizeFromString(input));
                                
                            } reverse:^NSString *(NSValue *input) {
                                
                                return OCAStringFromSize(OCAUnboxSize(input));
                            }]
            describe:@"size from string"
            reverse:@"string from size"];
}


+ (OCATransformer *)makeSize {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSValue class]
                            transform:^NSValue *(NSArray *input) {
                                
                                NSNumber *width = [input oca_valueAtIndex:0];
                                NSNumber *height = [input oca_valueAtIndex:1];
                                CGSize size = CGSizeMake(width.doubleValue, height.doubleValue);
                                return OCABox(size);
                                
                            } reverse:^NSArray *(NSValue *input) {
                                
                                CGSize size = OCAUnboxSize(input);
                                return @[ @(size.width), @(size.height) ];
                            }]
            describe:@"size from [w, h]"
            reverse:@"[w, h] from size"];
}



+ (OCATransformer *)makeSizeWithWidth:(CGFloat)width {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSValue class]
                            transform:^NSValue *(NSNumber *input) {
                                
                                return OCABox(CGSizeMake(width, input.doubleValue));
                                
                            } reverse:^NSNumber *(NSValue *input) {
                                
                                CGSize size = OCAUnboxSize(input);
                                return @(size.height);
                            }]
            describe:[NSString stringWithFormat:@"point with width %@", @(width)]
            reverse:@"CGSize.height"];
}


+ (OCATransformer *)makeSizeWithHeight:(CGFloat)height {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSValue class]
                            transform:^NSValue *(NSNumber *input) {
                                
                                return OCABox(CGSizeMake(input.doubleValue, height));
                                
                            } reverse:^NSNumber *(NSValue *input) {
                                
                                CGSize size = OCAUnboxSize(input);
                                return @(size.width);
                            }]
            describe:[NSString stringWithFormat:@"point with height %@", @(height)]
            reverse:@"CGSize.width"];
}





#pragma mark Modifying Sizes


+ (OCATransformer *)modifySize:(CGSize(^)(CGSize size))block {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            asymetric:^NSValue *(NSValue *input) {
                                
                                CGSize size = OCAUnboxSize(input);
                                size = block(size);
                                return OCABox(size);
                            }]
            describe:@"modify size"];
}


+ (OCATransformer *)modifySize:(CGSize(^)(CGSize size))block reverse:(CGSize(^)(CGSize size))reverseBlock {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            transform:^NSValue *(NSValue *input) {
                                
                                CGSize size = OCAUnboxSize(input);
                                size = block(size);
                                return OCABox(size);
                                
                            } reverse:^NSValue *(NSValue *input) {
                                
                                CGSize size = OCAUnboxSize(input);
                                size = reverseBlock(size);
                                return OCABox(size);
                            }]
            describe:@"modify size"];
}


+ (OCATransformer *)extendSizeBy:(CGSize)otherSize {
    return [[OCATransformer modifySize:^CGSize(CGSize size) {
        
        return OCASizeExtendBySize(size, otherSize);
        
    } reverse:^CGSize(CGSize size) {
        
        return OCASizeShrinkBySize(size, otherSize);
    }]
            describe:[NSString stringWithFormat:@"extend size by %@", OCAStringFromSize(otherSize)]
            reverse:[NSString stringWithFormat:@"shrink size by %@", OCAStringFromSize(otherSize)]];
}


+ (OCATransformer *)shrinkSizeBy:(CGSize)otherSize {
    return [[OCATransformer extendSizeBy:otherSize] reversed];
}


+ (OCATransformer *)multiplySizeBy:(CGFloat)multiplier {
    return [[OCATransformer modifySize:^CGSize(CGSize size) {
        
        return OCASizeMultiply(size, multiplier);
        
    } reverse:^CGSize(CGSize size) {
        
        return OCASizeMultiply(size, 1 / multiplier);
    }]
            describe:[NSString stringWithFormat:@"multiply size by %@", @(multiplier)]
            reverse:[NSString stringWithFormat:@"multiply size by %@", @(1 / multiplier)]];
}


+ (OCATransformer *)transformSize:(CGAffineTransform)affineTransform {
    return [[OCATransformer modifySize:^CGSize(CGSize size) {
        
        return CGSizeApplyAffineTransform(size, affineTransform);
        
    } reverse:^CGSize(CGSize size) {
        
        return CGSizeApplyAffineTransform(size, CGAffineTransformInvert(affineTransform));
    }]
            describe:@"apply affine transform on size"];
}


+ (OCATransformer *)roundSizeTo:(CGFloat)scale {
    return [[OCATransformer modifySize:^CGSize(CGSize size) {
        
        return OCASizeRound(size, scale);
        
    } reverse:^CGSize(CGSize size) {
        return size;
    }]
            describe:[NSString stringWithFormat:@"round size to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)floorSizeTo:(CGFloat)scale {
    return [[OCATransformer modifySize:^CGSize(CGSize size) {
        
        return OCASizeFloor(size, scale);
        
    } reverse:^CGSize(CGSize size) {
        return size;
    }]
            describe:[NSString stringWithFormat:@"floor size to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)ceilSizeTo:(CGFloat)scale {
    return [[OCATransformer modifySize:^CGSize(CGSize size) {
        
        return OCASizeCeil(size, scale);
        
    } reverse:^CGSize(CGSize size) {
        return size;
    }]
            describe:[NSString stringWithFormat:@"ceil size to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)standardizeSize {
    return [[OCATransformer modifySize:^CGSize(CGSize size) {
        
        return OCASizeStandardize(size);
        
    } reverse:^CGSize(CGSize size) {
        
        return size;
    }]
            describe:@"standardize size"
            reverse:@"pass"];
}





#pragma mark Disposing Sizes


+ (OCATransformer *)stringFromSize {
    return [[OCATransformer sizeFromString] reversed];
}


+ (OCATransformer *)sizeArea {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSNumber class]
                           asymetric:^NSNumber *(NSValue *input) {
                               
                               CGSize size = OCAUnbox(input, CGSize, CGSizeZero);
                               return @( OCASizeGetArea(size) );
                           }]
            describe:@"area of size"];
}


+ (OCATransformer *)sizeRatio {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSNumber class]
                            asymetric:^NSNumber *(NSValue *input) {
                                
                                CGSize size = OCAUnbox(input, CGSize, CGSizeZero);
                                return @( OCASizeGetRatio(size) );
                            }]
            describe:@"ratio of size"];
}





@end


