//
//  OCATransformer+Predefined.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Predefined.h"





@implementation OCATransformer (Predefined)



+ (instancetype)indentity {
    return [self subclassTransformerWithName:@"OCAIdentityTransformer"
                                  inputClass:nil
                                 outputClass:nil
                              transformation:nil
                                  reversible:YES
                       reverseTransformation:nil];
}



@end


