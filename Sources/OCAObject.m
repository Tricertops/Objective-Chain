//
//  OCAObject.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"





@implementation OCAObject





#pragma mark Class Checking


+ (Class)valueClassForClasses:(NSArray *)classes {
    NSMutableArray *concreteClasses = [[NSMutableArray alloc] init];
    for (Class class in classes) {
        if (class != NSNull.null && class != [NSObject class]) {
            [concreteClasses addObject:class];
        }
    }
    
    Class finalClass = concreteClasses.firstObject;
    while (finalClass) {
        BOOL isCommonToAll = YES;
        for (Class class in concreteClasses) {
            BOOL isSuperclass = [class isSubclassOfClass:finalClass];
            isCommonToAll &= isSuperclass;
            if ( ! isCommonToAll) break;
        }
        if (isCommonToAll) break;
        finalClass = finalClass.superclass;
    }
    return finalClass;
}


- (Class)valueClassForClasses:(NSArray *)classes {
    return [self.class valueClassForClasses:classes];
}





@end
