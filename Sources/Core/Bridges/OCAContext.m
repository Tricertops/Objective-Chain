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










@implementation OCAContext





#pragma mark Creating Context


- (instancetype)initWithValueClass:(Class)valueClass {
    return [self initWithValueClass:valueClass definitionBlock:nil];
}


- (instancetype)initWithValueClass:(Class)valueClass definitionBlock:(OCAContextDefinitionBlock)definitionBlock {
    self = [super initWithValueClass:valueClass];
    if (self) {
        self->_definitionBlock = definitionBlock ?: [OCAContext defaultDefinitionBlock];
    }
    return self;
}


+ (OCAContextDefinitionBlock)defaultDefinitionBlock {
    return ^(OCAContextExecutionBlock executionBlock){
        executionBlock();
    };
}


+ (OCAContext *)empty {
    return [[self alloc] initWithValueClass:nil definitionBlock:nil];
}


+ (OCAContext *)custom:(OCAContextDefinitionBlock)block {
    return [[self alloc] initWithValueClass:nil definitionBlock:block];
}


+ (OCAContext *)property:(OCAProperty *)property value:(id)value {
    return [[self alloc] initWithValueClass:nil definitionBlock:^(OCAContextExecutionBlock executionBlock) {
        id originalValue = [property value];
        [property setValue:value];
        
        executionBlock(); // Block is executed when the property has desired value.
        
        [property setValue:originalValue];
    }];
}





#pragma mark Using Context


- (void)execute:(OCAContextExecutionBlock)executionBlock {
    __block BOOL wasExecuted = NO;
    self.definitionBlock(^{
        wasExecuted = YES;
        executionBlock();
    });
    OCAAssert(wasExecuted, @"The block have to be executed!") executionBlock(); // As a fallback, execute it anyway, without the context.
}





#pragma mark Context as a Consumer


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



- (OCABridge *)contextualize:(OCAContext *)context {
    (void)[[OCAConnection alloc] initWithProducer:self queue:nil transform:nil consumer:context];
    return context;
}



@end


