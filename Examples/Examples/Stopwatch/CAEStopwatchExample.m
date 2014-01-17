//
//  CAEStopwatchExample.m
//  Chain Examples
//
//  Created by Martin Kiss on 17.1.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//

#import "CAEStopwatchExample.h"





@interface CAEStopwatchExample ()

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
}


- (void)setupConnections {
    [super setupConnections];
    
    
    
}





@end


