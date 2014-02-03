//
//  OCAInvoker.m
//  Objective-Chain
//
//  Created by Martin Kiss on 27.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAInvoker.h"
#import "NSArray+Ordinals.h"





@interface OCAInvoker ()


@property (atomic, readonly, strong) NSIndexSet *placeholderIndexes;
@property (atomic, readonly, strong) NSArray *placeholders;


@end










@implementation OCAInvoker





- (instancetype)initWithInvocation:(NSInvocation *)invocation {
    self = [super init];
    if (self) {
        OCAAssert(invocation != nil, @"Need invocation");
        
        self->_invocation = invocation;
        [self findPlaceholders]; // Includes replacing the target,
        [invocation retainArguments];
    }
    return self;
}


+ (instancetype)invoke:(NSInvocation *)invocation {
    return [[self alloc] initWithInvocation:invocation];
}


- (void)findPlaceholders {
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    NSMutableArray *placeholders = [[NSMutableArray alloc] init];
    
    NSInvocation *invocation = self->_invocation;
    NSUInteger count = invocation.methodSignature.numberOfArguments;
    for (NSUInteger index = 0; index < count; index++) {
        // At least two arguments are always there.
        
        const char *cType = [invocation.methodSignature getArgumentTypeAtIndex:index];
        NSString *type = @(cType);
        if ( ! [type isEqualToString:@(@encode(id))]) continue;
            // Found object argument.
            
        __unsafe_unretained id unsafe_argument = nil;
        [invocation getArgument:&unsafe_argument atIndex:index];
        id argument = unsafe_argument; // Retain it.
        
        if (index == 0 && argument && ! [argument isKindOfClass:[OCAPlaceholderObject class]]) {
            // Target is always replaced by placeholder and is stored weakly.
            self->_target = argument;
            argument = [[OCAPlaceholderObject alloc] initWithRepresentedClass:[argument class]];
        }
        
        if ([argument isKindOfClass:[OCAPlaceholderObject class]]) {
            // Found placeholder. This may be the target or other argument.
            
            OCAPlaceholderObject *placeholder = (OCAPlaceholderObject *)argument;
            [indexes addIndex:index];
            [placeholders addObject:placeholder];
            
            // Remove it from there.
            id nothing = nil;
            [invocation setArgument:&nothing atIndex:index];
        }
    }
    
    self->_placeholderIndexes = indexes;
    self->_placeholders = placeholders;
}


- (void)invokeWithSubstitutions:(NSArray *)substitutions {
    __block NSUInteger index = 0;
    [self.placeholderIndexes enumerateIndexesUsingBlock:^(NSUInteger argumentIndex, BOOL *stop) {
        
        OCAPlaceholderObject *placeholder = [self.placeholders objectAtIndex:index];
        id substitution = [substitutions oca_valueAtIndex:index];
        BOOL valid = [self validateObject:&substitution ofClass:placeholder.representedClass];
        if (valid) {
            [self.invocation setArgument:&substitution atIndex:argumentIndex];
        }
        
        index ++;
    }];
    [self.invocation invoke];
    self.invocation.target = nil;
    
    [self.placeholderIndexes enumerateIndexesUsingBlock:^(NSUInteger argumentIndex, BOOL *stop) {
        id nothing = nil;
        [self.invocation setArgument:&nothing atIndex:argumentIndex];
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
}





@end


