//
//  STHUDDefaultHostView.m
//  STHUD
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.
//

#import <STHUD/STHUDDefaultHostView.h>

#import <STHUD/STHUDDefaultHUDView.h>


static const NSTimeInterval kSTHUDDefaultHostViewHUDViewAnimationDuration = .2f;


@implementation STHUDDefaultHostView {
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
	[hud addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:&_hudViewsByNonretainedHUD];

	STHUDDefaultHUDView * const hudView = [[STHUDDefaultHUDView alloc] initWithHUD:hud];
	hudView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;

	[_hudViewsByNonretainedHUD setObject:hudView forKey:[NSValue valueWithNonretainedObject:hud]];

	hudView.alpha = 0;
	hudView.transform = CGAffineTransformMakeScale(1.25, 1.25);
	[self addSubview:hudView];
	[UIView animateWithDuration:kSTHUDDefaultHostViewHUDViewAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
		hudView.alpha = 1;
		hudView.transform = CGAffineTransformIdentity;
	} completion:nil];

	return YES;
}

- (BOOL)removeHUD:(STHUD *)hud {
	if (![super removeHUD:hud]) {
		return NO;
	}

	[hud removeObserver:self forKeyPath:@"title" context:&_hudViewsByNonretainedHUD];
	[hud removeObserver:self forKeyPath:@"state" context:&_hudViewsByNonretainedHUD];

	id const hudViewKey = [NSValue valueWithNonretainedObject:hud];

	STHUDDefaultHUDView * const hudView = [_hudViewsByNonretainedHUD objectForKey:hudViewKey];

	[_hudViewsByNonretainedHUD removeObjectForKey:hudViewKey];

	[UIView animateWithDuration:kSTHUDDefaultHostViewHUDViewAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
		hudView.alpha = 0;
		hudView.transform = CGAffineTransformMakeScale((CGFloat).666, (CGFloat).666);
	} completion:^(BOOL __unused finished) {
		[hudView removeFromSuperview];
	}];

	return YES;
}


- (void)setModal:(BOOL)modal animated:(BOOL)animated {
	[super setModal:modal animated:animated];

	void(^animations)(void) = ^{
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:(CGFloat)(modal ? .2 : 0 )];
	};
	if (animated) {
		[UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:animations completion:nil];
	} else {
		animations();
	}
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &_hudViewsByNonretainedHUD) {
		STHUD * const hud = object;
		id const hudViewKey = [NSValue valueWithNonretainedObject:hud];
		STHUDDefaultHUDView * const hudView = [_hudViewsByNonretainedHUD objectForKey:hudViewKey];

		if ([@"state" isEqualToString:keyPath]) {
			[hudView setState:[[change objectForKey:NSKeyValueChangeNewKey] unsignedIntegerValue]];
			return;
		}
		if ([@"title" isEqualToString:keyPath]) {
			[hudView setTitle:[change objectForKey:NSKeyValueChangeNewKey]];
			return;
		}
	}

	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
