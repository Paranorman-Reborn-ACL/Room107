//
//  ElevenTemplateTableViewCell.h
//  room107
//
//  Created by 107间 on 16/4/19.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

@interface ElevenTemplateTableViewCell : Room107TableViewCell

/*
 public String text;
 
 public String subtext;
 
 public String imageUrl;
 
 public Integer imageWidth;
 
 public Integer imageHeight;
 
 public List<String> targetUrl;
 
 */
- (void)setElevenTemplateInfo:(NSDictionary *)info;
- (void)setHoldTargetURL:(NSArray *)holdTargetURLs;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
