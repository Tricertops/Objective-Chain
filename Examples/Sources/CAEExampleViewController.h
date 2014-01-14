//
//  CAEExampleViewController.h
//  Chain Examples
//
//  Created by Martin Kiss on 14.1.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//


#import "ObjectiveChain.h"





@interface CAEExampleViewController : UIViewController



#pragma mark Registering Subclasses

+ (void)registerExample;
+ (NSArray *)allSubclasses;


#pragma mark Getting Info about Examples

+ (NSString *)exampleTitle;
+ (NSString *)exampleSubtitle;
+ (NSString *)exampleDescription;


- (void)setupConnections;



@end


