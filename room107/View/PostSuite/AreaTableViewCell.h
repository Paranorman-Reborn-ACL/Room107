//
//  AreaTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat areaTableViewCellHeight = 130.0f;

@interface AreaTableViewCell : Room107TableViewCell

- (void)setArea:(NSNumber *)area;
- (NSNumber *)area;
- (void)setminValue:(CGFloat)minValue andMaxValue:(CGFloat)maxValue;
@end
