//
//  OCAGeometry+Functions.m
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAGeometry+Functions.h"
#import "OCAMath.h"

#if OCA_iOS
    #import <UIKit/UIScreen.h> // For default rounding scale.
#endif










#pragma mark - 
#pragma mark Rounding


CGFloat OCAGeometryDefaultScale(void) {
#if OCA_iOS
    return 1 / [[UIScreen mainScreen] scale];
#else
    return 1;
#endif
}


CGFloat OCAGeometryRound(CGFloat value, CGFloat scale) {
    return OCARound(value, scale ?: OCAGeometryDefaultScale());
}


CGFloat OCAGeometryFloor(CGFloat value, CGFloat scale) {
    return OCAFloor(value, scale ?: OCAGeometryDefaultScale());
}


CGFloat OCAGeometryCeil(CGFloat value, CGFloat scale) {
    return OCACeil(value, scale ?: OCAGeometryDefaultScale());
}





#pragma mark -
#pragma mark Point


CGPoint OCAPointFromString(NSString *string) {
#if OCA_iOS
    return CGPointFromString(string);
#else
    return NSPointToCGPoint(NSPointFromString(string));
#endif
}


NSString * OCAStringFromPoint(CGPoint point) {
#if OCA_iOS
    return NSStringFromCGPoint(point);
#else
    return NSStringFromPoint(NSPointFromCGPoint(point));
#endif
}


CGPoint OCAPointAddPoint(CGPoint a, CGPoint b) {
    a.x += b.x;
    a.y += b.y;
    return a;
}


CGPoint OCAPointSubtractPoint(CGPoint a, CGPoint b) {
    a.x -= b.x;
    a.y -= b.y;
    return a;
}


CGPoint OCAPointMultiply(CGPoint p, CGFloat m) {
    p.x *= m;
    p.y *= m;
    return p;
}


CGPoint OCAPointNormalize(CGPoint p) {
    return OCAPointMultiply(p, 1 / OCAPointGetMagnitude(p));
}


CGPoint OCAPointRound(CGPoint p, CGFloat s) {
    p.x = OCAGeometryRound(p.x, s);
    p.y = OCAGeometryRound(p.y, s);
    return p;
}


CGPoint OCAPointFloor(CGPoint p, CGFloat s) {
    p.x = OCAGeometryFloor(p.x, s);
    p.y = OCAGeometryFloor(p.y, s);
    return p;
}


CGPoint OCAPointCeil(CGPoint p, CGFloat s) {
    p.x = OCAGeometryCeil(p.x, s);
    p.y = OCAGeometryCeil(p.y, s);
    return p;
}


CGFloat OCAPointDistanceToPoint(CGPoint a, CGPoint b) {
    return OCAPointGetMagnitude(OCAPointSubtractPoint(a, b));
}


CGFloat OCAPointGetMagnitude(CGPoint p) {
    return sqrt((p.x * p.x) + (p.y * p.y));
}


CGFloat OCAPointGetAngle(CGPoint p) {
    return atan2(p.x, p.y);
}





#pragma mark -
#pragma mark Size


CGSize OCASizeFromString(NSString *string) {
#if OCA_iOS
    return CGSizeFromString(string);
#else
    return NSSizeToCGSize(NSSizeFromString(string));
#endif
}


NSString * OCAStringFromSize(CGSize size) {
#if OCA_iOS
    return NSStringFromCGSize(size);
#else
    return NSStringFromSize(NSSizeFromCGSize(size));
#endif
}


CGSize OCASizeExtendBySize(CGSize a, CGSize b) {
    a.width += b.width;
    a.height += b.height;
    return a;
}


CGSize OCASizeShrinkBySize(CGSize a, CGSize b) {
    a.width -= b.width;
    a.height -= b.height;
    return a;
}


CGSize OCASizeMultiply(CGSize s, CGFloat m) {
    s.width *= m;
    s.height *= m;
    return s;
}


CGSize OCASizeRound(CGSize size, CGFloat scale) {
    size.width = OCAGeometryRound(size.width, scale);
    size.height = OCAGeometryRound(size.height, scale);
    return size;
}


CGSize OCASizeFloor(CGSize size, CGFloat scale) {
    size.width = OCAGeometryFloor(size.width, scale);
    size.height = OCAGeometryFloor(size.height, scale);
    return size;
}


CGSize OCASizeCeil(CGSize size, CGFloat scale) {
    size.width = OCAGeometryCeil(size.width, scale);
    size.height = OCAGeometryCeil(size.height, scale);
    return size;
}


CGSize OCASizeStandardize(CGSize size) {
    size.width = ABS(size.width);
    size.height = ABS(size.height);
    return size;
}


CGFloat OCASizeGetArea(CGSize size) {
    return (size.width * size.height);
}


CGFloat OCASizeGetRatio(CGSize size) {
    return (size.width / size.height);
}





#pragma mark -
#pragma mark Rectangle


CGRect OCARectFromString(NSString *string) {
#if OCA_iOS
    return CGRectFromString(string);
#else
    return NSRectToCGRect(NSRectFromString(string));
#endif
}


NSString * OCAStringFromRect(CGRect rect) {
#if OCA_iOS
    return NSStringFromCGRect(rect);
#else
    return NSStringFromRect(NSRectFromCGRect(rect));
#endif
}


CGRect OCARectRound(CGRect rect, CGFloat scale) {
    rect.origin = OCAPointRound(rect.origin, scale);
    rect.size = OCASizeRound(rect.size, scale);
    return rect;
}


CGRect OCARectCeil(CGRect rect, CGFloat scale) {
    rect.origin = OCAPointCeil(rect.origin, scale);
    rect.size = OCASizeCeil(rect.size, scale);
    return rect;
}


CGRect OCARectFloor(CGRect rect, CGFloat scale) {
    rect.origin = OCAPointFloor(rect.origin, scale);
    rect.size = OCASizeFloor(rect.size, scale);
    return rect;
}


CGPoint OCARectGetRelativePoint(CGRect rect, CGPoint relative) {
    CGPoint point;
    point.x = rect.origin.x + (rect.size.width * relative.x);
    point.y = rect.origin.y + (rect.size.height * relative.y);
    return point;
}


CGFloat OCARectGetEdge(CGRect rect, CGRectEdge edge) {
    CGFloat(*edgeFunction)(CGRect) = NULL;
    switch (edge) {
        case CGRectMinXEdge: edgeFunction = &CGRectGetMinX; break;
        case CGRectMaxXEdge: edgeFunction = &CGRectGetMaxX; break;
        case CGRectMinYEdge: edgeFunction = &CGRectGetMinY; break;
        case CGRectMaxYEdge: edgeFunction = &CGRectGetMaxY; break;
    }
    return edgeFunction(rect);
}





#if OCA_iOS


#pragma mark -
#pragma mark Edge Insets


UIEdgeInsets OCAEdgeInsetsAddEdgeInsets(UIEdgeInsets a, UIEdgeInsets b) {
    a.top += b.top;
    a.left += b.left;
    a.right += b.right;
    a.bottom += b.bottom;
    return a;
}


UIEdgeInsets OCAEdgeInsetsSubtractEdgeInsets(UIEdgeInsets a, UIEdgeInsets b) {
    a.top -= b.top;
    a.left -= b.left;
    a.right -= b.right;
    a.bottom -= b.bottom;
    return a;
}


UIEdgeInsets OCAEdgeInsetsMultiply(UIEdgeInsets insets, CGFloat multipler) {
    insets.top *= multipler;
    insets.left *= multipler;
    insets.right *= multipler;
    insets.bottom *= multipler;
    return insets;
}


UIEdgeInsets OCAEdgeInsetsRound(UIEdgeInsets insets, CGFloat scale) {
    insets.top = OCAGeometryRound(insets.top, scale);
    insets.left = OCAGeometryRound(insets.left, scale);
    insets.right = OCAGeometryRound(insets.right, scale);
    insets.bottom = OCAGeometryRound(insets.bottom, scale);
    return insets;
}


UIEdgeInsets OCAEdgeInsetsFloor(UIEdgeInsets insets, CGFloat scale) {
    insets.top = OCAGeometryFloor(insets.top, scale);
    insets.left = OCAGeometryFloor(insets.left, scale);
    insets.right = OCAGeometryFloor(insets.right, scale);
    insets.bottom = OCAGeometryFloor(insets.bottom, scale);
    return insets;
}


UIEdgeInsets OCAEdgeInsetsCeil(UIEdgeInsets insets, CGFloat scale) {
    insets.top = OCAGeometryCeil(insets.top, scale);
    insets.left = OCAGeometryCeil(insets.left, scale);
    insets.right = OCAGeometryCeil(insets.right, scale);
    insets.bottom = OCAGeometryCeil(insets.bottom, scale);
    return insets;
}

#endif


