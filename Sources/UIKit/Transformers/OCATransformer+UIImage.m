//
//  OCATransformer+UIImage.m
//  Objective-Chain
//
//  Created by Martin Kiss on 12.5.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <UIKit/UIGraphics.h>
#import "OCATransformer+UIImage.h"
#import "OCAGeometry+Functions.h"
#import "OCAVariadic.h"











@implementation OCATransformer (UIImage)





+ (OCATransformer *)resizeImageTo:(CGSize)size scale:(CGFloat)scale {
    return [[OCATransformer fromClass:[UIImage class] toClass:[UIImage class]
                           transform:^UIImage *(UIImage *input) {
                               if ( ! input) return nil;
                               if (input.images) return nil; // Do not resize animated images
                               
                               CGRect rect = (CGRect){
                                   .origin = CGPointZero,
                                   .size = size,
                               };
                               
                               UIGraphicsBeginImageContextWithOptions(size, NO, scale ?: input.scale);
                               [input drawInRect:rect blendMode:kCGBlendModeNormal alpha:1];
                               UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
                               UIGraphicsEndImageContext();
                               
                               return [resized imageWithRenderingMode:input.renderingMode];
                               
                           } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"resize image to %@", OCAStringFromSize(size)]
            reverse:@"pass"];
}


+ (OCATransformer *)clipImageTo:(UIBezierPath *)path {
    return [[OCATransformer fromClass:[UIImage class] toClass:[UIImage class]
                            transform:^UIImage *(UIImage *input) {
                                if ( ! input) return nil;
                                if ( ! path) return nil;
                                
                                UIGraphicsBeginImageContextWithOptions(input.size, NO, input.scale);
                                [path addClip];
                                [input drawAtPoint:CGPointZero];
                                UIImage *clipped = UIGraphicsGetImageFromCurrentImageContext();
                                UIGraphicsEndImageContext();
                                
                                return [clipped imageWithRenderingMode:input.renderingMode];
                                
                            } reverse:OCATransformationPass]
            describe:@"clip image"
            reverse:@"pass"];
}


+ (OCATransformer *)clipImageToCircle {
    // Since path is constructed from image's size, can't call +clipImageTo:
    return [[OCATransformer fromClass:[UIImage class] toClass:[UIImage class]
                            transform:^UIImage *(UIImage *input) {
                                if ( ! input) return nil;
                                
                                CGRect rect = (CGRect){
                                    .origin = CGPointZero,
                                    .size = input.size,
                                };
                                UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
                                
                                UIGraphicsBeginImageContextWithOptions(input.size, NO, input.scale);
                                [path addClip];
                                [input drawAtPoint:CGPointZero];
                                UIImage *clipped = UIGraphicsGetImageFromCurrentImageContext();
                                UIGraphicsEndImageContext();
                                
                                return [clipped imageWithRenderingMode:input.renderingMode];
                                
                            } reverse:OCATransformationPass]
            describe:@"clip image to circle"
            reverse:@"pass"];
}


+ (OCATransformer *)setImageRenderingMode:(UIImageRenderingMode)mode {
    return [[OCATransformer fromClass:[UIImage class] toClass:[UIImage class]
                            transform:^UIImage *(UIImage *input) {
                                
                                return [input imageWithRenderingMode:mode];
                                
                            } reverse:OCATransformationPass]
            describe:@"set rendering mode"
            reverse:@"pass"];
}


+ (OCATransformer *)filterImage:(CIFilter *)filter, ... NS_REQUIRES_NIL_TERMINATION {
    NSArray *filters = OCAArrayFromVariadicArguments(filter);
    return [OCATransformer fromClass:[UIImage class] toClass:[UIImage class]
                           asymetric:^UIImage *(UIImage *input) {
                               if ( ! input) return nil;
                               if ( ! filters.count) return input;
                               
                               CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                               CIContext *context = [CIContext contextWithOptions:
                                                     @{
                                                       kCIContextWorkingColorSpace: (__bridge id)colorSpace,
                                                       kCIContextOutputColorSpace: (__bridge id)colorSpace,
                                                       }];
                               CGColorSpaceRelease(colorSpace);
                               
                               CIImage *inputCI = [CIImage imageWithCGImage:input.CGImage];
                               
                               [filters.firstObject setValue:inputCI forKey:kCIInputImageKey];
                               
                               CIFilter *latestFilter = nil;
                               for (CIFilter *filter in filters) {
                                   if (latestFilter) {
                                       [filter setValue:latestFilter.outputImage forKey:kCIInputImageKey];
                                   }
                                   latestFilter = filter;
                               }
                               
                               CGImageRef outputCG = [context createCGImage:latestFilter.outputImage fromRect:inputCI.extent];
                               UIImage *output = [UIImage imageWithCGImage:outputCG scale:input.scale orientation:input.imageOrientation];
                               CGImageRelease(outputCG);
                               
                               return [output imageWithRenderingMode:input.renderingMode];
                           }];
}





@end




