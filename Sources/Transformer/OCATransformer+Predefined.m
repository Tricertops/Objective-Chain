//
//  OCATransformer+Predefined.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Predefined.h"





@implementation OCATransformer (Predefined)



+ (instancetype)pass {
    Class class = [self subclassForInputClass:nil outputClass:nil reversible:YES name:@"OCAPassTransformer"];
    return [[class alloc] initWithBlock:nil reverseBlock:nil];
}



@end


