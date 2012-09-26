//
//  STHUD.m
//  STHUD
//
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#import "STHUD.h"

#import "STHUDWindow.h"


@implementation STHUD {
@private
	NSString *_title;
	BOOL _modal;
	NSCountedSet *_selfRetains;
}

- (id)init {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	if ((self = [super init])) {
		_state = STHUDStateIndeterminate;
		_selfRetains = [[NSCountedSet alloc] init];
		[[STHUDWindow sharedWindow] addHUD:self];
	}
	return self;
}

- (void)dealloc {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	[[STHUDWindow sharedWindow] removeHUD:self];
}

+ (BOOL)automaticallyNotifiesObserversOfState { return NO; }
@synthesize state = _state;
- (void)setState:(enum STHUDState)state {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	if (state != _state) {
		[self willChangeValueForKey:@"state"];
		_state = state;
		[self didChangeValueForKey:@"state"];
	}
}

+ (BOOL)automaticallyNotifiesObserversOfTitle { return NO; }
@synthesize title = _title;
- (void)setTitle:(NSString *)title {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	if (![_title isEqualToString:title]) {
		[self willChangeValueForKey:@"title"];
		_title = [title copy];
		[self didChangeValueForKey:@"title"];
	}
}

+ (BOOL)automaticallyNotifiesObserversOfModal { return NO; }
@synthesize modal = _modal;
- (void)setModal:(BOOL)modal {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	if (_modal != modal) {
		[self willChangeValueForKey:@"modal"];
		_modal = modal;
		[self didChangeValueForKey:@"modal"];
	}
}


- (void)keepActiveForDuration:(NSTimeInterval)duration {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	[_selfRetains addObject:self];

	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * (double)NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		[_selfRetains removeObject:self];
	});
}

@end
