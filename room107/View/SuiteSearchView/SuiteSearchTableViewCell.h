//
//  SuiteSearchTableViewCell.h
//  room107
//
//  Created by ningxia on 16/1/27.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

@interface SuiteSearchTableViewCell : Room107TableViewCell

- (void)setItemDic:(NSDictionary *)itemDic;
- (void)setViewHouseTagExplanationHandler:(void(^)(NSDictionary *params))handler;
- (void)setItemFavoriteHandler:(void(^)())handler;

@end
