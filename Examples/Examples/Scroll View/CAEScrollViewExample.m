//
//  CAEScrollViewExample.m
//  Chain Examples
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//

#import "CAEScrollViewExample.h"





@interface CAEScrollViewExample ()


@property (atomic, readwrite, strong) UIScrollView *scrollView;
@property (atomic, readwrite, strong) CAShapeLayer *lineLayer;
@property (atomic, readwrite, strong) CAShapeLayer *starLayer;
@property (atomic, readwrite, strong) CAShapeLayer *pentagramLayer;


@end










@implementation CAEScrollViewExample





#pragma mark Example Info & Registration


+ (void)load {
    [self registerExample];
}


+ (NSString *)exampleTitle {
    return @"Scroll View";
}


+ (NSString *)exampleSubtitle {
    return @"Geometric transforms to make paralax";
}


+ (NSString *)exampleDescription {
    return @"";
}


+ (NSString *)exampleAuthor {
    return @"iMartin Kiss";
}


+ (NSDate *)exampleDate {
    return [self day:15 month:1 year:2014];
}





#pragma mark Creating & Loading


- (void)setupViews {
    [super setupViews];
    
    CGSize screen = UIScreen.mainScreen.bounds.size;
    
    self.scrollView = ({
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        scrollView.contentSize = CGSizeMake(screen.width, screen.height * 5);
        
        [self.view addSubview:scrollView];
        scrollView;
    });
    
    self.lineLayer = ({
        CAShapeLayer *lineLayer = [[CAShapeLayer alloc] init];
        lineLayer.frame = CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
        lineLayer.lineDashPattern = @[ @30, @30 ];
        lineLayer.lineWidth = 4;
        lineLayer.strokeColor = [[UIColor blackColor] CGColor];
        
        lineLayer.path = ({
            UIBezierPath *linePath = [[UIBezierPath alloc] init];
            [linePath moveToPoint:CGPointMake(lineLayer.bounds.size.width / 2, 0)];
            [linePath addLineToPoint:CGPointMake(lineLayer.bounds.size.width / 2, lineLayer.bounds.size.height)];
            linePath.CGPath;
        });
        
        [self.scrollView.layer addSublayer:lineLayer];
        lineLayer;
    });
    
    self.starLayer = ({
        CAShapeLayer *starLayer = [[CAShapeLayer alloc] init];
        starLayer.bounds = CGRectMake(0, 0, 100, 100);
        starLayer.fillColor = [[UIColor darkGrayColor] CGColor];
        starLayer.position = CGPointMake(self.view.bounds.size.width / 4, self.view.bounds.size.height / 2);
        
        starLayer.path = ({
            // Generated using PaintCode
            UIBezierPath* starPath = [UIBezierPath bezierPath];
            [starPath moveToPoint: CGPointMake(50, 0)];
            [starPath addLineToPoint: CGPointMake(59.52, 27)];
            [starPath addLineToPoint: CGPointMake(85.36, 14.64)];
            [starPath addLineToPoint: CGPointMake(73, 40.48)];
            [starPath addLineToPoint: CGPointMake(100, 50)];
            [starPath addLineToPoint: CGPointMake(73, 59.52)];
            [starPath addLineToPoint: CGPointMake(85.36, 85.36)];
            [starPath addLineToPoint: CGPointMake(59.52, 73)];
            [starPath addLineToPoint: CGPointMake(50, 100)];
            [starPath addLineToPoint: CGPointMake(40.48, 73)];
            [starPath addLineToPoint: CGPointMake(14.64, 85.36)];
            [starPath addLineToPoint: CGPointMake(27, 59.52)];
            [starPath addLineToPoint: CGPointMake(0, 50)];
            [starPath addLineToPoint: CGPointMake(27, 40.48)];
            [starPath addLineToPoint: CGPointMake(14.64, 14.64)];
            [starPath addLineToPoint: CGPointMake(40.48, 27)];
            [starPath closePath];
            starPath.CGPath;
        });
        
        starLayer.shadowColor = [[UIColor blackColor] CGColor];
        starLayer.shadowOffset = CGSizeMake(0, 20);
        starLayer.shadowOpacity = 0.25;
        starLayer.shadowPath = starLayer.path;
        starLayer.shadowRadius = 3;
        
        [self.view.layer addSublayer:starLayer];
        starLayer;
    });
    
    self.pentagramLayer = ({
        CAShapeLayer *pentagramLayer = [[CAShapeLayer alloc] init];
        pentagramLayer.fillColor = [[UIColor darkGrayColor] CGColor];
        pentagramLayer.bounds = CGRectMake(0, 0, 100, 100);
        pentagramLayer.position = CGPointMake(self.view.bounds.size.width / 4 * 3, self.view.bounds.size.height / 2);
        
        pentagramLayer.path = ({
            // Generated using PaintCode
            UIBezierPath* pentagramPath = [[UIBezierPath alloc] init];
            [pentagramPath moveToPoint: CGPointMake(50, 0)];
            [pentagramPath addLineToPoint: CGPointMake(97.55, 34.55)];
            [pentagramPath addLineToPoint: CGPointMake(79.39, 90.45)];
            [pentagramPath addLineToPoint: CGPointMake(20.61, 90.45)];
            [pentagramPath addLineToPoint: CGPointMake(2.45, 34.55)];
            [pentagramPath closePath];
            pentagramPath.CGPath;
        });
        
        pentagramLayer.shadowColor = [[UIColor blackColor] CGColor];
        pentagramLayer.shadowOffset = CGSizeMake(0, 1);
        pentagramLayer.shadowOpacity = 0.25;
        pentagramLayer.shadowPath = pentagramLayer.path;
        pentagramLayer.shadowRadius = 3;
        
        [self.view.layer addSublayer:pentagramLayer];
        pentagramLayer;
    });
    
}


- (void)setupConnections {
    [super setupConnections];
    
    [OCAProperty(self.view, tintColor, UIColor)
     transform:[OCAUIKit colorGetCGColor]
     connectTo:[OCAMulticast multicast:
                @[ OCAProperty(self.starLayer, fillColor, NSObject),
                   OCAProperty(self.pentagramLayer, fillColor, NSObject) ]]];
    
    OCAProducer *starRotation = [[OCAPropertyStruct(self.scrollView, contentOffset, y)
                                  contextualize:[OCAContext disableImplicitAnimations]]
                                 bridgeWithTransform:[OCAMath divideBy: - self.starLayer.bounds.size.width]];
    
    [starRotation
     transform:[OCAGeometry transform3DFromZRotation]
     connectTo:OCAProperty(self.starLayer, transform, CATransform3D)];
    
    [starRotation
     transform:[OCATransformer sequence:@[
                                          [OCAFoundation branchArray:@[
                                                                       [OCAMath sine],
                                                                       [OCAMath cosine]
                                                                       ]],
                                          [OCAGeometry makeSize],
                                          [OCAGeometry multiplySizeBy:20]
                                          ]]
     connectTo:OCAProperty(self.starLayer, shadowOffset, CGSize)];
    
    
    NSValueTransformer *scrollProgressFromContentOffset = [OCAMath transform:
                                                           ^OCAReal(OCAReal offset) {
                                                               CGFloat realOffset = offset + self.scrollView.contentInset.top;
                                                               CGFloat maxOffset = (self.scrollView.contentSize.height
                                                                                    - self.scrollView.bounds.size.height
                                                                                    + self.scrollView.contentInset.top);
                                                               return realOffset / maxOffset;
                                                           }];
    OCAProducer *paralax = [OCAPropertyStruct(self.scrollView, contentOffset, y)
                            bridgeWithTransform:[OCATransformer sequence:
                                                 @[ scrollProgressFromContentOffset,
                                                    [OCAMath subtract:0.5],
                                                    [OCAMath multiplyBy:-2],
                                                    // From -1 to 1
                                                    ]]];
    
    [[paralax contextualize:[OCAContext disableImplicitAnimations]]
     transform:[OCATransformer sequence:
                @[ [OCAMath multiplyBy:100],
                   [OCAMath add:self.view.bounds.size.height / 2], ]]
     connectTo:OCAPropertyStruct(self.pentagramLayer, position, y)];
    
    [[paralax contextualize:[OCAContext disableImplicitAnimations]]
     transform:[OCAMath multiplyBy:20]
     connectTo:OCAPropertyStruct(self.pentagramLayer, shadowOffset, height)];
    
}





@end


