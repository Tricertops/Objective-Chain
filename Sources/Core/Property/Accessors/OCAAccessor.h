//
//  OCAAccessor.h
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"





@interface OCAAccessor : OCAObject



#pragma mark Using Accessor

- (id)accessObject:(id)object;
- (id)modifyObject:(id)object withValue:(id)value;


#pragma mark Class Validation of Accessor

- (Class)objectClass;
- (Class)valueClass;



@end


