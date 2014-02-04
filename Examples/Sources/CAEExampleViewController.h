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
+ (NSString *)exampleAuthor;
+ (NSDate *)exampleDate;

+ (NSDate *)day:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year;


#pragma mark Setup the Example

- (void)setupViews;
- (void)setupChains;


#pragma mark State Properties

@property (nonatomic, readonly, assign) BOOL partiallyVisible;
@property (nonatomic, readonly, assign) BOOL fullyVisible;



@end


