//
//  STHUDDemoViewController.m
//  STHUDDemo
//
//  Copyright (c) 2012-2014 Scott Talbot. All rights reserved.
//

@import QuartzCore;

#import "STHUDDemoViewController.h"

#import <STHUD/STHUD.h>

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

	STHUDDemoHostView * const hudHostView = [[STHUDDemoHostView alloc] initWithFrame:view.bounds];
	hudHostView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[view addSubview:hudHostView];
	_hudHostView = hudHostView;

	UITapGestureRecognizer *backgroundTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];

	UITapGestureRecognizer *backgroundDoubleTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
	backgroundDoubleTapGestureRecogniser.numberOfTapsRequired = 2;

	[backgroundTapGestureRecogniser requireGestureRecognizerToFail:backgroundDoubleTapGestureRecogniser];

	[view addGestureRecognizer:backgroundTapGestureRecogniser];
	[view addGestureRecognizer:backgroundDoubleTapGestureRecogniser];
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer {
	STHUD *hud = nil;
	if (recognizer.numberOfTapsRequired == 1) {
	} else {
		hud = [[STHUD alloc] initWithHost:_hudHostView];
	}
	hud.title = @"Connecting";
	hud.modal = YES;

	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		hud.state = STHUDStateSuccessful;
		hud.title = @"Success";
		[hud keepActiveForDuration:3];
	});
}

@end
