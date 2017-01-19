//
//  FourTemplateTableViewCell.h
//  room107
//
//  Created by ningxia on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat fourTemplateTableViewCellHeight = 64;

@interface FourTemplateTableViewCell : Room107TableViewCell

- (void)setTemplateDataArray:(NSArray *)dataArray;
- (void)setViewDidClickHandler:(void(^)(NSArray *targetURLs))handler;
- (void)setHoldTargetURL:(NSArray *)holdTargetURLs;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
