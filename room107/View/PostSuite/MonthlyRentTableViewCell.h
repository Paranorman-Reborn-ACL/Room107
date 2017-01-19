//
//  MonthlyRentTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/19.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"
@class NXIconTextField;

static CGFloat monthlyRentTableViewCellHeight = 120.0f;

@interface MonthlyRentTableViewCell : Room107TableViewCell

@property (nonatomic, strong) NXIconTextField *priceTextField;
- (void)setPrice:(NSNumber *)price;
- (NSNumber *)price;

@property (nonatomic, copy) void(^block)(void);

@end
