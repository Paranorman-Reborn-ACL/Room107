//
//  SevenTemplateView.h
//  room107
//
//  Created by ningxia on 16/4/25.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 public class ListFourCard extends BasicCard {
 
 public String text;
 
 public String imageUrl;
 
 public Integer imageType;
 
 public List<String> targetUrl;
 
 public Boolean reddie;
 
 }
 */

@interface SevenTemplateView : UIView

- (id)initWithFrame:(CGRect)frame andTemplateDataDictionary:(NSDictionary *)dataDic;
- (void)setTemplateDataDictionary:(NSDictionary *)dataDic;

@end
