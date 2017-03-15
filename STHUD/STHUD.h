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


@class STHUD;

NS_ENUM(NSUInteger, STHUDState) {
	STHUDStateIndeterminate = 1,
	STHUDStateSuccessful,
	STHUDStateFailed,
};

@protocol STHUDHost <NSObject>
- (STHUD *)hudWithTitle:(NSString *)title;
- (STHUD *)hudWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
@end
@protocol STHUDHostImplementation <NSObject>
- (BOOL)addHUD:(STHUD *)hud;
- (BOOL)removeHUD:(STHUD *)hud;
@end


@interface STHUD : NSObject

+ (void)setDefaultHost:(id<STHUDHostImplementation>)host;

- (id)initWithHost:(id<STHUDHostImplementation>)host;
- (id)initWithHost:(id<STHUDHostImplementation>)host title:(NSString *)title;
- (id)initWithHost:(id<STHUDHostImplementation>)host title:(NSString *)title subtitle:(NSString *)subtitle __attribute__((objc_designated_initializer));

@property (nonatomic,assign) enum STHUDState state;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,assign,getter=isModal) BOOL modal;

- (void)keepActiveForDuration:(NSTimeInterval)duration;

@end


#import <STHUD/STHUDBaseHostView.h>
