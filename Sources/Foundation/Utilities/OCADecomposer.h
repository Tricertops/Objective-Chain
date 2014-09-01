//
//  OCADecomposer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"



typedef void(^OCADecomposerBlock)(__unsafe_unretained id owner);





@interface OCADecomposer : OCAObject



#pragma mark Managing Owned Objects

- (void)addOwnedObject:(id)object cleanup:(OCADecomposerBlock)block;
- (void)removeOwnedObject:(id)object;

- (NSArray *)ownedObjects;
- (id)findOwnedObjectOfClass:(Class)theClass usingBlock:(BOOL(^)(id ownedObject))filterBlock;



@end





@interface NSObject (OCADecomposer)


- (OCADecomposer *)decomposer;


@end


