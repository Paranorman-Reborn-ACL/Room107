//
//  FourSubTemplateView.h
//  room107
//
//  Created by ningxia on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 数据模型
 public class TextButton extends TemplateUnit {
 
 public String text;
 
 public String subtext;
 
 public Boolean reddie;
 
 public String imageUrl;
 
 public Integer imageType;
 
 public List<String> targetUrl;
 
 }
 */

@interface FourSubTemplateView : UIView

- (void)setTemplateDataDictionary:(NSDictionary *)dataDic;
- (void)setViewDidClickHandler:(void(^)(NSArray *targetURLs))handler;

@end
