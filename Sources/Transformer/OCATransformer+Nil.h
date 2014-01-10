//
//  OCATransformer+Nil.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Base.h"





@interface OCATransformer (OCANilTransformer)



+ (OCATransformer *)ifNil:(id)replacement;



@end


