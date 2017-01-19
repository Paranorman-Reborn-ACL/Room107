//
//  RoomSummaryTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat roomSummaryTableViewCellHeight = 85.0f;

@interface RoomSummaryTableViewCell : Room107TableViewCell

- (void)setCoverImageURL:(NSString *)url;
- (void)setRoomType:(NSNumber *)type;
- (void)setArea:(NSNumber *)area;
- (void)setOrientation:(NSString *)orientation;

@end
