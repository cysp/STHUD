//
//  STHUDBaseHostView.h
//  STHUD
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STHUDProtocols.h"
@class STHUD;


@interface STHUDBaseHostView : UIView<STHUDHost,STHUDHostImplementation>
- (BOOL)addHUD:(STHUD *)hud __attribute__((objc_requires_super));
- (BOOL)removeHUD:(STHUD *)hud __attribute__((objc_requires_super));
@property (nonatomic,assign,getter=isModal,readonly) BOOL modal;
- (void)setModal:(BOOL)modal __attribute__((objc_requires_super));
- (void)setModal:(BOOL)modal animated:(BOOL)animated __attribute__((objc_requires_super));
@end
