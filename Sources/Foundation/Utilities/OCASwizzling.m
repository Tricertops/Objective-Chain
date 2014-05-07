//
//  OCASwizzling.m
//  Objective-Chain
//
//  Created by Martin Kiss on 6.5.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "OCASwizzling.h"





@implementation NSObject (OCASwizzling)





+ (void)swizzleSelector:(SEL)originalSelector with:(SEL)replacementSelector {
    /// http://nshipster.com/method-swizzling/
    
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method replacementMethod = class_getInstanceMethod(self, replacementSelector);
    
    BOOL didAdd = class_addMethod(self,
                                  originalSelector,
                                  method_getImplementation(replacementMethod),
                                  method_getTypeEncoding(replacementMethod));
    if (didAdd) {
        class_replaceMethod(self,
                            replacementSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, replacementMethod);
    }
}


+ (void)implementOrderedCollectionAccessorsForKey:(NSString *)key {
    NSString *capitalizedKey = [NSString stringWithFormat:@"%@%@", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]];
    
    objc_property_t property = class_getProperty(self, key.UTF8String);
    char *ivar_name = property_copyAttributeValue(property, "V");
    Ivar ivar = class_getInstanceVariable(self, ivar_name);
    free(ivar_name);
    
    SEL underlayingSelector = NSSelectorFromString([NSString stringWithFormat:@"underlayingMutable%@", capitalizedKey]);
    [self implementSelector:underlayingSelector
                      types:"@@:"
                    replace:NO
                      block:^NSMutableArray *(id self) {
        NSMutableArray *collection = object_getIvar(self, ivar);
        if ( ! [collection isKindOfClass:[NSMutableArray class]]) {
            collection = [[NSMutableArray alloc] init];
            object_setIvar(self, ivar, collection);
        }
        return collection;
    }];
    
    NSMutableArray *(^callUnderlayingSelector)(id self) = ^NSMutableArray *(id self) {
        NSMutableArray *(*msg)(id self, SEL _cmd) = (typeof(msg))objc_msgSend;
        return msg(self, underlayingSelector);
    };
    
    [self implementSelector:NSSelectorFromString(key)
                      types:"@@:"
                    replace:YES
                      block:^NSArray *(id self){
                          NSMutableArray *collection = callUnderlayingSelector(self);
                          return [collection copy];
                      }];
    
    [self implementSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:", capitalizedKey])
                      types:"v@:@"
                    replace:YES
                      block:^(id self, NSArray *array){
                          NSMutableArray *collection = callUnderlayingSelector(self);
                          [collection setArray:array];
                      }];
    
    #warning Uses 32-bit NSUInteger
    
    [self implementSelector:NSSelectorFromString([NSString stringWithFormat:@"insertObject:in%@AtIndex:", capitalizedKey])
                      types:"v@:@I"
                    replace:NO
                      block:^(id self, id object, NSUInteger index){
                          NSMutableArray *collection = callUnderlayingSelector(self);
                          [collection insertObject:object atIndex:index];
                      }];
    
    [self implementSelector:NSSelectorFromString([NSString stringWithFormat:@"removeObjectFrom%@AtIndex:", capitalizedKey])
                      types:"v@:I"
                    replace:NO
                      block:^(id self, NSUInteger index){
                          NSMutableArray *collection = callUnderlayingSelector(self);
                          [collection removeObjectAtIndex:index];
                      }];
    
    //TODO: Implement more than minimum.
}


+ (BOOL)implementSelector:(SEL)selector types:(const char *)types replace:(BOOL)replace block:(id)block {
    IMP implementation = imp_implementationWithBlock(block);
    
    if (replace) {
        class_replaceMethod(self, selector, implementation, types);
        return YES;
    }
    else return class_addMethod(self, selector, implementation, types);
}







@end


