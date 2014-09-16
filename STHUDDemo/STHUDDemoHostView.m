//
//  STHUDDemoHostView.m
//  STHUD
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.
//

#import "STHUDDemoHostView.h"


@interface STHUDDemoHUDView : UIView
@end
@implementation STHUDDemoHUDView
+ (Class)layerClass {
	return [CAShapeLayer class];
}
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		CGRect const bounds = self.bounds;

		CAShapeLayer * const layer = (CAShapeLayer *)self.layer;
		CGFloat const hudCircleDiameter = 120;
		CGRect const hudCircleRect = (CGRect){
			.origin = {
				.x = (CGRectGetWidth(bounds) - hudCircleDiameter) / 2,
				.y = (CGRectGetHeight(bounds) - hudCircleDiameter) / 2,
			},
			.size = {
				.width = hudCircleDiameter,
				.height = hudCircleDiameter,
			},
		};
		CGPathRef path = CGPathCreateWithEllipseInRect(hudCircleRect, NULL);
		layer.path = path;
		CGPathRelease(path), path = NULL;
	}
	return self;
}
- (void)setBackgroundColor:(UIColor *)backgroundColor {
	CAShapeLayer * const layer = (CAShapeLayer *)self.layer;
	layer.fillColor = backgroundColor.CGColor;
}
@end


typedef void(^STHUDDemoCADisplayLinkTrampolineBlock)(CADisplayLink *displayLink);
@interface STHUDDemoCADisplayLinkTrampoline : NSObject
- (id)initWithBlock:(STHUDDemoCADisplayLinkTrampolineBlock)block;
- (void)displayLinkFired:(CADisplayLink *)displayLink;
@end
@implementation STHUDDemoCADisplayLinkTrampoline {
@private
	STHUDDemoCADisplayLinkTrampolineBlock _block;
}
- (instancetype)init {
	return [self initWithBlock:nil];
}
- (id)initWithBlock:(STHUDDemoCADisplayLinkTrampolineBlock)block {
	NSParameterAssert(block);
	if (!block) {
		return nil;
	}
	if ((self = [super init])) {
		_block = [block copy];
	}
	return self;
}
- (void)displayLinkFired:(CADisplayLink *)displayLink {
	_block(displayLink);
}
@end

@interface STHUDDemoHostView ()
@property (nonatomic,assign,getter=st_isVisible,setter=st_setVisible:) BOOL st_visible;
- (void)st_setVisible:(BOOL)visible animated:(BOOL)animated;
@end

@implementation STHUDDemoHostView {
@private
	CADisplayLink *_displayLink;
	STHUDDemoCADisplayLinkTrampoline *_displayLinkTrampoline;
	NSUInteger _numberOfHUDsAttached;
	UIView *_hudView;
	CGFloat _hudR;
	CGFloat _hudG;
	CGFloat _hudB;
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		CGRect const bounds = self.bounds;

		__typeof__(self) __weak wself = self;
		_displayLinkTrampoline = [[STHUDDemoCADisplayLinkTrampoline alloc] initWithBlock:^(CADisplayLink *displayLink) {
			__typeof__(self) const sself = wself;
			[sself displayLinkFired:displayLink];
		}];
		_displayLink = [CADisplayLink displayLinkWithTarget:_displayLinkTrampoline selector:@selector(displayLinkFired:)];
		[_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
		_displayLink.paused = YES;

		_hudView = [[STHUDDemoHUDView alloc] initWithFrame:bounds];
		_hudView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
		[self addSubview:_hudView];
		_hudView.userInteractionEnabled = NO;
		_hudView.alpha = 0;
	}
	return self;
}
- (void)dealloc {
	[_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (BOOL)addHUD:(STHUD *)hud {
	if (![super addHUD:hud]) {
		return NO;
	}
	++_numberOfHUDsAttached;
	BOOL const visible = _numberOfHUDsAttached > 0;
	[self st_setVisible:visible animated:YES];
	return YES;
}

- (BOOL)removeHUD:(STHUD *)hud {
	if (![super removeHUD:hud]) {
		return NO;
	}
	--_numberOfHUDsAttached;
	BOOL const visible = _numberOfHUDsAttached > 0;
	[self st_setVisible:visible animated:YES];
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

- (void)st_setVisible:(BOOL)visible {
	return [self st_setVisible:visible animated:NO];
}
- (void)st_setVisible:(BOOL)visible animated:(BOOL __unused)animated {
	if (visible != _st_visible) {
		_st_visible = visible;

		UIView * const hudView = _hudView;
		[UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
			hudView.alpha = visible ? 1 : 0;
		} completion:^(BOOL __unused finished) {
		}];
		_displayLink.paused = !_st_visible;
	}
}

- (void)displayLinkFired:(CADisplayLink * __unused)displayLink {
	CGFloat const XIncrementR = FLT_EPSILON * 20000;
	CGFloat const XIncrementG = FLT_EPSILON * 30000;
	CGFloat const XIncrementB = FLT_EPSILON * 70000;
   double x;
   _hudR = (CGFloat)modf(_hudR + XIncrementR, &x);
   _hudG = (CGFloat)modf(_hudG + XIncrementG, &x);
   _hudB = (CGFloat)modf(_hudB + XIncrementB, &x);

	UIColor * const hudColor = [UIColor colorWithRed:_hudR green:_hudG blue:_hudB alpha:1];
	_hudView.backgroundColor = hudColor;
}

@end
