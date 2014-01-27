//
//  OCAContext.m
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAContext.h"
#import "OCAProducer+Subclass.h"





@interface OCAContext ()


@property (atomic, readonly, strong) OCAContextDefinitionBlock definitionBlock;


@end





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





#pragma mark Using Context


- (void)execute:(OCAContextExecutionBlock)executionBlock {
    //TODO: Can be somehow controlled and verified.
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





#pragma mark Describing Context


- (NSString *)descriptionName {
    return @"Context";
}





@end










@implementation OCAProducer (OCAContext)



- (OCAContext *)produceInContext:(OCAContext *)context CONVENIENCE {
    [self addConsumer:context];
    return context;
}


- (OCAContext *)produceInContextBlock:(OCAContextDefinitionBlock)contextBlock {
    OCAContext *context = [[OCAContext alloc] initWithDefinitionBlock:contextBlock];
    [self addConsumer:context];
    return context;
}


- (OCAContext *)produceOnQueue:(OCAQueue *)queue CONVENIENCE {
    OCAContext *context = [[OCAContext alloc] initWithDefinitionBlock:^(OCAContextExecutionBlock executionBlock) {
        [queue performBlockAndTryWait:executionBlock];
    }];
    [self addConsumer:context];
    return context;
}



@end


