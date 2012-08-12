//
//  STHUDDemoApplicationDelegate.m
//  STHUDDemo
//
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#import "STHUDDemoApplicationDelegate.h"

#import "STHUDDemoViewController.h"


@implementation STHUDDemoApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    STHUDDemoViewController *viewController = [STHUDDemoViewController viewController];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [window setRootViewController:navigationController];

    self.window = window;

    return YES;
}

@synthesize window = _window;
- (void)setWindow:(UIWindow *)window {
    _window = window;
    [_window makeKeyAndVisible];
}

@end
