//
//  RentStatusTableViewCell.h
//  room107
//
//  Created by ningxia on 15/9/1.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat rentStatusTableViewCellHeight = 100.0f;

@interface RentStatusTableViewCell : Room107TableViewCell

- (void)setSelectRentStatusHandler:(void(^)(NSInteger status))handler;
- (void)setRentStatus:(NSInteger)status;
- (NSInteger)rentStatus;

@end
