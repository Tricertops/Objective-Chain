//
//  OCACommand.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCACommand.h"
#import "OCAProducer+Private.h"










@implementation OCACommand





- (void)sendValue:(id)value {
    [super produceValue:value];
}


- (void)finishWithError:(NSError *)error {
    [super finishProducingWithError:error];
}





@end
