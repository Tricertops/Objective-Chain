//
//  OCAGeometry+Base.m
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAGeometry+Base.h"
#import "OCAMath.h"










@implementation OCAGeometry

@end










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


