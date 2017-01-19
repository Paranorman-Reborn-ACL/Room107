//
//  SuiteFacilitiesTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat suiteFacilitiesTableViewCellHeight = 200.0f;

@interface SuiteFacilitiesTableViewCell : Room107TableViewCell

- (void)setSuiteFacilities:(NSString *)suiteFacilities;  //设置选中
- (void)setSourceFacilities:(NSArray *)sourceFacilitiesArray; //设置全集
- (NSString *)suiteFacilities;

@end
