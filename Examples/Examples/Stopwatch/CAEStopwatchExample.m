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
    return @"Timer with date transforms";
}


+ (NSString *)exampleDescription {
    return @"";
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


- (void)setupConnections {
    [super setupConnections];
    OCAWeakify(self);
    
    
    [[self.startButton producerForEvent:UIControlEventTouchUpInside]
     subscribeEvents:^{
         OCAStrongify(self);
         
         if (self.timer.isRunning) {
             [self.timer stop];
             self.timer = nil;
         }
         else {
             self.timer = [OCATimer repeat:0.01 owner:self];
             
             [self.timer subscribeEvents:^{
                 OCAStrongify(self);
                 self.interval += self.timer.interval * 10;
              }];
         }
     }];
    
    
    [OCAProperty(self, timer.isRunning, BOOL)
     transform:[OCATransformer yes:@"Stop" no:@"Start"]
     connectTo:[OCAUIKit setTitleOfButton:self.startButton
                          forControlState:UIControlStateNormal]];
    
    
    [OCAProperty(self, interval, NSTimeInterval)
     transform:[self transformerFromIntervalToString]
     connectTo:OCAProperty(self.label, text, NSString)];
    
    [OCAProperty(self, interval, NSTimeInterval)
     transform:[OCATransformer sequence:@[
                                          [OCAMath modulus:60],
                                          [OCAMath divideBy:60],
                                          ]]
     connectTo:OCAProperty(self, clockProgress, CGFloat)];
    
    [OCAPropertyChange(self, clockProgress, CGFloat)
     transform:[OCATransformer sequence:@[
                                          [OCATransformer sideEffect:
                                           ^(NSArray *change) {
                                               OCAStrongify(self);
                                               CGFloat old = [change.first doubleValue];
                                               CGFloat new = [change.second doubleValue];
                                               
                                               if (old > new) {
                                                   [self makeNewClockLayer];
                                               }
                                           }],
                                          [OCAFoundation objectAtIndex:1],
                                          [self transformerFromProgressToCirclePath],
                                          ]]
     connectTo:OCAProperty(self, clockLayer.path, NSObject)];
    
}


- (NSValueTransformer *)transformerFromIntervalToString {
    return [OCATransformer fromClass:[NSNumber class] toClass:[NSString class]
                    asymetric:^NSString *(NSNumber *intervalNumber) {
                        NSTimeInterval time = intervalNumber.doubleValue;
                        
                        NSUInteger hours = floor(time / 3600);
                        time -= hours * 3600;
                        NSUInteger minutes = floor(time / 60);
                        time -= minutes * 60;
                        NSUInteger seconds = floor(time);
                        time -= seconds;
                        NSUInteger fractions = floor(time * 100);
                        
                        if (hours) return [NSString stringWithFormat:@"%lu:%02lu:%02lu.%02lu", hours, minutes, seconds, fractions];
                        else if (minutes) return [NSString stringWithFormat:@"%lu:%02lu.%02lu", minutes, seconds, fractions];
                        else return [NSString stringWithFormat:@"%lu.%02lu", seconds, fractions];
                    }];
}


- (void)makeNewClockLayer {
    CAShapeLayer *oldClockLayer = self.clockLayer;
    oldClockLayer.path = (__bridge CGPathRef)[[self transformerFromProgressToCirclePath] transformedValue:@1];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:OCAKP(CALayer, opacity)];
    animation.duration = 12;
    animation.fromValue = @1;
    animation.toValue = @0;
    animation.fillMode = kCAFillModeBoth;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.delegate = self;
    oldClockLayer.opacity = 0;
    [oldClockLayer addAnimation:animation forKey:animation.keyPath];
    
    CAShapeLayer *clockLayer = [[CAShapeLayer alloc] init];
    clockLayer.frame = CGRectMake(20, 84, 280, 280);
    clockLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
    clockLayer.fillColor = [[self.view.tintColor colorWithAlphaComponent:0.25] CGColor];
    [self.view.layer insertSublayer:clockLayer above:self.clockLayer];
    self.clockLayer = clockLayer;
}


- (NSValueTransformer *)transformerFromProgressToCirclePath {
    return [OCATransformer fromClass:[NSNumber class] toClass:nil
                           asymetric:^id(NSNumber *progressNumber) {
                               NSTimeInterval progress = progressNumber.doubleValue;
                               
                               CGFloat outerRadius = 140;
                               CGFloat innerRadius = 110;
                               CGFloat degrees = progress * 360;
                               
                               CGPoint center = CGPointMake(outerRadius, outerRadius);
                               UIBezierPath* path = [UIBezierPath bezierPath];
                               [path addArcWithCenter:center
                                               radius:outerRadius
                                           startAngle:0
                                             endAngle:degrees * M_PI/180
                                            clockwise:YES];
                               
                               CGPoint vector = OCAPointSubtractPoint(path.currentPoint, center);
                               vector = OCAPointMultiply(vector, innerRadius / outerRadius);
                               [path addLineToPoint:OCAPointAddPoint(center, vector)];
                               
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


