//  Copyright (c) 2015 Scott Talbot. All rights reserved.


@class STHUD;

@protocol STHUDHost <NSObject>
- (STHUD *)hudWithTitle:(NSString *)title;
@end

@protocol STHUDHostImplementation <NSObject>
- (BOOL)addHUD:(STHUD *)hud;
- (BOOL)removeHUD:(STHUD *)hud;
@end
