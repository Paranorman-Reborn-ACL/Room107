//
//  SixTemplateTableViewCell.h
//  room107
//
//  Created by ningxia on 16/4/12.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat sixTemplateTableViewCellMinHeight = 11 * 2;

@interface SixTemplateTableViewCell : Room107TableViewCell

- (void)setTemplateDataArray:(NSArray *)dataArray;
- (void)setViewDidClickHandler:(void(^)(NSArray *targetURLs))handler;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
