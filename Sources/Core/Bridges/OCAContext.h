//
//  OCAContext.h
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCABridge.h"
#import "OCAProperty.h"



typedef void(^OCAContextExecutionBlock)(void);
typedef void(^OCAContextDefinitionBlock)(OCAContextExecutionBlock executionBlock);





@interface OCAContext : OCABridge



#pragma mark Creating Context

- (instancetype)initWithValueClass:(Class)valueClass definitionBlock:(OCAContextDefinitionBlock)definitionBlock;

+ (OCAContext *)empty;
+ (OCAContext *)custom:(OCAContextDefinitionBlock)block;
+ (OCAContext *)property:(OCAProperty *)property value:(id)value;


#pragma mark Using Context

- (void)execute:(OCAContextExecutionBlock)executionBlock;


#pragma mark Context as a Consumer

- (void)consumeValue:(id)value;
- (void)finishConsumingWithError:(NSError *)error;



@end




@interface OCAProducer (OCAContext)


- (OCABridge *)contextualize:(OCAContext *)context;


@end


