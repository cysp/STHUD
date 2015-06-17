//
//  STHUD.h
//  STHUD
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2014 Scott Talbot. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double STHUDVersionNumber;
FOUNDATION_EXPORT const unsigned char STHUDVersionString[];

#import <STHUD/STHUDBaseHostView.h>
#import <STHUD/STHUDNewShinyHostView.h>


#import "STHUDProtocols.h"


typedef NS_ENUM(NSUInteger, STHUDState) {
	STHUDStateIndeterminate = 1,
	STHUDStateSuccessful,
	STHUDStateFailed,
};

@interface STHUD : NSObject

+ (void)setDefaultHost:(id<STHUDHostImplementation>)host;

- (id)initWithHost:(id<STHUDHostImplementation>)host;
- (id)initWithHost:(id<STHUDHostImplementation>)host title:(NSString *)title __attribute__((objc_designated_initializer));

@property (nonatomic,assign) enum STHUDState state;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign,getter=isModal) BOOL modal;

- (void)keepActiveForDuration:(NSTimeInterval)duration;

@end
