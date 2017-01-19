//
//  RoomTypeTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat roomTypeTableViewCellHeight = 100.0f;

@interface RoomTypeTableViewCell : Room107TableViewCell

- (void)setRoomType:(NSInteger)type;
- (NSInteger)roomType;

@end
