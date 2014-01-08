//
//  OCAAccessor.m
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAAccessor.h"










@implementation OCAAccessor





#pragma mark Using Accessor


- (id)accessObject:(id)object {
    return object;
}


- (id)modifyObject:(id)object withValue:(id)value {
    return object;
}





#pragma mark Clas Validation


- (Class)objectClass {
    return nil;
}


- (Class)valueClass {
    return nil;
}





@end


