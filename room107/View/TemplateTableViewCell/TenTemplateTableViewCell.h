//
//  TenTemplateTableViewCell.h
//  room107
//
//  Created by 107间 on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat tenTemplateTableViewCellHeight = 64.0f;

@interface TenTemplateTableViewCell : Room107TableViewCell
/*
 public class ListFiveCard extends BasicCard {
 
 public String text;
 
 public String subtext;
 
 public String imageUrl;
 
 public Integer imageType;
 
 public Boolean reddie;
 
 public String headText;
 
 public List<String> targetUrl;
 }
 */
- (void)setTenTemplateInfo:(NSDictionary *)info;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
