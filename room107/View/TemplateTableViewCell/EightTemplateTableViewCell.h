//
//  EightTemplateTableViewCell.h
//  room107
//
//  Created by ningxia on 16/4/13.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat eightTemplateTableViewCellHeight = 91;

/*
 数据模型
 public class ListThreeCard extends BasicCard {
 
 public String text;
 
 public String subtext;
 
 public String imageUrl;
 
 public Integer imageType;
 
 public Boolean reddie;
 
 public String headText;
 
 public String headBackgroundColor;
 
 public String tailText;
 
 public Boolean isEnable;
 
 public List<String> targetUrl;
 
 public List<String> holdTargetUrl;
 
 }
*/

@interface EightTemplateTableViewCell : Room107TableViewCell

- (void)setTemplateDataDictionary:(NSDictionary *)dataDic;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
