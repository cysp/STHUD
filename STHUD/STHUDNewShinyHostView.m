//
//  STHUDNewShinyHostView.m
//  STHUD
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.
//

#import "STHUDNewShinyHostView.h"

#import "STGeometry.h"


static const NSTimeInterval kSTHUDNewShinyHostViewHUDViewAppearanceAnimationDuration = 1./4.;
static const NSTimeInterval kSTHUDNewShinyHostViewHUDViewDismissalAnimationDuration = 1./8.;


static CGSize const STHUDNewShinyHUDViewNaturalSize = (CGSize){ .width = 80, .height = 80 };

@interface STHUDNewShinyHUDView : UIView
@end

@implementation STHUDNewShinyHUDView {
@private
	CAShapeLayer *_activityIndicatorLayer;
}
- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		CGRect const bounds = self.bounds;

		self.backgroundColor = [UIColor colorWithWhite:(CGFloat).975 alpha:(CGFloat).95];
		self.layer.cornerRadius = 6;

		CAShapeLayer * const activityIndicatorLayer = _activityIndicatorLayer = [CAShapeLayer layer];
		activityIndicatorLayer.frame = bounds;
		{
			CGColorRef const strokeColor = [UIColor colorWithWhite:(CGFloat).6 alpha:1].CGColor;
			activityIndicatorLayer.strokeColor = strokeColor;
			(void)strokeColor;
		}
		activityIndicatorLayer.fillColor = NULL;
		activityIndicatorLayer.lineCap = kCALineCapRound;

		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddArc(path, NULL, 40, 40, 20, (CGFloat)(M_PI_4), (CGFloat)(2 * M_PI), false);
		activityIndicatorLayer.path = path;
		CGPathRelease(path), path = NULL;

		[self.layer addSublayer:activityIndicatorLayer];
	}
	return self;
}
- (void)layoutSubviews {
	[super layoutSubviews];

	CGRect const bounds = self.bounds;

	CAShapeLayer * const activityIndicatorLayer = _activityIndicatorLayer;
	activityIndicatorLayer.frame = bounds;
}
- (void)didMoveToWindow {
	UIWindow * const window = self.window;
	CAShapeLayer * const activityIndicatorLayer = _activityIndicatorLayer;
	if (!window) {
		[activityIndicatorLayer removeAnimationForKey:@"animation"];
		return;
	}
	CGFloat const hairlineWidth = (CGFloat)(1. / (window.screen.scale ?: 1));
	activityIndicatorLayer.lineWidth = 3 * hairlineWidth;

	CABasicAnimation * const animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.byValue = @(2 * M_PI);
	animation.duration = 1 + 2./3.;
	animation.repeatCount = HUGE_VALF;
	animation.fillMode = kCAFillModeBoth;
	[activityIndicatorLayer addAnimation:animation forKey:@"animation"];
}
@end


@implementation STHUDNewShinyHostView {
@private
	NSMutableDictionary *_hudViewsByNonretainedHUD;
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_hudViewsByNonretainedHUD = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (BOOL)addHUD:(STHUD *)hud {
	if (![super addHUD:hud]) {
		return NO;
	}

	CGRect const bounds = self.bounds;
	CGRect const hudViewRect = STRectAlign(bounds, (CGRect){ .size = STHUDNewShinyHUDViewNaturalSize }, STRectAlignXCenter|STRectAlignYCenter);
	STHUDNewShinyHUDView * const hudView = [[STHUDNewShinyHUDView alloc] initWithFrame:hudViewRect];
	hudView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;

	[_hudViewsByNonretainedHUD setObject:hudView forKey:[NSValue valueWithNonretainedObject:hud]];

	hudView.alpha = 0;
	[self addSubview:hudView];
	[UIView animateWithDuration:kSTHUDNewShinyHostViewHUDViewAppearanceAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
		hudView.alpha = 1;
	} completion:nil];

	return YES;
}

- (BOOL)removeHUD:(STHUD *)hud {
	if (![super removeHUD:hud]) {
		return NO;
	}

	id const hudViewKey = [NSValue valueWithNonretainedObject:hud];

	STHUDNewShinyHUDView * const hudView = [_hudViewsByNonretainedHUD objectForKey:hudViewKey];

	[_hudViewsByNonretainedHUD removeObjectForKey:hudViewKey];

	[UIView animateWithDuration:kSTHUDNewShinyHostViewHUDViewDismissalAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
		hudView.alpha = 0;
	} completion:^(BOOL __unused finished) {
		[hudView removeFromSuperview];
	}];

	return YES;
}


- (void)setModal:(BOOL)modal animated:(BOOL)animated {
	[super setModal:modal animated:animated];

	void(^animations)(void) = ^{
		self.backgroundColor = [UIColor colorWithWhite:(CGFloat)1 alpha:(CGFloat)(modal ? 1./4. : 0 )];
	};
	if (animated) {
		[UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:animations completion:nil];
	} else {
		animations();
	}
}

@end
