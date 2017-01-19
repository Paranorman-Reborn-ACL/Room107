//
//  OneTemplateTableViewCell.h
//  room107
//
//  Created by 107间 on 16/4/15.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

typedef void(^buttonClickHandler)(NSArray *targetURLs);
static CGFloat oneTemplateTableViewCellheight = 64.0f;

/*
 public String text;
 
 public String subtext;
 
 public Boolean reddie;
 
 public String imageUrl;
 
 public Integer imageType;
 
 public List<String> targetUrl;
 
 */
@interface OneTemplateTableViewCell : Room107TableViewCell

- (void)setTemplateDataArray:(NSArray *)dataArray;
- (void)setViewDidClickHandler:(buttonClickHandler)buttonClickHandler;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
