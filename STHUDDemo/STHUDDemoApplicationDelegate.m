//
//  STHUDDemoApplicationDelegate.m
//  STHUDDemo
//
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#import "STHUDDemoApplicationDelegate.h"

#import <STHUD/STHUD.h>
#import <STHUD/STHUDDefaultHostView.h>

#import "STHUDDemoViewController.h"


STHUDDemoApplicationDelegate *STHUDDemoSharedApplicationDelegate(void) {
	return UIApplication.sharedApplication.delegate;
}


@interface STHUDDemoRootNavigationController : UINavigationController
@property (nonatomic,strong,readonly) id<STHUDHost> hudHost;
@end


@implementation STHUDDemoApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    STHUDDemoViewController *viewController = [STHUDDemoViewController viewController];

    UINavigationController *navigationController = [[STHUDDemoRootNavigationController alloc] initWithRootViewController:viewController];
    [window setRootViewController:navigationController];

    self.window = window;

    return YES;
}

@synthesize window = _window;
- (void)setWindow:(UIWindow *)window {
    _window = window;
    [_window makeKeyAndVisible];
}

- (id<STHUDHost>)hudHost {
	UIViewController *rootViewController = self.window.rootViewController;
	if ([rootViewController isKindOfClass:[STHUDDemoRootNavigationController class]]) {
		return ((STHUDDemoRootNavigationController *)rootViewController).hudHost;
	}
	return nil;
}

@end


@implementation STHUDDemoRootNavigationController {
@private
	STHUDDefaultHostView *_hudHost;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_hudHost = [[STHUDDefaultHostView alloc] initWithFrame:CGRectZero];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	UIView * const view = self.view;
	CGRect const bounds = view.bounds;
	STHUDDefaultHostView * const hudHost = _hudHost;
	hudHost.frame = bounds;
	hudHost.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[view addSubview:hudHost];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	[self.view bringSubviewToFront:_hudHost];
}

@end
