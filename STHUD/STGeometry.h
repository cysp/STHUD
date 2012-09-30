//
//  STGeometry.h
//  STHUD
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>


CGPoint STPointIntegral(CGPoint point);

enum {
    STRectAlignXLeft   = 0x01,
    STRectAlignXCenter = 0x02,
    STRectAlignXRight  = 0x03,
    STRectAlignYTop    = 0x10,
    STRectAlignYCenter = 0x20,
    STRectAlignYBottom = 0x30,
};
typedef unsigned int STRectAlignOptions;

CGRect STRectAlign(CGRect outer, CGRect rect, STRectAlignOptions options);
CGRect STRectCenter(CGRect outer, CGRect rect);


CGPathRef STRoundedRectPathCreate(CGRect rect, CGFloat cornerRadius);
