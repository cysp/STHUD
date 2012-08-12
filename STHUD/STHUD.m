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

@synthesize state = _state;
@synthesize title = _title;
@synthesize modal = _modal;

@end
