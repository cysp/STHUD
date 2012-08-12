//
//  STHUDWindow.h
//  STHUD
//
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STHUD.h"


@interface STHUDWindow : UIWindow

+ (instancetype)sharedWindow;

- (void)addHUD:(STHUD *)hud;
- (void)removeHUD:(STHUD *)hud;

@end

