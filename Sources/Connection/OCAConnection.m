//
//  OCAConnection.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAConnection+Private.h"



@interface OCAConnection ()

@end





@implementation OCAConnection





- (instancetype)initWithProducer:(id<OCAProducer>)producer {
    self = [super init];
    if (self) {
        self->_producer = producer;
    }
    return self;
}





@end
