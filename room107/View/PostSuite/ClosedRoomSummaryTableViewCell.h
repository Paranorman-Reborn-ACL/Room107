//
//  ClosedRoomSummaryTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/31.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat closedRoomSummaryTableViewCellHeight = 105.0f;

@interface ClosedRoomSummaryTableViewCell : Room107TableViewCell

@property (nonatomic, copy) void(^closedRoomSummarydidClick)(void);
- (void)setRoomType:(NSNumber *)type;
- (void)setPhotos:(NSArray *)photos;

@end
