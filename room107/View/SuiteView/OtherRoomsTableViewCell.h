//
//  OtherRoomsTableViewCell.h
//  room107
//
//  Created by ningxia on 15/7/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room107TableViewCell.h"

@interface OtherRoomsTableViewCell : Room107TableViewCell

- (void)setRooms:(NSArray *)rooms;
- (CGFloat)getCellHeightWithRooms:(NSArray *)rooms;

@end
