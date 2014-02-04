//
//  CAEStopwatchExample.m
//  Chain Examples
//
//  Created by Martin Kiss on 17.1.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//

#import "CAEStopwatchExample.h"





@interface CAEStopwatchExample ()


@property (nonatomic, readwrite, strong) OCATimer *timer;

@property (nonatomic, readwrite, assign) NSTimeInterval interval;
@property (nonatomic, readwrite, assign) CGFloat clockProgress;

@property (nonatomic, readwrite, strong) UILabel *label;
@property (nonatomic, readwrite, strong) CAShapeLayer *clockLayer;
@property (nonatomic, readwrite, strong) UIButton *startButton;



@end










@implementation CAEStopwatchExample





#pragma mark Example Info & Registration


+ (void)load {
    [self registerExample];
}


+ (NSString *)exampleTitle {
    return @"Stopwatch";
}


+ (NSString *)exampleSubtitle {
    return @"Uses button to control Timer";
}


+ (NSString *)exampleDescription {
    return @"This example uses Timer object, calculates elapsed time, and displays it as formatted text and as a circular progress. Total of 6 chains.";
}


+ (NSString *)exampleAuthor {
    return @"iMartin Kiss";
}


+ (NSDate *)exampleDate {
    return [self day:17 month:1 year:2014];
}





#pragma mark Setup


- (void)setupViews {
    [super setupViews];
    
    [self makeNewClockLayer];
    
    self.label = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:80];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        
        label.frame = UIEdgeInsetsInsetRect(self.clockLayer.frame, UIEdgeInsetsMake(40, 40, 40, 40));
        [self.view addSubview:label];
        label;
    });
    
    CGFloat buttonSize = 100;
    CGFloat buttonPadding = (self.view.bounds.size.width - 2 * buttonSize) / 3;
    CGFloat buttonPosition = CGRectGetMaxY(self.clockLayer.frame) + 30;
    
    self.startButton = ({
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(buttonPadding, buttonPosition, buttonSize, buttonSize);
        button.layer.borderWidth = 5;
        button.layer.borderColor = [[self.view.tintColor colorWithAlphaComponent:0.5] CGColor];
        button.layer.cornerRadius = buttonSize / 2;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:26];
        
        [self.view addSubview:button];
        button;
    });
    
}


- (void)setupChains {
    [super setupChains];
    OCAWeakify(self);
    
    
    /// Make the button start and stop the timer instance.
    [[self.startButton producerForEvent:UIControlEventTouchUpInside]
     subscribe:^{
         OCAStrongify(self);
         
         if (self.timer.isRunning) {
             [self.timer stop];
             self.timer = nil;
         }
         else {
             /// Create and subscribe to the Timer.
             self.timer = [OCATimer timerWithInterval:0.01 owner:self];
             [self.timer subscribe:^{
                 OCAStrongify(self);
                 self.interval += self.timer.interval;
             }];
         }
     }];
    
    /// Update button based on Timer's state.
    [[OCAProperty(self, timer.isRunning, BOOL) transformValues:
      [OCATransformer ifYes:@"Stop" ifNo:@"Start"],
      nil] connectTo:[OCAUIKit setTitleOfButton:self.startButton
                                forControlState:UIControlStateNormal]];
    
    
    /// Update label's text using custom transformer.
    [[OCAProperty(self, interval, NSTimeInterval) transformValues:
      [self transformerFromIntervalToString],
      nil] connectTo:OCAProperty(self.label, text, NSString)];
    
    /// Calculate clock's progress.
    [[OCAProperty(self, interval, NSTimeInterval) transformValues:
      [OCAMath modulus:60],
      [OCAMath divideBy:60],
      nil] connectTo:OCAProperty(self, clockProgress, CGFloat)];
    
    /// Use clock progress to create the shape and assign it to the layer.
    [[[[OCAProperty(self, clockProgress, CGFloat) producePreviousWithLatest]
       produceInContext:[OCAContext disableImplicitAnimations]] transformValues:
      /// But before, check whether we made full circle (progress from 1 to 0) and create new layer on top.
      [OCATransformer sideEffect:^(NSArray *change) {
           OCAStrongify(self);
           CGFloat old = [[change oca_valueAtIndex:0] doubleValue];
           CGFloat new = [[change oca_valueAtIndex:1] doubleValue];
           
           if (old > new) {
               [self makeNewClockLayer];
           }
       }],
      [OCATransformer objectAtIndex:1], // Current value is second in the array.
      [self transformerFromProgressToCirclePath],
      nil] connectTo:OCAProperty(self, clockLayer.path, NSObject)];
    
}


- (NSValueTransformer *)transformerFromIntervalToString {
    return [OCATransformer fromClass:[NSNumber class] toClass:[NSString class]
                           asymetric:^NSString *(NSNumber *intervalNumber) {
                               NSTimeInterval time = intervalNumber.doubleValue;
                               
                               long hours = floor(time / 3600);
                               time -= hours * 3600;
                               long minutes = floor(time / 60);
                               time -= minutes * 60;
                               long seconds = floor(time);
                               time -= seconds;
                               long fractions = floor(time * 100);
                               
                               if (hours) return [NSString stringWithFormat:@"%lu:%02lu:%02lu.%02lu", hours, minutes, seconds, fractions];
                               else if (minutes) return [NSString stringWithFormat:@"%lu:%02lu.%02lu", minutes, seconds, fractions];
                               else return [NSString stringWithFormat:@"%lu.%02lu", seconds, fractions];
                           }];
}


- (void)makeNewClockLayer {
    CAShapeLayer *oldClockLayer = self.clockLayer;
    // Finish the circle, so there is no gap as it sometimes used to be.
    oldClockLayer.path = (__bridge CGPathRef)[[self transformerFromProgressToCirclePath] transformedValue:@1];
    {
        /// Animate the previous circle for two minutes. This creates an effect, that new circles are darker, but after two rounds they fade slowly back to original opacity, so they never get too dark.
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:OCAKP(CALayer, opacity)];
        animation.duration = 120;
        animation.fromValue = @1;
        animation.toValue = @0;
        animation.fillMode = kCAFillModeBoth;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        oldClockLayer.opacity = 0;
        [oldClockLayer addAnimation:animation forKey:animation.keyPath];
        //TODO: I should remove the layers from hierarchy.
    }
    
    /// Create new clock layer.
    CAShapeLayer *clockLayer = [[CAShapeLayer alloc] init];
    clockLayer.frame = CGRectMake(20, 84, 280, 280);
    clockLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1); // Rotate, so 0 angle is up.
    clockLayer.fillColor = [[self.view.tintColor colorWithAlphaComponent:0.25] CGColor]; // Alpha 0.25, so they multiply.
    [self.view.layer insertSublayer:clockLayer above:self.clockLayer];
    self.clockLayer = clockLayer;
}


- (NSValueTransformer *)transformerFromProgressToCirclePath {
    return [OCATransformer fromClass:[NSNumber class] toClass:nil
                           asymetric:^id(NSNumber *progressNumber) {
                               
                               /// Creates path to be used in the clock layer.
                               NSTimeInterval progress = progressNumber.doubleValue;
                               
                               CGFloat outerRadius = 140;
                               CGFloat innerRadius = 110;
                               CGPoint center = CGPointMake(outerRadius, outerRadius);
                               CGFloat degrees = progress * 360;
                               UIBezierPath* path = [UIBezierPath bezierPath];
                               
                               // Outer arc.
                               [path addArcWithCenter:center
                                               radius:outerRadius
                                           startAngle:0
                                             endAngle:degrees * M_PI/180
                                            clockwise:YES];
                               
                               // Line with direction to the center, but only 30 points in length.
                               CGPoint vector = OCAPointSubtractPoint(path.currentPoint, center);
                               vector = OCAPointMultiply(vector, innerRadius / outerRadius);
                               [path addLineToPoint:OCAPointAddPoint(center, vector)];
                               
                               // Inner arc
                               [path addArcWithCenter:center
                                               radius:innerRadius
                                           startAngle:degrees * M_PI/180
                                             endAngle:0
                                            clockwise:NO];
                               
                               [path closePath];
                               return (id)path.CGPath;
                           }];
}





@end


