//
//  HouseFeatureTableViewCell.h
//  room107
//
//  Created by ningxia on 15/12/29.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

@interface HouseFeatureTableViewCell : Room107TableViewCell

- (void)setFeatureTagIDs:(NSArray *)tagIDs;
- (CGFloat)getCellHeightWithTagIDs:(NSArray *)tagIDs;

@end
