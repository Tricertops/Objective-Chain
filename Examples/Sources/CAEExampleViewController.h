//
//  CAEExampleViewController.h
//  Chain Examples
//
//  Created by Martin Kiss on 14.1.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//





@interface CAEExampleViewController : UIViewController


+ (void)registerExample;
+ (NSArray *)allSubclasses;

+ (NSString *)exampleTitle;
+ (NSString *)exampleSubtitle;
+ (NSString *)exampleDescription;


@end


