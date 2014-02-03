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
        [self findPlaceholders];
        
        // Target may be one of the placeholders and is now nullified.
        self->_target = invocation.target;
        self.invocation.target = nil;
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
        
        const char *cType = [invocation.methodSignature getArgumentTypeAtIndex:index];
        NSString *type = @(cType);
        if ([type isEqualToString:@(@encode(id))]) {
            // Found object argument.
            
            __unsafe_unretained id argumentUnretained = nil;
            [invocation getArgument:&argumentUnretained atIndex:index];
            id argument = argumentUnretained;
            if ([argument isKindOfClass:[OCAPlaceholderObject class]]) {
                // Found placeholder. This may be even the target.
                
                OCAPlaceholderObject *placeholder = (OCAPlaceholderObject *)argument;
                [indexes addIndex:index];
                [placeholders addObject:placeholder];
                
                // Remove it from there.
                id nothing = nil;
                [invocation setArgument:&nothing atIndex:index];
                
            }
            
        }
        
    }
    self->_placeholderIndexes = indexes;
    self->_placeholders = placeholders;
}


- (void)invokeWithSubstitutions:(NSArray *)substitutions {
    NSInvocation *invocation = self->_invocation;
    __block NSUInteger index = 0;
    [self.placeholderIndexes enumerateIndexesUsingBlock:^(NSUInteger argumentIndex, BOOL *stop) {
        
        OCAPlaceholderObject *placeholder = [self.placeholders objectAtIndex:index];
        id substitution = [substitutions oca_valueAtIndex:index];
        BOOL valid = [self validateObject:&substitution ofClass:placeholder.representedClass];
        if (valid) {
            [invocation setArgument:&substitution atIndex:argumentIndex];
        }
        
        index ++;
    }];
    if ( ! [self.placeholderIndexes containsIndex:0]) {
        // Target was not placeholder.
        self.invocation.target = self.target;
    }
    [self.invocation invoke];
    self.invocation.target = nil;
}


- (Class)consumedValueClass {
    return nil;
}


- (void)consumeValue:(id)value {
    NSArray *substitutions = nil;
    if ([value isKindOfClass:[NSArray class]]) {
        substitutions = value;
    }
    else {
        substitutions = @[ value ?: NSNull.null ];
    }
    [self invokeWithSubstitutions:substitutions];
}


- (void)finishConsumingWithError:(NSError *)error {
    self->_target = nil;
    self->_invocation = nil;
}





@end


