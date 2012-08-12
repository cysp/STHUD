//
//  STHUD.h
//  STHUD
//
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ENUM(NSUInteger, STHUDState) {
	STHUDStateIndeterminate = 1,
	STHUDStateSuccessful,
	STHUDStateFailed,
};


@interface STHUD : NSObject

@property (nonatomic,assign) enum STHUDState state;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign,getter=isModal) BOOL modal;

@end
