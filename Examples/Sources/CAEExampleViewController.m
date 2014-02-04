//
//  CAEExampleViewController.m
//  Chain Examples
//
//  Created by Martin Kiss on 14.1.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//

#import "CAEExampleViewController.h"





@interface CAEExampleViewController ()


@property (nonatomic, readwrite, assign) BOOL partiallyVisible;
@property (nonatomic, readwrite, assign) BOOL fullyVisible;


@end










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
    components.year = year;
    components.month = month;
    components.day = day;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}





#pragma mark Creating & Loading


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [self.class exampleTitle];
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [detailButton addTarget:self action:@selector(showExampleDetails) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:detailButton];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self setupViews];
    [self setupChains];
}


- (void)showExampleDetails {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Example: %@", [self.class exampleTitle]]
                                message:[NSString stringWithFormat:@"%@\n\n%@\n\nAuthor: %@\nDate: %@",
                                         [self.class exampleSubtitle],
                                         [self.class exampleDescription] ?: @"",
                                         [self.class exampleAuthor],
                                         [formatter stringFromDate:[self.class exampleDate]]]
                               delegate:nil
                      cancelButtonTitle:@"Dismiss"
                      otherButtonTitles:nil] show];
}


- (void)setupViews {
    
}


- (void)setupChains {
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.partiallyVisible = YES;
    self.fullyVisible = NO;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.partiallyVisible = YES;
    self.fullyVisible = YES;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.partiallyVisible = YES;
    self.fullyVisible = NO;
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.partiallyVisible = NO;
    self.fullyVisible = NO;
    
    Class class = self.class;
    OCAWeakify(self);
    [[NSOperationQueue mainQueue] performSelector:@selector(addOperationWithBlock:)
                                       withObject:^{
                                           OCAStrongify(self);
                                           if (self) {
                                               [[[UIAlertView alloc] initWithTitle:@"Memory Leak"
                                                                          message:[NSString stringWithFormat:@"“%@” example was not deallocated after being popped!", [class exampleTitle]]
                                                                         delegate:nil
                                                                cancelButtonTitle:@"Oh 💩!"
                                                                otherButtonTitles:nil] show];
                                           }
                                       }
                                       afterDelay:0.5];
}





@end


