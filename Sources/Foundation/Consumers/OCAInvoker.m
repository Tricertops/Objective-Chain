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





@interface OCAInvoker ()


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
            
            placeholder = [[OCAPlaceholderObject alloc] initWithRepresentedClass:[argument classForCoder]];
        }
        else if ([argument isKindOfClass:[OCAPlaceholderObject class]]) {
            // Found placeholder. Works even if the placeholder is the target.
            placeholder = argument;
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
    return nil;
}


- (void)consumeValue:(id)value {
    NSMutableArray *substitutions = [NSMutableArray arrayWithObjects:self->_target, nil]; // May be nil, so empty.
    if ([value isKindOfClass:[NSArray class]]) {
        [substitutions addObjectsFromArray:(NSArray *)value];
    }
    else if (value) {
        [substitutions addObject:value];
    }
    [self invokeWithSubstitutions:substitutions];
}


- (void)finishConsumingWithError:(NSError *)error {
    self->_target = nil;
    self->_invocation = nil;
    self->_fixedArguments = nil;
    self->_placeholderIndexes = nil;
    self->_placeholders = nil;
}





@end


