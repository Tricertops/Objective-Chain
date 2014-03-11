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
    return @"This example uses UIControl event Producers to update internal property, that is subsequently displayed in a form of temperature label. Also allows you to disable these controls with custom tint color dimming. Total of 7 connections.";
}


+ (NSString *)exampleAuthor {
    return @"iMartin Kiss";
}


+ (NSDate *)exampleDate {
    return [self day:14 month:1 year:2014];
}





#pragma mark Creating & Loading


- (void)setupChains {
    [super setupChains];
    
    
    // Connect Slider changes to temperature property.
    [[self.slider producerForValue] connectTo:OCAProperty(self, temperature, float)];
    
    // Connect Stepper changes to temperature property.
    [[self.stepper producerForValue] connectTo:OCAProperty(self, temperature, float)];
    
    // Connect temperature property back to Slider and Stepper. Now we have two-way binding.
    [OCAProperty(self, temperature, float)
     connectToMany:
     OCAProperty(self, slider.value, float),
     OCAProperty(self, stepper.value, double),
     nil];
    
    
    
    // Display formatted temperature property.
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.minimumIntegerDigits = 1;
    formatter.minimumFractionDigits = 1;
    formatter.maximumFractionDigits = 1;
    formatter.positiveSuffix = @"°";
    formatter.negativeSuffix = @"°";
    
    [[OCAProperty(self, temperature, float) transformValues:
      [OCATransformer stringWithNumberFormatter:formatter],
      nil] connectTo:OCAProperty(self, label.text, NSString)];
    
    
    
    // Disable Slider and Stepper when Switch is off.
    [[[self.switcher producerForEvent:UIControlEventValueChanged] transformValues:
      [OCATransformer access:OCAKeyPath(UISwitch, on, BOOL)],
      nil] connectToMany:
     OCAProperty(self, slider.enabled, BOOL),
     OCAProperty(self, stepper.enabled, BOOL),
     nil];
    
    
    // Simple mapping transformer from BOOL to enum.
    NSValueTransformer *mapEnabledToTintAdjustmentMode = [OCATransformer ifYes:@(UIViewTintAdjustmentModeAutomatic)
                                                                          ifNo:@(UIViewTintAdjustmentModeDimmed)];
    
    // Dim tint color of Stepper when disabled.
    [[OCAProperty(self, stepper.enabled, BOOL) transformValues:
      mapEnabledToTintAdjustmentMode,
      nil] connectTo:OCAProperty(self, stepper.tintAdjustmentMode, UIViewTintAdjustmentMode)];
    
    // Dim tint color of Stepper when disabled.
    [[OCAProperty(self, slider.enabled, BOOL)transformValues:
      mapEnabledToTintAdjustmentMode,
      nil] connectTo:OCAProperty(self, slider.tintAdjustmentMode, UIViewTintAdjustmentMode)];
    
    
    
}





@end


