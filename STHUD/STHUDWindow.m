//
//  STHUDWindow.m
//  STHUD
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#import "STHUDWindow.h"

#import "STHUDView.h"


static STHUDWindow *gSTHUDWindow = nil;

static const NSTimeInterval kSTHUDViewAnimationDuration = .2f;

static CGFloat UIInterfaceOrientationTransformForRotation(UIInterfaceOrientation);
static NSTimeInterval UIInterfaceOrientationAnimationDuration(UIApplication *, UIInterfaceOrientation from, UIInterfaceOrientation to);
static CGRect CGRectScreenBoundsForOrientation(UIScreen *, UIInterfaceOrientation);


@interface STHUDWindow ()
@property (nonatomic,assign,getter=isModal) BOOL modal;
@property (nonatomic,assign) UIInterfaceOrientation interfaceOrientation;
- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation animated:(BOOL)animated;
- (void)recalculateModality;
@end


@implementation STHUDWindow {
@private
	NSMutableSet *_weakHUDs;
	NSMutableDictionary *_hudViewsByNonretainedHUD;
	BOOL _modal;
	UIInterfaceOrientation _interfaceOrientation;
}

+ (void)initialize {
	if (self == [STHUDWindow class]) {
		UIScreen * const mainScreen = [UIScreen mainScreen];
		gSTHUDWindow = [[self alloc] initWithFrame:mainScreen.bounds];
		gSTHUDWindow.hidden = NO;
	}
}


+ (instancetype)sharedWindow {
	return gSTHUDWindow;
}


- (id)initWithFrame:(CGRect)frame {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

    if ((self = [super initWithFrame:frame])) {
		self.windowLevel = (UIWindowLevelNormal + UIWindowLevelAlert) / 2.f;
		self.userInteractionEnabled = NO;

		{
			CFSetCallBacks callbacks = {
				.version = 0,
			};
			CFMutableSetRef weakHUDs = CFSetCreateMutable(NULL, 0, &callbacks);
			_weakHUDs = (__bridge_transfer NSMutableSet *)weakHUDs;
		}

		_hudViewsByNonretainedHUD = [[NSMutableDictionary alloc] init];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationStatusBarOrientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
		UIApplication * const application = [UIApplication sharedApplication];
		[self setInterfaceOrientation:application.statusBarOrientation animated:NO];
    }
    return self;
}

- (void)dealloc {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);
}


- (void)addHUD:(STHUD *)hud {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	if (![_weakHUDs containsObject:hud]) {
		STHUDView * const hudView = [[STHUDView alloc] initWithHUD:hud];
		hudView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;

		[_hudViewsByNonretainedHUD setObject:hudView forKey:[NSValue valueWithNonretainedObject:hud]];
		[_weakHUDs addObject:hud];

		hudView.alpha = 0;
		hudView.transform = CGAffineTransformMakeScale(1.25, 1.25);
		[self addSubview:hudView];
		[UIView animateWithDuration:kSTHUDViewAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
			hudView.alpha = 1;
			hudView.transform = CGAffineTransformIdentity;
		} completion:nil];

		[hud addObserver:self forKeyPath:@"modal" options:NSKeyValueObservingOptionNew context:&_weakHUDs];
		[hud addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:&_weakHUDs];
		[hud addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:&_weakHUDs];

		[self recalculateModality];
	}
}

- (void)removeHUD:(STHUD *)hud {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	if ([_weakHUDs containsObject:hud]) {
		[hud removeObserver:self forKeyPath:@"modal"];
		[hud removeObserver:self forKeyPath:@"title"];
		[hud removeObserver:self forKeyPath:@"state"];

		id const hudViewKey = [NSValue valueWithNonretainedObject:hud];

		STHUDView * const hudView = [_hudViewsByNonretainedHUD objectForKey:hudViewKey];

		[_hudViewsByNonretainedHUD removeObjectForKey:hudViewKey];
		[_weakHUDs removeObject:hud];

		[UIView animateWithDuration:kSTHUDViewAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
			hudView.alpha = 0;
			hudView.transform = CGAffineTransformMakeScale(.666, .666);
		} completion:^(BOOL finished) {
			[hudView removeFromSuperview];
		}];

		[self recalculateModality];
	}
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

@synthesize interfaceOrientation = _interfaceOrientation;
- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	[self setInterfaceOrientation:interfaceOrientation animated:NO];
}
- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation animated:(BOOL)animated {
	if (interfaceOrientation != _interfaceOrientation) {
		UIInterfaceOrientation const fromOrientation = _interfaceOrientation;
		_interfaceOrientation = interfaceOrientation;

		UIApplication * const application = [UIApplication sharedApplication];
		NSTimeInterval const duration = UIInterfaceOrientationAnimationDuration(application, fromOrientation, interfaceOrientation);

		CGFloat const rotation = UIInterfaceOrientationTransformForRotation(interfaceOrientation);
		CGAffineTransform const transform = CGAffineTransformMakeRotation(rotation);
		CGRect const bounds = CGRectScreenBoundsForOrientation([UIScreen mainScreen], interfaceOrientation);

		void(^animations)(void) = ^{
			self.transform = transform;
			self.bounds = bounds;
		};

		if (animated) {
		[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:animations completion:nil];
		} else {
			animations();
		}
	}
}

- (void)applicationStatusBarOrientationWillChange:(NSNotification *)note {
	UIInterfaceOrientation const interfaceOrientation = (UIInterfaceOrientation)[[note.userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey] unsignedIntegerValue];

	[self setInterfaceOrientation:interfaceOrientation animated:YES];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &_weakHUDs) {
		if ([@"modal" isEqualToString:keyPath]) {
			[self recalculateModality];
			return;
		}
		STHUD * const hud = object;
		id const hudViewKey = [NSValue valueWithNonretainedObject:hud];
		STHUDView * const hudView = [_hudViewsByNonretainedHUD objectForKey:hudViewKey];

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

static CGFloat UIInterfaceOrientationTransformForRotation(UIInterfaceOrientation interfaceOrientation) {
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			return 0;
		case UIInterfaceOrientationLandscapeRight:
			return (CGFloat)M_PI_2;
		case UIInterfaceOrientationPortraitUpsideDown:
			return (CGFloat)M_PI;
		case UIInterfaceOrientationLandscapeLeft:
			return (CGFloat)(M_PI + M_PI_2);
	}
	NSCAssert(0, @"unreachable", nil);
	return 0;
}

static NSTimeInterval UIInterfaceOrientationAnimationDuration(UIApplication *application, UIInterfaceOrientation from, UIInterfaceOrientation to) {
	if (from == to) {
		return 0;
	}

	NSTimeInterval const baseDuration = application.statusBarOrientationAnimationDuration;

	if (UIInterfaceOrientationIsPortrait(from) && UIInterfaceOrientationIsPortrait(to)) {
		return baseDuration * 2;
	}

	if (UIInterfaceOrientationIsLandscape(from) && UIInterfaceOrientationIsLandscape(to)) {
		return baseDuration * 2;
	}

	return baseDuration;
}

static CGRect CGRectScreenBoundsForOrientation(UIScreen *screen, UIInterfaceOrientation interfaceOrientation) {
	CGRect const bounds = [screen bounds];
	CGSize const size = bounds.size;

	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		return (CGRect){ .size = { .width = size.height, .height = size.width } };
	}

	return bounds;
}
