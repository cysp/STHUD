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
- (BOOL)addHUD:(STHUD *)hud;
- (BOOL)removeHUD:(STHUD *)hud;
@property (nonatomic,assign,getter=isModal) BOOL modal;
- (void)setModal:(BOOL)modal animated:(BOOL)animated;
@end

@protocol STHUDView <NSObject>
- (id)initWithHUD:(STHUD *)hud;
- (void)setState:(enum STHUDState)state;
- (void)setTitle:(NSString *)title;
@end


@interface STHUD : NSObject

- (id)initWithHost:(id<STHUDHost>)host;

@property (nonatomic,assign) enum STHUDState state;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign,getter=isModal) BOOL modal;

- (void)keepActiveForDuration:(NSTimeInterval)duration;

@end
