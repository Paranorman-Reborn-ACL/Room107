//
//  SelectPhotosCollectionViewCell.h
//  room107
//
//  Created by ningxia on 16/4/27.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 数据模型
 {
 
 public bool selected;
 
 public String imageUrl;
 
 }
*/

@interface SelectPhotosCollectionViewCell : UICollectionViewCell

- (void)setPhotoDataDictionary:(NSDictionary *)dataDic;

@end
