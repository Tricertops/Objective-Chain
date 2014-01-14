//
//  CAEAppDelegate.m
//  Chain Examples
//
//  Created by Martin Kiss on 14.1.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//

#import "CAEAppDelegate.h"
#import "CAEListViewController.h"





@implementation CAEAppDelegate





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
    CAEListViewController *listViewController = [[CAEListViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:listViewController];
    
    [self.window makeKeyAndVisible];
    return YES;
}





@end


