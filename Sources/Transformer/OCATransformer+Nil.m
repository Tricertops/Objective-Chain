//
//  OCATransformer+Nil.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Nil.h"
#import "OCAObject.h"





@interface OCANilTransformer : OCATransformer


@property (atomic, readonly, strong) id replacement;


@end










@implementation OCANilTransformer







- (instancetype)initWithReplacement:(id)replacement {
    self = [super init];
    if (self) {
        OCAAssert(replacement != nil, @"Are you kidding me?");
        self->_replacement = replacement;
        
        [self describe:[NSString stringWithFormat:@"replace nil by %@", replacement]];
    }
    return self;
}


+ (BOOL)allowsReverseTransformation {
    return YES;
}


- (id)transformedValue:(id)value {
    [OCAObject validateObject:&value ofClass:[self.class valueClass]];
    return value ?: self.replacement;
}


- (id)reverseTransformedValue:(id)value {
    return value;
}






@end










@implementation OCATransformer (OCANilTransformer)



+ (OCATransformer *)ifNil:(id)replacement {
    return [[OCANilTransformer alloc] initWithReplacement:replacement];
}



@end


