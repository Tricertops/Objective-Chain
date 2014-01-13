//
//  OCAPredicate.m
//  Objective-Chain
//
//  Created by Martin Kiss on 11.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAPredicate.h"










@implementation NSPredicate (OCAPredicateCompatibility)





- (NSPredicate *)negate {
    return [OCAPredicate not:self];
}





@end










@implementation OCAPredicate





+ (NSPredicate *)isNil {
    return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return (evaluatedObject == nil); //TODO: Test if nils are evaluated.
    }];
}


+ (NSPredicate *)predicateForClass:(Class)class block:(BOOL(^)(id object))block {
    return [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        if ( ! object) return NO;
        BOOL compatible = [self isClass:[object class] compatibleWithClass:class];
        if ( ! compatible) return NO;
        
        return block(object);
    }];
}





@end










@implementation OCAPredicate (Predefined)





+ (NSPredicate *)isEmpty {
    return [OCAPredicate predicateForClass:nil block:^BOOL(id object) {
        if ([object respondsToSelector:@selector(count)]) {
            return ([object count] == 0);
        }
        if ([object respondsToSelector:@selector(length)]) {
            return ([object length] == 0);
        }
        if ([object respondsToSelector:@selector(boolValue)]) {
            return [object boolValue];
        }
        return NO;
    }];
}


+ (NSPredicate *)pass {
    return [NSPredicate predicateWithValue:YES];
}


+ (NSPredicate *)discard {
    return [NSPredicate predicateWithValue:NO];
}


+ (NSPredicate *)isKindOf:(Class)class {
    return [OCAPredicate predicateForClass:class block:^BOOL(id object) {
        return YES;
    }];
}


+ (NSPredicate *)not:(NSPredicate *)predicate {
    return [NSCompoundPredicate notPredicateWithSubpredicate:predicate];
}


+ (NSPredicate *)and:(NSArray *)subpredicates {
    return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
}


+ (NSPredicate *)or:(NSArray *)subpredicates {
    return [NSCompoundPredicate orPredicateWithSubpredicates:subpredicates];
}


+ (NSPredicate *)all:(NSPredicate *)predicate {
    return [OCAPredicate predicateForClass:nil block:^BOOL(id<NSFastEnumeration, NSObject> collection) {
        if ([collection conformsToProtocol:@protocol(NSFastEnumeration)]) {
            return NO;
        }
        for (id object in collection) {
            BOOL b = [predicate evaluateWithObject:object];
            if ( ! b) return NO;
        }
        return YES;
    }];
}


+ (NSPredicate *)any:(NSPredicate *)predicate {
    return [OCAPredicate predicateForClass:nil block:^BOOL(id<NSFastEnumeration, NSObject> collection) {
        if ([collection conformsToProtocol:@protocol(NSFastEnumeration)]) {
            return NO;
        }
        for (id object in collection) {
            BOOL b = [predicate evaluateWithObject:object];
            if (b) return YES;
        }
        return NO;
    }];
}


+ (NSPredicate *)predicateForClass:(Class)class predicate:(NSPredicate *)predicate {
    return [OCAPredicate predicateForClass:class block:^BOOL(id object) {
        return [predicate evaluateWithObject:object];
    }];
}


+ (NSPredicate *)predicateFor:(Class)class format:(NSString *)format, ... {
    va_list vargs;
    va_start(vargs, format);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format arguments:vargs];
    va_end(vargs);
    
    return [OCAPredicate predicateForClass:class predicate:predicate];
}


+ (NSPredicate *)access:(OCAAccessor *)booleanAccessor {
    return [OCAPredicate predicateForClass:booleanAccessor.valueClass block:^BOOL(id object) {
        id value = [booleanAccessor accessObject:object];
        if ( ! value) return NO;
        if (value == NSNull.null) return NO;
        if ([value respondsToSelector:@selector(boolValue)]) return [object boolValue];
        return YES;
    }];
}


+ (NSPredicate *)compare:(OCAAccessor *)accessor operator:(NSString *)operator value:(id)rightValue {
    return [OCAPredicate predicateForClass:accessor.valueClass block:^BOOL(id object) {
        id leftValue = [accessor accessObject:object];
        // Now, a double substitution!
        NSString *format = [NSString stringWithFormat:@"%%@ %@ %%@", operator];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:format, leftValue, rightValue];
        return [predicate evaluateWithObject:object];
    }];
}


+ (NSPredicate *)compare:(OCAAccessor *)accessor using:(BOOL(^)(id input))block {
    return [OCAPredicate predicateForClass:accessor.valueClass block:^BOOL(id object) {
        id value = [accessor accessObject:object];
        return block(value);
    }];
}





@end


