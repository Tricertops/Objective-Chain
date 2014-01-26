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


- (void)setupConnections {
    [super setupConnections];
    
    
    //TODO: Connections not deallocating.
    
    
    // Connect Slider changes to temperature property.
    [[self.slider producerForEvent:UIControlEventValueChanged] // Sends the sender: UISlider instance
     transform:[OCATransformer access:OCAKeyPath(UISlider, value, float)] // Get `value` property of sender.
     connectTo:OCAProperty(self, temperature, float)];
    
    // Connect Stepper changes to temperature property.
    [[self.stepper producerForEvent:UIControlEventValueChanged] // Sends the sender: UIStepper instance
     transform:[OCATransformer access:OCAKeyPath(UIStepper, value, float)]
     connectTo:OCAProperty(self, temperature, float)];
    
    // Connect temperature property back to Slider and Stepper. Now we have two-way binding.
    [OCAProperty(self, temperature, float)
     connectTo:[OCAMulticast multicast: // Simply group two Consumers into one.
                @[ OCAProperty(self, slider.value, float),
                   OCAProperty(self, stepper.value, double) ]]];
    
    
    
    // Display formatted temperature property.
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.minimumIntegerDigits = 1;
    formatter.minimumFractionDigits = 1;
    formatter.maximumFractionDigits = 1;
    formatter.positiveSuffix = @"°";
    formatter.negativeSuffix = @"°";
    
    [OCAProperty(self, temperature, float)
     transform:[OCAFoundation stringWithNumberFormatter:formatter]
     connectTo:OCAProperty(self, label.text, NSString)];
    
    
    
    // Disable Slider and Stepper when Switch is off.
    [[self.switcher producerForEvent:UIControlEventValueChanged] // Sends the sender: UISwith instance
     transform:[OCATransformer access:OCAKeyPath(UISwitch, on, BOOL)]
     connectTo:[OCAMulticast multicast:
                @[ OCAProperty(self, slider.enabled, BOOL),
                   OCAProperty(self, stepper.enabled, BOOL) ]]];
    
    
    // Simple mapping transformer from BOOL to enum.
    NSValueTransformer *mapEnabledToTintAdjustmentMode = [OCAFoundation map:@{ @YES: @(UIViewTintAdjustmentModeAutomatic),
                                                                               @NO:  @(UIViewTintAdjustmentModeDimmed) }];
    
    // Dim tint color of Stepper when disabled.
    [OCAProperty(self, stepper.enabled, BOOL)
     transform:mapEnabledToTintAdjustmentMode
     connectTo:OCAProperty(self, stepper.tintAdjustmentMode, UIViewTintAdjustmentMode)];
    
    // Dim tint color of Stepper when disabled.
    [OCAProperty(self, slider.enabled, BOOL)
     transform:mapEnabledToTintAdjustmentMode
     connectTo:OCAProperty(self, slider.tintAdjustmentMode, UIViewTintAdjustmentMode)];
    
    
    
}





@end


