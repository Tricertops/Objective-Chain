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
        [invocation retainArguments];
        [self findPlaceholders]; // Includes replacing the target.
    }
    return self;
}


+ (instancetype)invoke:(NSInvocation *)invocation {
    return [[self alloc] initWithInvocation:invocation];
}


- (void)findPlaceholders {
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    NSMutableArray *placeholders = [[NSMutableArray alloc] init];
    [self invocation:self.invocation substituteObjectArguments:^id(NSUInteger index, id argument) {
        
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
            [placeholders addObject:placeholder];
        }
        
        return placeholder ?: argument;
    }];
    
    self->_placeholderIndexes = indexes;
    self->_placeholders = placeholders;
}


- (void)invocation:(NSInvocation *)invocation enumerateObjectArguments:(void(^)(NSUInteger index))block {
    NSUInteger count = invocation.methodSignature.numberOfArguments;
    for (NSUInteger index = 0; index < count; index++) {
        const char *cType = [invocation.methodSignature getArgumentTypeAtIndex:index];
        NSString *type = @(cType);
        if ([type isEqualToString:@(@encode(id))]) {
            block(index);
        }
    }
}


- (void)invocation:(NSInvocation *)invocation substituteObjectArguments:(id(^)(NSUInteger index, id argument))block {
   [self invocation:invocation enumerateObjectArguments:^(NSUInteger index) {
       id argument = [self invocation:invocation objectArgumentAtIndex:index];
       id replacement = block(index, argument);
       if (argument != replacement) {
           [self invocation:invocation setObjectArgument:replacement atIndex:index];
       }
   }];
}


- (id)invocation:(NSInvocation *)invocation objectArgumentAtIndex:(NSUInteger)index {
    void *oldPointer = nil;
    [self.invocation getArgument:&oldPointer atIndex:index];
    return (__bridge id)oldPointer;
}


- (void)invocation:(NSInvocation *)invocation setObjectArgument:(id)newObject atIndex:(NSUInteger)index {
    OCAAssert(invocation.argumentsRetained, @"Current implementation works only for retained arguments.") return;
    
    const char *cType = [invocation.methodSignature getArgumentTypeAtIndex:index];
    OCAAssert([@(cType) isEqualToString:@(@encode(id))], @"Argument at index %lu is not of object type.", (unsigned long)index) return;
    
    void *oldPointer = nil;
    [self.invocation getArgument:&oldPointer atIndex:index];
    __unused id oldObject = (__bridge_transfer id)oldPointer; // -release
    
    void *newPointer = (__bridge_retained void *)newObject; // -retain
    [self.invocation setArgument:&newPointer atIndex:index];
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


