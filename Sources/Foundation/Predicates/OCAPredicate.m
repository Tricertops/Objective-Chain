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
        return (evaluatedObject == nil || evaluatedObject == NSNull.null);
    }];
}


+ (NSPredicate *)isNotNil {
    return [[OCAPredicate isNil] negate];
}


+ (NSPredicate *)predicateForClass:(Class)class block:(BOOL(^)(id object))block {
    return [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        BOOL compatible = [self isClass:[object class] compatibleWithClass:class];
        if ( ! compatible) return NO;
        
        return block(object);
    }];
}





@end










@implementation OCAPredicate (Predefined)





+ (NSPredicate *)isTrue {
    return [OCAPredicate predicateForClass:nil block:^BOOL(id object) {
        if ([object isKindOfClass:[NSNumber class]]) {
            return [object boolValue];
        }
        if (object == NSNull.null) {
            return NO;
        }
        return (object != nil);
    }];
}


+ (NSPredicate *)isFalse {
    return [[OCAPredicate isTrue] negate];
}


+ (NSPredicate *)isEmpty {
    return [OCAPredicate predicateForClass:nil block:^BOOL(id object) {
        if ( ! object) {
            return YES;
        }
        if ([object respondsToSelector:@selector(count)]) {
            return ([object count] == 0);
        }
        if ([object respondsToSelector:@selector(length)]) {
            return ([object length] == 0);
        }
        if ([object respondsToSelector:@selector(boolValue)]) {
            return ([object boolValue] == NO);
        }
        return NO;
    }];
}

+ (NSPredicate *)isNotEmpty {
    return [[OCAPredicate isEmpty] negate];
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


+ (NSPredicate *)isProperty:(OCAProperty *)property {
    return [OCAPredicate compareProperty:property using:[OCAPredicate isTrue]];
}


+ (NSPredicate *)compareProperty:(OCAProperty *)property using:(NSPredicate *)predicate {
    return [OCAPredicate predicateForClass:nil block:^BOOL(id object) {
        return [predicate evaluateWithObject:property.value];
    }];
}


+ (NSPredicate *)compare:(OCAAccessor *)accessor format:(NSString *)operatorFormat value:(id)rightValue {
    return [OCAPredicate predicateForClass:accessor.objectClass block:^BOOL(id object) {
        id leftValue = [accessor accessObject:object];
        // Now, a double substitution!
        NSString *format = [NSString stringWithFormat:@"%%@ %@ %%@", operatorFormat];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:format, leftValue, rightValue];
        return [predicate evaluateWithObject:object];
    }];
}


+ (NSPredicate *)compare:(OCAAccessor *)accessor using:(NSPredicate *)predicate {
    return [OCAPredicate predicateForClass:accessor.objectClass block:^BOOL(id object) {
        id value = [accessor accessObject:object];
        return [predicate evaluateWithObject:value];
    }];
}


+ (NSPredicate *)operator:(NSPredicateOperatorType)operator options:(NSComparisonPredicateOptions)options value:(id)value {
    return [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForEvaluatedObject]
                                              rightExpression:[NSExpression expressionForConstantValue:value]
                                                     modifier:NSDirectPredicateModifier
                                                         type:operator
                                                      options:options];
}


+ (NSPredicate *)isLessThan:(id)value {
    return [self operator:NSLessThanPredicateOperatorType options:kNilOptions value:value];
}


+ (NSPredicate *)isLessThanOrEqual:(id)value {
    return [self operator:NSLessThanOrEqualToPredicateOperatorType options:kNilOptions value:value];
}


+ (NSPredicate *)isGreaterThan:(id)value {
    return [self operator:NSGreaterThanPredicateOperatorType options:kNilOptions value:value];
}


+ (NSPredicate *)isGreaterThanOrEqual:(id)value {
    return [self operator:NSGreaterThanOrEqualToPredicateOperatorType options:kNilOptions value:value];
}


+ (NSPredicate *)isEqualTo:(id)value {
    return [self operator:NSEqualToPredicateOperatorType options:kNilOptions value:value];
}


+ (NSPredicate *)isNotEqualTo:(id)value {
    return [[OCAPredicate isEqualTo:value] negate];
}


+ (NSPredicate *)matches:(NSString *)regex {
    return [self operator:NSMatchesPredicateOperatorType options:kNilOptions value:regex];
}


+ (NSPredicate *)isLike:(NSString *)string {
    return [self operator:NSLikePredicateOperatorType options:kNilOptions value:string];
}


+ (NSPredicate *)beginsWith:(id)value {
    return [self operator:NSBeginsWithPredicateOperatorType options:kNilOptions value:value];
}


+ (NSPredicate *)endsWith:(id)value {
    return [self operator:NSEndsWithPredicateOperatorType options:kNilOptions value:value];
}


+ (NSPredicate *)isIn:(id)value {
    return [self operator:NSInPredicateOperatorType options:kNilOptions value:value];
}


+ (NSPredicate *)contains:(id)value {
    return [self operator:NSContainsPredicateOperatorType options:kNilOptions value:value];
}


+ (NSPredicate *)isBetween:(id)lower and:(id)upper {
    return [self operator:NSBetweenPredicateOperatorType options:kNilOptions value:@[ lower, upper ]];
}





@end


