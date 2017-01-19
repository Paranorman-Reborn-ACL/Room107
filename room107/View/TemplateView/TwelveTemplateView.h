//
//  TwelveTemplateView.h
//  room107
//
//  Created by ningxia on 16/4/25.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 数据模型
 public class GroupCard extends BasicCard {
 
 public String text;
 
 public String subtext;
 
 public String imageUrl;
 
 public Integer imageType;
 
 }
 */

@interface TwelveTemplateView : UIView

- (id)initWithFrame:(CGRect)frame andTemplateDataDictionary:(NSDictionary *)dataDic;
- (void)setTemplateDataDictionary:(NSDictionary *)dataDic;

@end
