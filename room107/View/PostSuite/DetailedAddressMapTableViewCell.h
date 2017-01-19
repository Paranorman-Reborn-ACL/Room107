//
//  DetailedAddressMapTableViewCell.h
//  room107
//
//  Created by 107间 on 16/4/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat detailedAddressMapTableViewCellHeight = 350;

@interface DetailedAddressMapTableViewCell : Room107TableViewCell

@property (nonatomic, copy) void(^resetPositionClickHandler)(void);

@end
