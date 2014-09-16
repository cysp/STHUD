//
//  STHUDDemoViewController.m
//  STHUDDemo
//
//  Copyright (c) 2012-2014 Scott Talbot. All rights reserved.
//

@import QuartzCore;

#import "STHUDDemoViewController.h"

#import <STHUD/STHUD.h>

#import "STHUDDemoApplicationDelegate.h"
#import "STHUDDemoHostView.h"


@interface STHUDDemoViewController ()
- (IBAction)viewTapped:(UITapGestureRecognizer *)recognizer;
@end


@implementation STHUDDemoViewController {
@private
	UIView<STHUDHost> *_hudHostView;
}

+ (id)viewController {
	return [[self alloc] initWithNibName:nil bundle:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation __unused)toInterfaceOrientation {
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

	STHUDDemoHostView * const hudHostView = [[STHUDDemoHostView alloc] initWithFrame:view.bounds];
	hudHostView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[view addSubview:hudHostView];
	_hudHostView = hudHostView;

	UITapGestureRecognizer *backgroundTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];

	UITapGestureRecognizer *backgroundDoubleTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
	backgroundDoubleTapGestureRecogniser.numberOfTapsRequired = 2;

	UITapGestureRecognizer *backgroundTripleTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
	backgroundTripleTapGestureRecogniser.numberOfTapsRequired = 3;

	[backgroundTapGestureRecogniser requireGestureRecognizerToFail:backgroundDoubleTapGestureRecogniser];
	[backgroundTapGestureRecogniser requireGestureRecognizerToFail:backgroundTripleTapGestureRecogniser];;

	[backgroundDoubleTapGestureRecogniser requireGestureRecognizerToFail:backgroundTripleTapGestureRecogniser];

	[view addGestureRecognizer:backgroundTapGestureRecogniser];
	[view addGestureRecognizer:backgroundDoubleTapGestureRecogniser];
	[view addGestureRecognizer:backgroundTripleTapGestureRecogniser];
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer {
	STHUD *hud = nil;
	switch (recognizer.numberOfTapsRequired) {
		case 1: {
			hud = [STHUDDemoSharedApplicationDelegate().hudHost hudWithTitle:@"Connecting"];
		} break;
		case 2: {
			hud = [_hudHostView hudWithTitle:@"Connecting"];
		} break;
		case 3: {
			hud = [STHUDDemoSharedApplicationDelegate().shinyHUDHost hudWithTitle:@"Connecting"];
		} break;
	}
	hud.modal = YES;

	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		hud.state = STHUDStateSuccessful;
		hud.title = @"Success";
		[hud keepActiveForDuration:3];
	});
}

@end
