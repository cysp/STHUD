//
//  STHUDDefaultHUDView.h
//  STHUD
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2014 Scott Talbot. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <STHUD/STHUD.h>


@interface STHUDDefaultHUDView : UIView<STHUDView>

- (id)initWithHUD:(STHUD *)hud;

- (void)setState:(enum STHUDState)state;
- (void)setTitle:(NSString *)title;

@end
