//
//  FloorTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat floorTableViewCellHeight = 150.0f;

@interface FloorTableViewCell : Room107TableViewCell

- (void)setFloor:(NSNumber *)floor;
- (NSNumber *)floor;

@end
