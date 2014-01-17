//
//  OCAConnection+OCAFoundation.m
//  Objective-Chain
//
//  Created by Martin Kiss on 17.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAConnection+OCAFoundation.h"
#import "OCAProperty.h"
#import "OCASubscriber.h"










@implementation OCAConnection (OCAFoundation)





- (instancetype)closeWhen:(OCAProperty *)property meets:(NSPredicate *)predicate {
    [property subscribe:nil handler:^(id object) {
        BOOL meets = [predicate evaluateWithObject:object];
        if (meets) {
            [self close];
        }
    }];
    return self;
}





@end


