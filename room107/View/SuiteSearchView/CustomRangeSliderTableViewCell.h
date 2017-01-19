//
//  CustomRangeSliderTableViewCell.h
//  room107
//
//  Created by ningxia on 15/12/22.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat customRangeSliderTableViewCellHeight = 100.0f;

@interface CustomRangeSliderTableViewCell : Room107TableViewCell

- (void)setMinValue:(CGFloat)minValue andMaxValue:(CGFloat)maxValue withOffsetY:(CGFloat)offsetY;
- (void)setLeftValue:(CGFloat)leftValue andRightValue:(CGFloat)rightValue;
- (int)leftValue;
- (int)rightValue;

@end
