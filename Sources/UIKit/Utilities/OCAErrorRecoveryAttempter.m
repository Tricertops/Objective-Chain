//
//  OCAErrorRecoveryAttempter.m
//  Objective-Chain
//
//  Created by Martin Kiss on 24.4.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAErrorRecoveryAttempter.h"
#import "OCACommand.h"
@import ObjectiveC.message;





@interface OCAErrorRecoveryAttempter ()

@property (atomic, readonly, strong) NSMutableArray *titles;
@property (atomic, readonly, strong) NSMutableArray *options;

@end





@implementation OCAErrorRecoveryAttempter





- (instancetype)init {
    self = [super init];
    if (self) {
        self->_titles = [[NSMutableArray alloc] init];
        self->_options = [[NSMutableArray alloc] init];
    }
    return self;
}





- (OCAProducer *)addRecoveryOptionWithTitle:(NSString *)title {
    OCACommand *option = [OCACommand commandForClass:[NSError class]];
    [self.titles addObject:title];
    [self.options addObject:option];
    return option;
}


- (OCAProducer *)recoveryOptionAtIndex:(NSUInteger)index {
    return [self.options objectAtIndex:index];
}





- (NSString *)recoveryOptionTitles {
    return [self.titles copy];
}





- (BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex {
    OCACommand *option = [self.options objectAtIndex:recoveryOptionIndex];
    [option sendValue:error];
    
	return YES; // We don't have mechanism to report this.
}


- (void)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex delegate:(id)delegate didRecoverSelector:(SEL)didRecoverSelector contextInfo:(void *)contextInfo {
	OCACommand *option = [self.options objectAtIndex:recoveryOptionIndex];
    [option sendValue:error];
    
    void (*didRecoverMessage)(id, SEL, BOOL, void *) = (typeof(didRecoverMessage))objc_msgSend;
	didRecoverMessage(delegate, didRecoverSelector, YES, contextInfo);
    // ... don't ask me.
}





@end


