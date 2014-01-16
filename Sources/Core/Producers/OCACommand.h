//
//  OCACommand.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"





/// Command is a Producer, that allows explicit sending of values.
@interface OCACommand : OCAProducer



#pragma mark Creating Command

- (instancetype)initWithValueClass:(Class)valueClass;

+ (instancetype)class:(Class)valueClass;


#pragma mark Using Command

- (void)sendValue:(id)value;
- (void)sendValues:(NSArray *)values;
- (void)finishWithError:(NSError *)error;



@end


