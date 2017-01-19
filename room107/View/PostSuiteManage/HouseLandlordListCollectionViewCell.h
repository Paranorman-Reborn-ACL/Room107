//
//  HouseLandlordListCollectionViewCell.h
//  room107
//
//  Created by ningxia on 16/4/21.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 数据模型
 public class SuiteButton extends TemplateUnit {
 
 public String middleText;
 
 public String middleTailText;
 
 public String footText;
 
 public String footSubtext;
 
 public String imageUrl;
 
 }
 */

@interface HouseLandlordListCollectionViewCell : UICollectionViewCell

- (void)setHouseListDataDictionary:(NSDictionary *)dataDic;

@end
