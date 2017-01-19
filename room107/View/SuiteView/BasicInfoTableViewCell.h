//
//  BasicInfoTableViewCell.h
//  room107
//
//  Created by ningxia on 15/6/25.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room107TableViewCell.h"

static CGFloat basicInfoViewMinHeight = 11 + 36.5 + 11 * 2 + 36;
static CGFloat basicInfoItemHeight = 36;

@interface BasicInfoTableViewCell : Room107TableViewCell

- (void)setName:(NSString *)name;
- (void)setAreaContent:(NSString *)area;
- (void)setFloor:(NSNumber *)floor;
- (void)setOrientation:(NSString *)orientation;

@end
