//
//  OCASwitch.h
//  Objective-Chain
//
//  Created by Martin Kiss on 4.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAConsumer.h"





@interface OCASwitch : OCAObject <OCAConsumer>


- (instancetype)initWithDictionary:(NSDictionary *)consumersByPredicates;

+ (OCASwitch *)switchYes:(id<OCAConsumer>)consumer no:(id<OCAConsumer>)consumer;
+ (OCASwitch *)switchIf:(NSPredicate *)predicate then:(id<OCAConsumer>)consumer else:(id<OCAConsumer>)consumer;

@property (atomic, readonly, strong) NSDictionary *consumersByPredicates;
@property (atomic, readonly, strong) Class consumedValueClass;


@end


