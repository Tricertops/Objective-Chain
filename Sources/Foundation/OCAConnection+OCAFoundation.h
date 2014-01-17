//
//  OCAConnection+OCAFoundation.h
//  Objective-Chain
//
//  Created by Martin Kiss on 17.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAConnection.h"





@interface OCAConnection (OCAFoundation)




- (instancetype)closeWhen:(OCAProperty *)property meets:(NSPredicate *)predicate;





@end


