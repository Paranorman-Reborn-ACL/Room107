//
//  CustomSwitchTableViewCell.h
//  room107
//
//  Created by ningxia on 15/12/22.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat customSwitchTableViewCellHeight = 70.0f;

@interface CustomSwitchTableViewCell : Room107TableViewCell

- (void)setStringsArray:(NSArray *)strings withOffsetY:(CGFloat)offsetY;
- (void)setSwitchIndex:(NSInteger)index;
- (void)setSwitchIndexDidChangeHandler:(void(^)(NSInteger index))handler;
- (NSInteger)switchIndex;

@end
