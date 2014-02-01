//
//  OCAContext.m
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAContext.h"
#import "OCAProducer+Subclass.h"





OCAContextDefinitionBlock const OCAContextDefaultDefinitionBlock = ^(OCAContextExecutionBlock executionBlock){
    executionBlock();
};










@implementation OCAContext





#pragma mark Creating Context


- (instancetype)initWithValueClass:(Class)valueClass {
    return [self initWithDefinitionBlock:nil];
}


- (instancetype)initWithDefinitionBlock:(OCAContextDefinitionBlock)definitionBlock {
    self = [super initWithValueClass:nil];
    if (self) {
        self->_definitionBlock = definitionBlock ?: OCAContextDefaultDefinitionBlock;
    }
    return self;
}


+ (OCAContext *)empty {
    return [[self alloc] initWithDefinitionBlock:nil];
}


+ (OCAContext *)custom:(OCAContextDefinitionBlock)block {
    return [[self alloc] initWithDefinitionBlock:block];
}


+ (OCAContext *)property:(OCAProperty *)property value:(id)value {
    return [[self alloc] initWithDefinitionBlock:^(OCAContextExecutionBlock executionBlock) {
        id originalValue = [property value];
        [property setValue:value];
        
        executionBlock(); // Block is executed when the property has desired value.
        
        [property setValue:originalValue];
    }];
}


+ (OCAContext *)onQueue:(OCAQueue *)queue synchronous:(BOOL)synchronous {
    if (synchronous) {
        return [[self alloc] initWithDefinitionBlock:^(OCAContextExecutionBlock executionBlock) {
            [queue performBlockAndWait:executionBlock];
        }];
    }
    else {
        return [[self alloc] initWithDefinitionBlock:^(OCAContextExecutionBlock executionBlock) {
            [queue performBlockAndTryWait:executionBlock];
        }];
    }
}


+ (OCAContext *)lock:(id<NSLocking>)lock {
    OCAAssert(lock != nil, @"Lock is missing.") return nil;
    return [[OCAContext alloc] initWithDefinitionBlock:^(OCAContextExecutionBlock executionBlock) {
        [lock lock];
        
        executionBlock();
        
        [lock unlock];
    }];
}


+ (OCAContext *)synchronized:(id)object {
    OCAAssert(object != nil, @"Object is missing.") return nil;
    return [[OCAContext alloc] initWithDefinitionBlock:^(OCAContextExecutionBlock executionBlock) {
        @synchronized(object) {
            executionBlock();
        }
    }];
}


+ (OCAContext *)autoreleasepool {
    return [[OCAContext alloc] initWithDefinitionBlock:^(OCAContextExecutionBlock executionBlock) {
        @autoreleasepool {
            executionBlock();
        }
    }];
}





#pragma mark Using Context


- (void)execute:(OCAContextExecutionBlock)executionBlock {
    self.definitionBlock(executionBlock);
}





#pragma mark Context as a Consumer


- (Class)consumedValueClass {
    return nil;
}


- (void)consumeValue:(id)value {
    [self execute:^{
        [self produceValue:value];
    }];
}


- (void)finishConsumingWithError:(NSError *)error {
    [self execute:^{
        [self finishProducingWithError:error];
    }];
}





@end


