//
//  CAEControlsExample.m
//  Chain Examples
//
//  Created by Martin Kiss on 14.1.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//

#import "CAEControlsExample.h"





@interface CAEControlsExample ()


@property (nonatomic, readwrite, strong) IBOutlet UILabel *label;
@property (nonatomic, readwrite, strong) IBOutlet UISlider *slider;
@property (nonatomic, readwrite, strong) IBOutlet UIStepper *stepper;
@property (nonatomic, readwrite, strong) IBOutlet UISwitch *switcher;

@property (nonatomic, readwrite, assign) float temperature;


@end










@implementation CAEControlsExample





#pragma mark Example Info & Registration


+ (void)load {
    [self registerExample];
}


+ (NSString *)exampleTitle {
    return @"Controls";
}


+ (NSString *)exampleSubtitle {
    return @"Handling target+action of various UI controls";
}


+ (NSString *)exampleDescription {
    return @"";
}


+ (NSString *)exampleAuthor {
    return @"iMartin Kiss";
}


+ (NSDate *)exampleDate {
    return [self day:14 month:1 year:2014];
}





#pragma mark Creating & Loading


- (void)setupConnections {
    [super setupConnections];

    [self.slider addTarget:self action:@selector(sliderDidChangeValue) forControlEvents:UIControlEventValueChanged];
    [self.stepper addTarget:self action:@selector(stepperDidChangeValue) forControlEvents:UIControlEventValueChanged];
    [self.switcher addTarget:self action:@selector(switcherDidChangeValue) forControlEvents:UIControlEventValueChanged];
    
    [OCAProperty(self, slider.value, float)
     bindWithTransform:[OCAMath roundTo:1]
     to:OCAProperty(self, temperature, float)];
    
    [OCAProperty(self, temperature, float)
     bindTo:OCAProperty(self, stepper.value, double)];
    
    [OCAProperty(self, temperature, float)
     connectWithTransform:[OCAFoundation formatString:@"%@°"]
     to:OCAProperty(self, label.text, NSString)];
    
    [OCAProperty(self, switcher.on, BOOL)
     connectTo:[OCAMulticast multicast:
                @[ OCAProperty(self, slider.enabled, BOOL),
                   OCAProperty(self, stepper.enabled, BOOL) ]]];
}


- (void)sliderDidChangeValue {
    // Fuck off UISlider, I want KVO events now!
    float value = self.slider.value;
    self.slider.value = 0;
    self.slider.value = value;
}


- (void)stepperDidChangeValue {
    // Fuck off UIStepper, I want KVO events now!
    float value = self.stepper.value;
    self.stepper.value = 0;
    self.stepper.value = value;
}

- (void)switcherDidChangeValue {
    // Fuck off UISwitch, I want KVO events now!
    BOOL value = self.switcher.on;
    self.switcher.on = !value;
    self.switcher.on = value;
}






@end


