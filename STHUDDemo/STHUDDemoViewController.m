//
//  STHUDDemoViewController.m
//  STHUDDemo
//
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#import "STHUDDemoViewController.h"

#import "STHUD.h"


@interface STHUDDemoViewController ()
- (IBAction)viewTapped;
@end


@implementation STHUDDemoViewController

+ (id)viewController {
    return [[self alloc] initWithNibName:nil bundle:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    self.view = view;
    view.backgroundColor = [UIColor whiteColor];

    UITapGestureRecognizer *backgroundTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [view addGestureRecognizer:backgroundTapGestureRecogniser];
}

- (void)viewTapped {
    STHUD *hud = [[STHUD alloc] init];
	hud.title = @"Connecting";
	hud.modal = YES;

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		hud.state = STHUDStateSuccessful;
		hud.title = @"Success";
    });
}

@end
