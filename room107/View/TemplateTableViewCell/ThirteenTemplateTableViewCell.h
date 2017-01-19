//
//  ThirteenTemplateTableViewCell.h
//  room107
//
//  Created by ningxia on 16/4/12.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat thirteenTemplateTableViewCellHeight = 36;

/*
 数据模型
 public class GroupCard extends BasicCard {
 
 public String text;
 
 public String subtext;
 
 public String imageUrl;
 
 public Integer imageType;
 
 }
 */

@interface ThirteenTemplateTableViewCell : Room107TableViewCell

- (void)setTemplateDataDictionary:(NSDictionary *)dataDic;
- (void)setHoldTargetURL:(NSArray *)holdTargetURLs;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
