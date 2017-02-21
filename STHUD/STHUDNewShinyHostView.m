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
static const NSTimeInterval kSTHUDNewShinyHostViewHUDViewChangeAnimationDuration = 1./4.;
static const NSTimeInterval kSTHUDNewShinyHostViewHUDViewDismissalAnimationDuration = 1./8.;


static CGSize const STHUDNewShinyHUDViewNaturalSize = (CGSize){ .width = 80, .height = 80 };
static CGSize const STHUDNewShinyHUDViewWithDisplayTextNaturalSize = (CGSize){ .width = 160, .height = 80 };
static UIEdgeInsets const STHUDNewShinyHUDViewLabelInsets = (UIEdgeInsets){.top = -2, .left = 12, .bottom = 12 , .right = 12};

@interface STHUDNewShinyHUDView : UIView
@end

@implementation STHUDNewShinyHUDView {
@private
	CAShapeLayer *_activityIndicatorLayer;
	UILabel *_titleLabel;
}
- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		CGRect const bounds = self.bounds;

		UIView * const backgroundView = [[UIView alloc] initWithFrame:bounds];
		backgroundView.backgroundColor = [UIColor colorWithWhite:(CGFloat).975 alpha:(CGFloat).975];
		backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		backgroundView.layer.cornerRadius = 6;
		backgroundView.layer.shadowOpacity = (float)(1./3.);
		backgroundView.layer.shadowOffset = CGSizeZero;
		backgroundView.layer.shadowRadius = 6;
		{
			CGColorRef const strokeColor = [UIColor colorWithWhite:(CGFloat).2 alpha:1].CGColor;
			backgroundView.layer.shadowColor = strokeColor;
			(void)strokeColor;
		}
		[self addSubview:backgroundView];

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
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		_titleLabel.font = [UIFont systemFontOfSize:14];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor darkGrayColor];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
		_titleLabel.numberOfLines = 0;
		[self addSubview:_titleLabel];

		[self.layer addSublayer:activityIndicatorLayer];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGRect const bounds = self.bounds;

	CAShapeLayer * const activityIndicatorLayer = _activityIndicatorLayer;
	CGRect activityScratch;
	CGRect scratch;
	CGRectDivide(bounds, &activityScratch, &scratch, STHUDNewShinyHUDViewNaturalSize.height, CGRectMinYEdge);
	CGRect const activityIndicatorRect = STRectAlign(activityScratch, (CGRect){ .size = STHUDNewShinyHUDViewNaturalSize }, STRectAlignXCenter|STRectAlignYCenter);
	activityIndicatorLayer.frame = activityIndicatorRect;
	
	_titleLabel.frame = UIEdgeInsetsInsetRect(scratch, STHUDNewShinyHUDViewLabelInsets);
}

- (void)setTitle:(NSString *)title {
	_titleLabel.text = title;
	_titleLabel.alpha = title.length > 0 ? 1 : 0;
}

- (CGSize)intrinsicContentSize {
	if (_titleLabel.text.length == 0) {
		return STHUDNewShinyHUDViewNaturalSize;
	}
	CGFloat const width = STHUDNewShinyHUDViewWithDisplayTextNaturalSize.width - STHUDNewShinyHUDViewLabelInsets.left * 2;
	NSDictionary * const attributes = @{NSFontAttributeName : _titleLabel.font};
	CGSize size = [_titleLabel.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
	CGFloat const totalHeight = STHUDNewShinyHUDViewWithDisplayTextNaturalSize.height + size.height + STHUDNewShinyHUDViewLabelInsets.top + STHUDNewShinyHUDViewLabelInsets.bottom;
	return CGSizeMake(STHUDNewShinyHUDViewWithDisplayTextNaturalSize.width, totalHeight);
}

- (void)didMoveToWindow {
	UIWindow * const window = self.window;
	CAShapeLayer * const activityIndicatorLayer = _activityIndicatorLayer;
	if (!window) {
		[activityIndicatorLayer removeAnimationForKey:@"animation"];
		return;
	}
	CGFloat const hairlineWidth = (CGFloat)(1. / ((window.screen.scale > 0) ? window.screen.scale : 1));
	activityIndicatorLayer.lineWidth = 3 * hairlineWidth;

	CABasicAnimation * const animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.byValue = @(2 * M_PI);
	animation.duration = 1 + 2./3.;
	animation.repeatCount = HUGE_VALF;
	animation.fillMode = kCAFillModeBoth;
	[activityIndicatorLayer addAnimation:animation forKey:@"animation"];
}

- (void)tintColorDidChange {
	[super tintColorDidChange];

	UIColor * const tintColor = self.tintColor;
	if (tintColor) {
		_activityIndicatorLayer.strokeColor = tintColor.CGColor;
	}
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
	[hud addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:&_hudViewsByNonretainedHUD];

	
	STHUDNewShinyHUDView * const hudView = [[STHUDNewShinyHUDView alloc] initWithFrame:CGRectZero];
	[hudView setTitle:hud.title];
	[self updateHudFrameSize:hudView];

	[_hudViewsByNonretainedHUD setObject:hudView forKey:[NSValue valueWithNonretainedObject:hud]];

	hudView.alpha = 0;
	[self addSubview:hudView];
	[UIView animateWithDuration:kSTHUDNewShinyHostViewHUDViewAppearanceAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
		hudView.alpha = 1;
	} completion:nil];

	return YES;
}

- (void)updateHudFrameSize:(STHUDNewShinyHUDView *)hudView {
	CGRect const bounds = self.bounds;
	CGSize const hudViewSize = [hudView intrinsicContentSize];
	CGRect hudViewRect = STRectAlign(bounds, (CGRect){ .size = hudViewSize }, STRectAlignXCenter|STRectAlignYCenter);
	[UIView performWithoutAnimation:^{
		hudView.frame = hudViewRect;
	}];
}

- (BOOL)removeHUD:(STHUD *)hud {
	if (![super removeHUD:hud]) {
		return NO;
	}

	id const hudViewKey = [NSValue valueWithNonretainedObject:hud];
	[hud removeObserver:self forKeyPath:@"title" context:&_hudViewsByNonretainedHUD];

	STHUDNewShinyHUDView * const hudView = [_hudViewsByNonretainedHUD objectForKey:hudViewKey];

	[_hudViewsByNonretainedHUD removeObjectForKey:hudViewKey];

	[UIView animateWithDuration:kSTHUDNewShinyHostViewHUDViewDismissalAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
		hudView.alpha = 0;
	} completion:^(BOOL __unused finished) {
		[hudView removeFromSuperview];
	}];

	return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &_hudViewsByNonretainedHUD) {
		STHUD * const hud = object;
		id const hudViewKey = [NSValue valueWithNonretainedObject:hud];
		STHUDNewShinyHUDView * const hudView = [_hudViewsByNonretainedHUD objectForKey:hudViewKey];
		
		if ([@"title" isEqualToString:keyPath]) {
			id const titleObject = [change objectForKey:NSKeyValueChangeNewKey];
			NSString *title = nil;
			if ([titleObject isKindOfClass:[NSString class]]) {
				title = (NSString *)titleObject;
			}
			[UIView animateWithDuration:kSTHUDNewShinyHostViewHUDViewChangeAnimationDuration animations:^{
				[hudView setTitle:title];
				[self updateHudFrameSize:hudView];
			}];
			return;
		}
	}
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
