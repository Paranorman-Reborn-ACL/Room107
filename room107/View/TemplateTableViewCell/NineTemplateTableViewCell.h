//
//  NineTemplateTableViewCell.h
//  room107
//
//  Created by ningxia on 16/4/15.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat nineTemplateTableViewCellHeight = 64;

/*
 数据模型
 public class ListTwoCard extends BasicCard {
 
 public String text;
 
 public String subtext;
 
 public String imageUrl;
 
 public Integer imageType;
 
 public List<String> targetUrl;
 
 public Boolean reddie;
 
 }
 */

@interface NineTemplateTableViewCell : Room107TableViewCell

- (void)setTemplateDataDictionary:(NSDictionary *)dataDic;
- (void)setHoldTargetURL:(NSArray *)holdTargetURLs;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
