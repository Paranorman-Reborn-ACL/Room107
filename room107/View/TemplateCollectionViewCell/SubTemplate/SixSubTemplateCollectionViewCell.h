//
//  SixSubTemplateCollectionViewCell.h
//  room107
//
//  Created by ningxia on 16/4/12.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 数据模型
 public class SuiteButton extends TemplateUnit {
 
 public String headImageUrl;
 
 public Integer headImageType;
 
 public String headText;
 
 public String headBackgroundColor;
 
 public String middleText;
 
 public String middleSubtext;
 
 public String middleBackgroundColor;
 
 public String middleTailText;
 
 public String middleTailBackgroundColor;
 
 public String footText;
 
 public String footSubtext;
 
 public String footTailText;
 
 public String imageUrl;
 
 public Integer imageWidth;
 
 public Integer imageHeight;
 
 public List<String> targetUrl;
 
 }
 */

@interface SixSubTemplateCollectionViewCell : UICollectionViewCell

- (void)setTemplateDataDictionary:(NSDictionary *)dataDic;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
