//
//  OCASwizzling.h
//  Objective-Chain
//
//  Created by Martin Kiss on 6.5.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>





@interface NSObject (OCASwizzling)


+ (void)swizzleSelector:(SEL)original with:(SEL)replacement;


@end


