//
//  FiveTemplateTableViewCell.h
//  room107
//
//  Created by ningxia on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat fiveTemplateTableViewCellMinHeight = 58;

/*
 数据模型
 public class ImageTextButton extends TemplateUnit {
 
 public String text;
 
 public String subtext;
 
 public Boolean reddie;
 
 public String imageUrl;
 
 public Integer imageWidth;
 
 public Integer imageHeight;
 
 public List<String> targetUrl;
 
 }
 */

@interface FiveTemplateTableViewCell : Room107TableViewCell

- (void)setTemplateDataArray:(NSArray *)dataArray;
- (void)setScrollImageViewFrame:(CGRect)frame;
- (void)setImageViewDidClickHandler:(void(^)(NSArray *targetURLs))handler;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
