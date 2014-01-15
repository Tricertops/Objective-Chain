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

    
    // Slider changes to property.
    [[self.slider producerForEvent:UIControlEventValueChanged]
     connectWithTransform:[OCATransformer access:OCAKeyPath(UISlider, value, float)]
     to:OCAProperty(self, temperature, float)];
    
    // Stepper changes to property.
    [[self.stepper producerForEvent:UIControlEventValueChanged]
     connectWithTransform:[OCATransformer access:OCAKeyPath(UIStepper, value, float)]
     to:OCAProperty(self, temperature, float)];
    
    // Property to Slider and Stepper.
    [OCAProperty(self, temperature, float)
     connectTo:[OCAMulticast multicast:
                @[ OCAProperty(self, slider.value, float),
                   OCAProperty(self, stepper.value, double) ]]];
    
    
    // Display formatted Temperature property.
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.minimumIntegerDigits = 1;
    formatter.minimumFractionDigits = 1;
    formatter.maximumFractionDigits = 1;
    formatter.positiveSuffix = @"°";
    formatter.negativeSuffix = @"°";
    
    [OCAProperty(self, temperature, float)
     connectWithTransform:[OCAFoundation stringWithNumberFormatter:formatter]
     to:OCAProperty(self, label.text, NSString)];
    
    
    // Disable Slider and Stepper with Switch.
    [[self.switcher producerForEvent:UIControlEventValueChanged]
     connectWithTransform:[OCATransformer access:OCAKeyPath(UISwitch, on, BOOL)]
     to:[OCAMulticast multicast:
            @[ OCAProperty(self, slider.enabled, BOOL),
               OCAProperty(self, stepper.enabled, BOOL) ]]];
    
    
    // Dimm tint color of Slider and Stepper when disabled.
    NSValueTransformer *mapEnabledToTintAdjustmentMode = [OCAFoundation map:@{ @YES: @(UIViewTintAdjustmentModeAutomatic),
                                                                               @NO:  @(UIViewTintAdjustmentModeDimmed) }];
    
    [OCAProperty(self, stepper.enabled, BOOL)
     connectWithTransform:mapEnabledToTintAdjustmentMode
     to:OCAProperty(self, stepper.tintAdjustmentMode, UIViewTintAdjustmentMode)];
    
    [OCAProperty(self, slider.enabled, BOOL)
     connectWithTransform:mapEnabledToTintAdjustmentMode
     to:OCAProperty(self, slider.tintAdjustmentMode, UIViewTintAdjustmentMode)];
}





@end


