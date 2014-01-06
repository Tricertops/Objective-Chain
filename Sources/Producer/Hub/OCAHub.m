//
//  OCAHub.m
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAHub.h"
#import "OCAProducer+Private.h"
#import "OCAConsumer.h"
#import "OCATransformer.h"





@interface OCAHub () < OCAConsumer >


@property (OCA_atomic, readonly, strong) Class consumedValueClass;
@property (OCA_atomic, readonly, strong) NSMutableArray *mutableProducers;


@end










@implementation OCAHub





#pragma mark Creating Hub


- (instancetype)initWithType:(OCAHubType)type producers:(NSArray *)producers {
    Class valueClass = nil;
    Class consumedValueClass = [self valueClassForClasses:[producers valueForKeyPath:OCAKeypath(OCAProducer, valueClass)]];
    
    if (type == OCAHubTypeMerge) {
        valueClass = consumedValueClass;
    }
    else if (type == OCAHubTypeCombine) {
        valueClass = [NSArray class];
    }
    
    self = [super initWithValueClass:valueClass];
    if (self) {
        self->_type = type;
        self->_mutableProducers = [producers mutableCopy];
        self->_consumedValueClass = consumedValueClass;
        
        [self openConnections];
    }
    return self;
}


+ (instancetype)merge:(NSArray *)producers {
    return [[self alloc] initWithType:OCAHubTypeMerge producers:producers];
}


+ (instancetype)combine:(NSArray *)producers {
    return [[self alloc] initWithType:OCAHubTypeCombine producers:producers];
}





#pragma mark Lifetime of Hub


- (NSArray *)producers {
    return [self.mutableProducers copy];
}


- (void)openConnections {
    for (OCAProducer *producer in self.mutableProducers) {
        OCAAssert([producer isKindOfClass:[OCAProducer class]], @"Need OCAProducer, not %@", producer.class) continue;
        
        [producer connectTo:self];
    }
}


- (void)consumeValue:(id)value {
    if (self.type == OCAHubTypeMerge) {
        [self produceValue:value];
    }
    else if (self.type == OCAHubTypeCombine) {
        NSArray *latestValues = [self.producers valueForKeyPath:OCAKeypath(OCAProducer, lastValue)];
        [self produceValue:latestValues];
    }
}


- (void)finishConsumingWithError:(NSError *)error {
    if (error) {
        [self finishProducingWithError:error];
    }
    else {
        for (OCAProducer *producer in [self.mutableProducers copy]) {
            if (producer.finished) {
                [self.mutableProducers removeObjectIdenticalTo:producer];
            }
        }
        if (self.mutableProducers.count == 0) {
            [self finishProducingWithError:nil];
        }
    }
}





#pragma mark Describing Hub


- (NSString *)descriptionName {
    return (self.type == OCAHubTypeMerge
            ? @"Merge"
            : (self.type == OCAHubTypeCombine
               ? @"Combination"
               : @"Hub"));
}


- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" from { %@ }", [[self.producers valueForKeyPath:OCAKeypath(OCAProducer, description)] componentsJoinedByString:@", "]];
}


- (NSDictionary *)debugDescriptionValues {
    NSMutableDictionary *dictionary = [[super debugDescriptionValues] mutableCopy];
    
    id type = (self.type == OCAHubTypeMerge? @"OCAHubTypeMerge" : (self.type == OCAHubTypeCombine? @"OCAHubTypeMerge" : @(self.type)));
    [dictionary setValue:type forKey:@"type"];
    [dictionary setValue:[self.producers debugDescription] forKey:@"producers"];
    
    return dictionary;
}






@end









@implementation OCAProducer (OCAHub)





- (OCAHub *)mergeWith:(OCAProducer *)producer {
    return [[OCAHub alloc] initWithType:OCAHubTypeMerge producers:@[ self, producer ]];
}


- (OCAHub *)combineWith:(OCAProducer *)producer {
    return [[OCAHub alloc] initWithType:OCAHubTypeCombine producers:@[ self, producer ]];
}





@end


