//
//  OCAMutableArrayProxy.h
//  Objective-Chain
//
//  Created by Martin Kiss on 17.4.15.
//  Copyright (c) 2015 Martin Kiss. All rights reserved.
//

#import "OCAAccessor.h"





@interface OCAMutableArrayProxy : NSProxy



- (instancetype)initWithReceiver:(id)receiver accessor:(OCAAccessor *)accessor;
- (NSMutableArray *)asMutableArray;

@property (nonatomic, readonly, strong) id receiver;
@property (nonatomic, readonly, strong) OCAAccessor *accessor;


@end


