//
//  OCAProducer+Private.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAProducer.h"





/// Methods used by private subclasses.
@interface OCAProducer ()



- (void)sendValue:(id)value NS_REQUIRES_SUPER;
- (void)finishWithError:(NSError *)error NS_REQUIRES_SUPER;



@end
