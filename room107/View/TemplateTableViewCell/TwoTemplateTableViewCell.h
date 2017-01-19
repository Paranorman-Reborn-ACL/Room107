//
//  TwoTemplateTableViewCell.h
//  room107
//
//  Created by 107间 on 16/4/8.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat twoTemplateTableViewCellHeight = 44.0f;

/*
 public class ListOneCard extends BasicCard {
 
 public String text;
 
 public String subtext;
 
 public String imageUrl;
 
 public Integer imageType;
 
 public Boolean reddie;
 
 public String tailText;
 
 public String tailImageUrl;
 
 public Integer tailImageType;
 
 public List<String> targetUrl;
 
 */
@interface TwoTemplateTableViewCell : Room107TableViewCell

- (void)setTwoTemplateInfo:(NSDictionary *)info;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
