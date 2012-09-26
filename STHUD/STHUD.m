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
}

- (id)init {
	if ((self = [super init])) {
		_state = STHUDStateIndeterminate;
		[[STHUDWindow sharedWindow] addHUD:self];
	}
	return self;
}

- (void)dealloc {
	[[STHUDWindow sharedWindow] removeHUD:self];
}

+ (BOOL)automaticallyNotifiesObserversOfState { return NO; }
@synthesize state = _state;
- (void)setState:(enum STHUDState)state {
	if (state != _state) {
		[self willChangeValueForKey:@"state"];
		_state = state;
		[self didChangeValueForKey:@"state"];
	}
}

+ (BOOL)automaticallyNotifiesObserversOfTitle { return NO; }
@synthesize title = _title;
- (void)setTitle:(NSString *)title {
	if (![_title isEqualToString:title]) {
		[self willChangeValueForKey:@"title"];
		_title = [title copy];
		[self didChangeValueForKey:@"title"];
	}
}

+ (BOOL)automaticallyNotifiesObserversOfModal { return NO; }
@synthesize modal = _modal;
- (void)setModal:(BOOL)modal {
	if (_modal != modal) {
		[self willChangeValueForKey:@"modal"];
		_modal = modal;
		[self didChangeValueForKey:@"modal"];
	}
}

@end
