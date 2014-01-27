//
//  OCAGeometry+Base.h
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import <CoreGraphics/CGAffineTransform.h>

#import "OCAObject.h"

#if OCA_iOS
    #import <UIKit/UIGeometry.h>
    #import <UIKit/UIScreen.h> // For default rounding scale.
#endif

#import "OCAPredicate.h"
#import "OCATransformer.h"





@interface OCAGeometry : OCAObject

@end





extern CGFloat OCAGeometryDefaultScale(void);
extern CGFloat OCAGeometryRound(CGFloat value, CGFloat scale);
extern CGFloat OCAGeometryFloor(CGFloat value, CGFloat scale);
extern CGFloat OCAGeometryCeil(CGFloat value, CGFloat scale);


