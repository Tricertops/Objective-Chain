//
//  OCAContext.h
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMediator.h"
#import "OCAProperty.h"
#import "OCAQueue.h"



typedef void(^OCAContextExecutionBlock)(void);
typedef void(^OCAContextDefinitionBlock)(OCAContextExecutionBlock executionBlock);
extern OCAContextDefinitionBlock const OCAContextDefaultDefinitionBlock;





@interface OCAContext : OCAMediator



#pragma mark Creating Context

- (instancetype)initWithDefinitionBlock:(OCAContextDefinitionBlock)definitionBlock;

+ (OCAContext *)empty;
+ (OCAContext *)custom:(OCAContextDefinitionBlock)block;
+ (OCAContext *)property:(OCAProperty *)property value:(id)value;
+ (OCAContext *)onQueue:(OCAQueue *)queue synchronous:(BOOL)synchronous;


#pragma mark Using Context

- (void)execute:(OCAContextExecutionBlock)executionBlock;


#pragma mark Context as a Consumer

- (void)consumeValue:(id)value;
- (void)finishConsumingWithError:(NSError *)error;



@end





@interface OCAProducer (OCAContext)


- (OCAContext *)produceInContext:(OCAContext *)context CONVENIENCE;
- (OCAContext *)produceInContextBlock:(OCAContextDefinitionBlock)contextBlock CONVENIENCE;
- (OCAContext *)produceOnQueue:(OCAQueue *)queue CONVENIENCE;
//TODO: Methods for specific instances.


@end


