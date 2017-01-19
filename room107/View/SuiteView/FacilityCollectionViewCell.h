//
//  FacilityCollectionViewCell.h
//  room107
//
//  Created by ningxia on 15/6/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacilityCollectionViewCell : UICollectionViewCell

- (void)setIconText:(NSString *)iconText;
- (void)setContent:(NSString *)content;
- (void)didSelect;

@end
