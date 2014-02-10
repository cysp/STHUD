//
//  STHUDHostView.m
//  STHUD
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.
//

#import "STHUDHostView.h"


@implementation STHUDHostView {
@private
	NSMutableSet *_weakHUDs;
	BOOL _modal;
}

- (id)initWithFrame:(CGRect)frame {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;

		{
			CFSetCallBacks callbacks = {
				.version = 0,
			};
			CFMutableSetRef weakHUDs = CFSetCreateMutable(NULL, 0, &callbacks);
			_weakHUDs = (__bridge_transfer NSMutableSet *)weakHUDs;
		}
	}
	return self;
}

- (void)dealloc {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);
}


- (BOOL)addHUD:(STHUD *)hud {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	if ([_weakHUDs containsObject:hud]) {
		return NO;
	}
	[_weakHUDs addObject:hud];

	[hud addObserver:self forKeyPath:@"modal" options:NSKeyValueObservingOptionNew context:&_weakHUDs];

	[self recalculateModality];

	return YES;
}

- (BOOL)removeHUD:(STHUD *)hud {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	if (![_weakHUDs containsObject:hud]) {
		return NO;
	}
	[_weakHUDs removeObject:hud];

	[hud removeObserver:self forKeyPath:@"modal" context:&_weakHUDs];

	[self recalculateModality];

	return YES;
}


@synthesize modal = _modal;
- (void)setModal:(BOOL)modal {
	[self setModal:modal animated:NO];
}
- (void)setModal:(BOOL)modal animated:(BOOL)animated {
	if (modal != _modal) {
		_modal = modal;

		void(^animations)(void) = ^{
			self.userInteractionEnabled = _modal;
			self.backgroundColor = [UIColor colorWithWhite:0 alpha:(_modal ? .2 : 0 )];
		};
		if (animated) {
			[UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:animations completion:nil];
		} else {
			animations();
		}
	}
}


- (void)recalculateModality {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	BOOL isModal = NO;
	for (STHUD *hud in _weakHUDs) {
		if ([hud isModal]) {
			isModal = YES;
			break;
		}
	}

	[self setModal:isModal animated:YES];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &_weakHUDs) {
		if ([@"modal" isEqualToString:keyPath]) {
			[self recalculateModality];
			return;
		}
	}

	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
