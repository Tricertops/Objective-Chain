//
//  OCABridge.h
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMediator.h"





//! Bridge is a Mediator (Producer and Consumer), that simply passes values further with optional transformation.
@interface OCABridge : OCAMediator



#pragma mark Creating Bridge

/*! Designated initializer. Initializes new Bridge that uses given transformer to transform values. Pass nil for no transformation on values.
 *  The receiver will use transformer's +valueClass and +transformedValueClass methods to declare its own -valueClass and -consumedValueClass.
 */
- (instancetype)initWithTransformer:(NSValueTransformer *)transformer;

//! Creates new Bridge, that passes values of given class. If class is nil, it passes all values to its Consumers.
+ (OCABridge *)bridgeForClass:(Class)theClass;

//! Create new Bridge, that uses sequence of transformers to transform values passed then to Consumers.
+ (OCABridge *)bridgeWithTransformers:(NSValueTransformer *)transformer, ... NS_REQUIRES_NIL_TERMINATION;



#pragma mark Transformer

//! Property that contains the transformer passed to initializer, if any.
@property (atomic, readonly, strong) NSValueTransformer *transformer;



@end


