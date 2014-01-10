//
//  OCADecomposer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"



typedef void(^OCADecomposerBlock)(void);





@interface OCADecomposer : OCAObject



#pragma mark Managing Owned Objects

- (void)addOwnedObject:(id)object cleanup:(OCADecomposerBlock)block;
- (void)removeOwnedObject:(id)object;

- (NSArray *)ownedObjects;
- (void)enumerateOwnedObjectsOfClass:(Class)class usingBlock:(void(^)(id ownedObject, BOOL *stop))block;



@end





@interface NSObject (OCADecomposer)


- (OCADecomposer *)decomposer;


@end


