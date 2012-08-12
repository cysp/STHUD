//
//  STHUDView.h
//  STHUD
//
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STHUD.h"


@interface STHUDView : UIView

- (id)initWithHUD:(STHUD *)hud;

- (void)setState:(enum STHUDState)state;
- (void)setTitle:(NSString *)title;

@end
