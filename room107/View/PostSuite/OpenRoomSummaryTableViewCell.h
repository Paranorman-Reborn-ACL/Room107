//
//  OpenRoomSummaryTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/31.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat openRoomSummaryTableViewCellHeight = 105.0f;

@interface OpenRoomSummaryTableViewCell : Room107TableViewCell

- (void)setPrice:(NSNumber *)price;
- (void)setCoverImageURL:(NSString *)url;
- (void)setRoomType:(NSNumber *)type;
- (void)setArea:(NSNumber *)area;
- (void)setOrientation:(NSString *)orientation;

@end
