//
//  CAEThrottledExample.m
//  Chain Examples
//
//  Created by Martin Kiss on 10.3.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//

#import "CAEThrottledExample.h"





@interface CAEThrottledExample ()



@property (nonatomic, readwrite, assign) NSUInteger integer;
@property (nonatomic, readwrite, strong) UILabel *label;
@property (nonatomic, readwrite, strong) UISlider *slider;



@end










@implementation CAEThrottledExample





#pragma mark Example Info & Registration


+ (void)load {
    [self registerExample];
}


+ (NSString *)exampleTitle {
    return @"Throttled";
}


+ (NSString *)exampleSubtitle {
    return @"Limiting frequency of events";
}


+ (NSString *)exampleDescription {
    return @"This example uses Throttling mechanism to limit how often is value from Slider applied. It then animates the changed value by interpolating from previous to the current. Total of 2 chains";
}


+ (NSString *)exampleAuthor {
    return @"iMartin Kiss";
}


+ (NSDate *)exampleDate {
    return [self day:10 month:3 year:2014];
}





#pragma mark Setup


- (void)setupViews {
    [super setupViews];
    
    self.label = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:90];
        label.backgroundColor = [UIColor clearColor];
        label.frame = CGRectMake(20, 64+40, 280, label.font.pointSize);
        label.text = @"1000";
        label.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:label];
        label;
    });
    
    self.slider = ({
        UISlider *slider = [[UISlider alloc] init];
        slider.frame = CGRectMake(20, CGRectGetMaxY(self.label.frame) + 60, 280, 44);
        slider.minimumValue = 0;
        slider.maximumValue = 100;
        
        [self.view addSubview:slider];
        slider;
    });
    
}


- (void)setupChains {
    [super setupChains];
    OCAWeakify(self);
    
    __block __weak OCAInterpolator *interpolator = nil; // Weak, because it will deallocate automatically once finished.
    [[OCAProperty(self, integer, NSUInteger) produceChanges]
     subscribeForClass:[OCAKeyValueChangeSetting class] handler:^(OCAKeyValueChangeSetting *change) {
         OCAStrongify(self);
         
         [interpolator finishWithLastValue:YES]; // Will stop and display final value.
         
         NSUInteger previous = [change.previousValue unsignedIntegerValue];
         NSUInteger latest = [change.latestValue unsignedIntegerValue];
         interpolator = [OCAInterpolator interpolatorWithDuration:0.5
                                                        frequency:30
                                                        fromValue:previous
                                                          toValue:latest];
         
         [[interpolator transformValues:
           [OCATransformer stringWithNumberStyle:NSNumberFormatterDecimalStyle fractionDigits:0],
           nil] connectTo:OCAProperty(self, label.text, NSString)];
     }];
    
    [[[self.slider producerForValue]
      throttleContinuous:1] // Sends latest value every 1 second
     connectTo:OCAProperty(self, integer, NSUInteger)];
}





@end


