//
//  CAEExampleViewController.m
//  Chain Examples
//
//  Created by Martin Kiss on 14.1.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//

#import "CAEExampleViewController.h"










@implementation CAEExampleViewController





#pragma mark Registering Subclasses


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





#pragma mark Getting Info about Examples


+ (NSString *)exampleTitle {
    return NSStringFromClass(self);
}


+ (NSString *)exampleSubtitle {
    return nil;
}


+ (NSString *)exampleDescription {
    return nil;
}


+ (NSString *)exampleAuthor {
    return nil;
}


+ (NSDate *)exampleDate {
    return nil;
}


+ (NSDate *)day:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = day;
    components.month = month;
    components.day = year;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}





#pragma mark Creating & Loading


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [self.class exampleTitle];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self setupViews];
    [self setupConnections];
}


- (void)setupViews {
    
}


- (void)setupConnections {
    
}





@end


