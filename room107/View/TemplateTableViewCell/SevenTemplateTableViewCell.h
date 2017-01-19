//
//  SevenTemplateTableViewCell.h
//  room107
//
//  Created by 107间 on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

//模板7 由图标，文字构成 上下左右居中
static CGFloat sevenTemplateTableViewCellHeight = 44.0f;

/*
 public class ListFourCard extends BasicCard {
 
 public String text;
 
 public String imageUrl;
 
 public Integer imageType;
 
 public List<String> targetUrl;
 
 public Boolean reddie;
 
 }
 */
@interface SevenTemplateTableViewCell : Room107TableViewCell

- (void)setSevenTemplateInfo:(NSDictionary *)info;
- (void)settTitleColor:(UIColor *)color;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
