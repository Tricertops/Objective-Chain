//
//  OCASwizzling.h
//  Objective-Chain
//
//  Created by Martin Kiss on 6.5.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCAConsumer.h"





@interface NSObject (OCASwizzling)


+ (void)swizzleSelector:(SEL)original with:(SEL)replacement;


+ (void)implementOrderedCollectionAccessorsForKey:(NSString *)key;
+ (void)implementOrderedCollectionAccessorsForKey:(NSString *)key insertionCallback:(id<OCAConsumer>)insertionCallback removalCallback:(id<OCAConsumer>)removalCallback;


@end


