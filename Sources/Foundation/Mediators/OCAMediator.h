//
//  OCAMediator.h
//  Objective-Chain
//
//  Created by Martin Kiss on 27.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"





/*! Mediator is abstract class, that inherits from Producer and conforms to Consumer protocol.
 *  Subclasses of this class have two things in common:
 *    1. They don't really consume the values in meaningful manner.
 *    2. They don't really produce any genuine values.
 *  Mediator serves as an intermediate step between original Producer and final Consumer and allows you to do powerful manipulations to the values that flow between them.
 *
 *  Concrete Mediators allow you to transform the values, filter them, forward them in a known context, limit them, or temporarily stop them.
 */
@interface OCAMediator : OCAProducer <OCAConsumer>

@end


