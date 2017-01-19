//
//  SimilarHouseTableViewCell.h
//  room107
//
//  Created by ningxia on 15/12/29.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat spaceY = 11;
static CGFloat similarHouseTableViewCellMinHeight = 11 * 2 + 36;

@interface SimilarHouseTableViewCell : Room107TableViewCell

- (void)setRecommendHouses:(NSArray *)houses;
- (void)setViewHouseTagExplanationHandler:(void(^)(NSDictionary *params))handler;
- (void)setSelectHouseHandler:(void(^)(NSArray *houses, NSInteger index))handler;

@end
