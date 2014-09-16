//
//  STHUD.m
//  STHUD
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2014 Scott Talbot. All rights reserved.
//

#import <STHUD/STHUD.h>


static id<STHUDHostImplementation> gSTHUDDefaultHost = nil;


@implementation STHUD {
@private
	id<STHUDHostImplementation> _host;
	NSString *_title;
	BOOL _modal;
	NSCountedSet *_selfRetains;
}

+ (void)setDefaultHost:(id<STHUDHostImplementation>)host {
	gSTHUDDefaultHost = host;
}

- (id)init {
	return [self initWithHost:gSTHUDDefaultHost title:nil];
}
- (id)initWithHost:(id<STHUDHostImplementation>)host {
	return [self initWithHost:host title:nil];
}
- (id)initWithHost:(id<STHUDHostImplementation>)host title:(NSString *)title {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);
	NSParameterAssert(host);
	if ((self = [super init])) {
		_host = host;
		_title = title.copy;
		_state = STHUDStateIndeterminate;
		_selfRetains = [[NSCountedSet alloc] init];
		[_host addHUD:self];
	}
	return self;
}

- (void)dealloc {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);

	[_host removeHUD:self];
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
