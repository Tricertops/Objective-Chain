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





#pragma mark Creating & Loading


- (void)setupConnections {
    [super setupConnections];
    
    [self.slider addTarget:self action:@selector(sliderDidChangeValue) forControlEvents:UIControlEventValueChanged];
    
    [OCAProperty(self, slider.value, float)
     connectWithTransform:[OCATransformer sequence:@[ [OCATransformer debugPrintWithMarker:@"Slider"],
                                                      [OCAMath roundTo:1],
                                                      [OCAFoundation formatString:@"%@°"] ]]
     to:OCAProperty(self, label.text, NSString)];
    
}


- (void)sliderDidChangeValue {
    // Fuck off UISlider, I want KVO events now!
    float value = self.slider.value;
    self.slider.value = 0;
    self.slider.value = value;
}








@end


