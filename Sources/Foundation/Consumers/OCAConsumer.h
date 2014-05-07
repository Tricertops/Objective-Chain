//
//  OCAConsumer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>





/*! Consumer is abstract receiver of values that are send from Producers.
 *  Consumers are retained by all Producers from whose they receive values .
 */
@protocol OCAConsumer <NSObject>



@required

//! Return a class of values that your instance consumes. Retunr nil or NSObject for any values.
- (Class)consumedValueClass;

//! Called after Producer sends new value. Do whatever your implementation requires. Your Consumer can receive from multiple Producers and you don't have a reference to them unless you create it.
- (void)consumeValue:(id)value;

//! Called after Producer finishes sending values. Your Consumer can receive from multiple Producers, so this MAY get called multiple times, one for each Producer.
- (void)finishConsumingWithError:(NSError *)error;



@optional

//! Return an array of classes of values that your instance consumes. Implementing this method is optional and takes precedence over -consumedValueClass.
- (NSArray *)consumedValueClasses;



@end


