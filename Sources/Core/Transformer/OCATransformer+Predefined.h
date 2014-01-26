//
//  OCATransformer+Predefined.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Base.h"
#import "OCAKeyPathAccessor.h"
#import "OCAStructureAccessor.h"





@interface OCATransformer (Predefined)



#pragma mark Basic

+ (OCATransformer *)pass;
+ (OCATransformer *)discard;
+ (OCATransformer *)replaceWith:(id)replacement;
+ (OCATransformer *)ifNil:(id)replacement;
+ (OCATransformer *)kindOfClass:(Class)class or:(id)replacement;
+ (OCATransformer *)copy;


#pragma mark Control Flow

+ (OCATransformer *)sequence:(NSArray *)transformers;
+ (OCATransformer *)convertTo:(Class)finalClass using:(NSArray *)transformers;
+ (OCATransformer *)repeat:(NSUInteger)count transformer:(NSValueTransformer *)transformer;
+ (OCATransformer *)if:(NSPredicate *)predicate then:(NSValueTransformer *)thenTransformer else:(NSValueTransformer *)elseTransformer;
+ (OCATransformer *)yes:(id)replacement no:(id)replacement;


#pragma mark Accessors

+ (OCATransformer *)access:(OCAAccessor *)accessor;
+ (OCATransformer *)modify:(OCAAccessor *)accessor value:(id)value;
+ (OCATransformer *)modify:(OCAAccessor *)accessor transformer:(NSValueTransformer *)transformer;


#pragma mark Side Effects

+ (OCATransformer *)sideEffect:(void(^)(id value))block;
+ (OCATransformer *)debugPrintWithMarker:(NSString *)marker;



@end


