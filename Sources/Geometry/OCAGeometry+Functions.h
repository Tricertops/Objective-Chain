//
//  OCAGeometry+Functions.h
//  Objective-Chain
//
//  Created by Martin Kiss on 27.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/NSString.h>
#import <CoreGraphics/CGGeometry.h>
#import "NSValue+Boxing.h"
#import "OCAObject.h"

#if OCA_iOS
    #import <UIKit/UIGeometry.h>
#endif





#pragma mark -
#pragma mark Rounding

extern CGFloat OCAGeometryDefaultScale(void);
extern CGFloat OCAGeometryRound(CGFloat value, CGFloat scale);
extern CGFloat OCAGeometryFloor(CGFloat value, CGFloat scale);
extern CGFloat OCAGeometryCeil(CGFloat value, CGFloat scale);





#pragma mark -
#pragma mark Point

extern CGPoint OCAPointFromString(NSString *);
extern NSString * OCAStringFromPoint(CGPoint);

extern CGPoint OCAPointAddPoint(CGPoint, CGPoint);
extern CGPoint OCAPointSubtractPoint(CGPoint, CGPoint);
extern CGPoint OCAPointMultiply(CGPoint point, CGFloat multipler);
extern CGPoint OCAPointNormalize(CGPoint);

extern CGPoint OCAPointRound(CGPoint point, CGFloat scale);
extern CGPoint OCAPointFloor(CGPoint point, CGFloat scale);
extern CGPoint OCAPointCeil(CGPoint point, CGFloat scale);

extern CGFloat OCAPointDistanceToPoint(CGPoint, CGPoint);
extern CGFloat OCAPointGetMagnitude(CGPoint);
extern CGFloat OCAPointGetAngle(CGPoint);





#pragma mark -
#pragma mark Size

extern CGSize OCASizeFromString(NSString *);
extern NSString * OCAStringFromSize(CGSize);

extern CGSize OCASizeExtendBySize(CGSize, CGSize);
extern CGSize OCASizeShrinkBySize(CGSize, CGSize);
extern CGSize OCASizeMultiply(CGSize, CGFloat);
extern CGSize OCASizeStandardize(CGSize size);

extern CGSize OCASizeRound(CGSize size, CGFloat scale);
extern CGSize OCASizeFloor(CGSize size, CGFloat scale);
extern CGSize OCASizeCeil(CGSize size, CGFloat scale);

extern CGFloat OCASizeGetArea(CGSize size);
extern CGFloat OCASizeGetRatio(CGSize size);





#pragma mark -
#pragma mark Rectangle

extern CGRect OCARectFromString(NSString *);
extern NSString * OCAStringFromRect(CGRect);

extern CGRect OCARectRound(CGRect rect, CGFloat scale);
extern CGRect OCARectCeil(CGRect rect, CGFloat scale);
extern CGRect OCARectFloor(CGRect rect, CGFloat scale);

extern CGPoint OCARectGetRelativePoint(CGRect rect, CGPoint point);
extern CGFloat OCARectGetEdge(CGRect, CGRectEdge);





#if OCA_iOS

#pragma mark -
#pragma mark Edge Insets

extern UIEdgeInsets OCAEdgeInsetsAddEdgeInsets(UIEdgeInsets, UIEdgeInsets);
extern UIEdgeInsets OCAEdgeInsetsSubtractEdgeInsets(UIEdgeInsets, UIEdgeInsets);
extern UIEdgeInsets OCAEdgeInsetsMultiply(UIEdgeInsets insets, CGFloat multipler);

extern UIEdgeInsets OCAEdgeInsetsRound(UIEdgeInsets insets, CGFloat scale);
extern UIEdgeInsets OCAEdgeInsetsFloor(UIEdgeInsets insets, CGFloat scale);
extern UIEdgeInsets OCAEdgeInsetsCeil(UIEdgeInsets insets, CGFloat scale);

#endif


