//
//  SuiteSearchCollectionViewCell.h
//  room107
//
//  Created by ningxia on 15/7/3.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HouseListItemModel.h"

@interface SuiteSearchCollectionViewCell : UICollectionViewCell

- (void)setItem:(HouseListItemModel *)item;
- (void)setViewHouseTagExplanationHandler:(void(^)(NSDictionary *params))handler;

@end
