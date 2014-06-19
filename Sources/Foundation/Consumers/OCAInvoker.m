//
//  OCAInvoker.m
//  Objective-Chain
//
//  Created by Martin Kiss on 27.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAInvoker.h"
#import "OCAInvocationCatcher.h"
#import "NSArray+Ordinals.h"
#import "OCADecomposer.h"





@interface OCAInvoker ()

@property (nonatomic, readonly, assign) BOOL isTargetConsumed;
@property (nonatomic, readonly, assign) NSUInteger numberOfConsumedObjects;

@property (atomic, readonly, strong) NSArray *fixedArguments;
@property (atomic, readonly, strong) NSIndexSet *placeholderIndexes;
@property (atomic, readonly, strong) NSArray *placeholders;


@end










@implementation OCAInvoker





- (instancetype)initWithInvocationCatcher:(OCAInvocationCatcher *)catcher {
    self = [super init];
    if (self) {
        NSInvocation *invocation = catcher.invocation;
        
        OCAAssert(invocation != nil, @"Need invocation!") return nil;
        OCAAssert( ! invocation.argumentsRetained, @"Retaining arguments of invocation does not work as expected.") return nil;
        
        self->_invocation = invocation;
        [self findPlaceholders];
        
        [[self.target decomposer] addOwnedObject:self cleanup:^(__unsafe_unretained id owner) {
            [self clearInvocationAndArguments];
        }];
        
        //! Catcher must live until here, because it retains the arguments.
        [catcher self];
    }
    return self;
}


+ (instancetype)invoke:(NSInvocation *)invocation {
    return [[self alloc] initWithInvocation:invocation];
}





- (void)findPlaceholders {
    NSMutableArray *fixedArguments = [[NSMutableArray alloc] init];
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    NSMutableArray *placeholders = [[NSMutableArray alloc] init];
    
    [self.invocation oca_enumerateObjectArgumentsUsingBlock:^(NSUInteger index, id argument) {
        OCAPlaceholderObject *placeholder = nil;
        if (index == 0 && argument && ! [argument isKindOfClass:[OCAPlaceholderObject class]]) {
            // Target is always replaced by placeholder and is stored weakly.
            self->_target = argument; // This is weak, so the target must be retained somewhere else to make this work.
            
            placeholder = [OCAPlaceholderObject placeholderForClass:[argument classForCoder]];
        }
        else if ([argument isKindOfClass:[OCAPlaceholderObject class]]) {
            // Found placeholder. Works even if the placeholder is the target.
            placeholder = argument;
            self->_numberOfConsumedObjects ++;
            if (index == 0) {
                self->_isTargetConsumed = YES;
            }
        }
        
        if (placeholder) {
            [indexes addIndex:index];
            [placeholders addObject:placeholder]; // Retains placeholders.
        }
        else if (argument) {
            [fixedArguments addObject:argument]; // Retains arguments.
        }
        
        __unsafe_unretained id replacement = (placeholder ? nil : argument);
        [self.invocation setArgument:&replacement atIndex:index];
    }];
    
    self->_fixedArguments = fixedArguments;
    self->_placeholderIndexes = indexes;
    self->_placeholders = placeholders;
}





- (void)invokeWithSubstitutions:(NSArray *)substitutions {
    NSInvocation *invocation = self.invocation;
    __block NSUInteger index = 0;
    [self.placeholderIndexes enumerateIndexesUsingBlock:^(NSUInteger argumentPosition, BOOL *stop) {
        
        OCAPlaceholderObject *placeholder = [self.placeholders objectAtIndex:index];
        id substitution = [substitutions oca_valueAtIndex:index];
        BOOL valid = [self validateObject:&substitution ofClass:placeholder.representedClass];
        if (valid) {
            __unsafe_unretained id unsafe = substitution;
            [invocation setArgument:&unsafe atIndex:argumentPosition];
        }
        index ++;
    }];
    
    [invocation invoke];
    
    [self.placeholderIndexes enumerateIndexesUsingBlock:^(NSUInteger argumentPosition, BOOL *stop) {
        __unsafe_unretained id null = nil;
        [invocation setArgument:&null atIndex:argumentPosition];
    }];
}


- (Class)consumedValueClass {
    switch (self.numberOfConsumedObjects) {
        case 0: return nil;
        case 1: return [self.placeholders.lastObject representedClass]; // There should be 2 placeholders, since target always has one.
        default: return [NSArray class];
    }
}


- (void)consumeValue:(id)value {
    if ( ! self.invocation) return;
    
    NSObject *target = self.target;
    if ( ! target && ! self.isTargetConsumed) {
        [self clearInvocationAndArguments];
        return;
    }
    
    NSMutableArray *substitutions = [NSMutableArray arrayWithObjects:target, nil]; // May be nil, so empty.
    
    if ([value isKindOfClass:[NSArray class]] && self.consumedValueClass == [NSArray class]) {
        // Expand the array only if multiple arguments are expected.
        [substitutions addObjectsFromArray:(NSArray *)value];
    }
    else if (value) {
        // Even in case of NSArray, when only single argument is expected.
        [substitutions addObject:value];
    }
    [self invokeWithSubstitutions:substitutions];
}


- (void)clearInvocationAndArguments {
    self->_target = nil;
    self->_invocation = nil;
    self->_fixedArguments = nil;
    self->_placeholderIndexes = nil;
    self->_placeholders = nil;
}


- (void)finishConsumingWithError:(NSError *)error {
}





@end


