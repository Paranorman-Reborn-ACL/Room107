//
//  ThreeTemplateTableViewCell.h
//  room107
//
//  Created by ningxia on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

/*
 数据模型
 public class ImageButton extends TemplateUnit {
 
 public String imageUrl;
 
 public Integer imageWidth;
 
 public Integer imageHeight;
 
 public Boolean reddie;
 
 public List<String> targetUrl;
 
 }
 */

@interface ThreeTemplateTableViewCell : Room107TableViewCell

- (void)setTemplateDataArray:(NSArray *)dataArray;
- (void)setImageViewDidClickHandler:(void(^)(NSArray *targetURLs))handler;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
