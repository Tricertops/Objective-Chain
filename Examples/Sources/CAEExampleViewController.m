//
//  CAEExampleViewController.m
//  Chain Examples
//
//  Created by Martin Kiss on 14.1.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//

#import "CAEExampleViewController.h"










@implementation CAEExampleViewController





+ (void)registerExample {
    if (self == [CAEExampleViewController class]) return;
    
    [[CAEExampleViewController mutableSubclasses] addObject:self];
    NSLog(@"Loaded example class %@", self);
}


+ (NSMutableSet *)mutableSubclasses {
    static NSMutableSet *subclasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        subclasses = [[NSMutableSet alloc] init];
    });
    return subclasses;
}


+ (NSArray *)allSubclasses {
    return [[self mutableSubclasses] allObjects];
}





+ (NSString *)exampleTitle {
    return NSStringFromClass(self);
}


+ (NSString *)exampleSubtitle {
    return nil;
}


+ (NSString *)exampleDescription {
    return nil;
}





- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}





@end


