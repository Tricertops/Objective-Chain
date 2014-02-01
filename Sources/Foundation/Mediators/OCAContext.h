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





/*! This class represents “a context”, that acts as a Consumer and a Producer. Received values are passed to Consumers in a known context.
 *  “Context” for the purpose of this class means, that some code is executed before and after the main task.
 *  Good example is use of NSLock (via +lock: constructor). When the Context object receives a value, it locks the Lock, passes the value to Consumers and then unlocks the Lock. This means, that the Consumers are invoked in a known “context”.
 *  You can use one of the provided constructors or define your own using simple block.
 *
 *  NOTE: Since this class is quite abstract, it allows you to do anything in the definition block. For thing like filtering, transformations or delaying the production of values, use appropriate Mediator subclasses. Don't abuse this Context.
 */
@interface OCAContext : OCAMediator



#pragma mark Creating Context

//! Designated initializer. Definition block receives execution block that must be invoked. Execute desired code before and after the execution block as you wish. You may even nest the execution block into other block, for example for animations or queues.
- (instancetype)initWithDefinitionBlock:(OCAContextDefinitionBlock)definitionBlock;

//! Returns a Context that does nothing extra.
+ (OCAContext *)empty;

//! Shorthand for designated initializer.
+ (OCAContext *)custom:(OCAContextDefinitionBlock)block;

//! Returns a Context, that sets given value to the property, then produces consumed value and reverts the proeprty to previous value. For example, you may have a flag to supress observations of a notification, so you may want to set the flag to YES while sending it.
+ (OCAContext *)property:(OCAProperty *)property value:(id)value;

//! Returns a Context, that produces consumed values on provided queue.
+ (OCAContext *)onQueue:(OCAQueue *)queue synchronous:(BOOL)synchronous;

//! Returns a Context, that lock and unlocks provided NSLocking object. This means all chained Consumers are executed inside of locked context.
+ (OCAContext *)lock:(id<NSLocking>)lock;

//! Returns a Context, that uses @synchronized directive to produce values.
+ (OCAContext *)synchronized:(id)object;

//! Returns a Context, that produces consumed values in auto-release pool.
+ (OCAContext *)autoreleasepool;



#pragma mark Using Context

//! Definition block as passed to the designated initializer.
@property (atomic, readonly, strong) OCAContextDefinitionBlock definitionBlock;

//! You can use this method to execute arbitrary code inside of the context represented by the receiver.
- (void)execute:(OCAContextExecutionBlock)executionBlock;



@end


