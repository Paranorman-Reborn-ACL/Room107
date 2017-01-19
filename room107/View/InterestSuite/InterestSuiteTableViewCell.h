//
//  InterestSuiteTableViewCell.h
//  room107
//
//  Created by ningxia on 16/1/28.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

@protocol InterestSuiteTableViewCellDelegate;

@interface InterestSuiteTableViewCell : Room107TableViewCell

@property (nonatomic, weak) id<InterestSuiteTableViewCellDelegate> delegate;

- (void)setItemDic:(NSDictionary *)itemDic;
- (void)setButtonType:(NSNumber *)type;
- (void)setNewUpdate:(NSNumber *)newUpdate;
- (void)setViewHouseTagExplanationHandler:(void(^)(NSDictionary *params))handler;

@end

@protocol InterestSuiteTableViewCellDelegate <NSObject>

- (void)reportButtonDidClick:(InterestSuiteTableViewCell *)interestSuiteTableViewCell;
- (void)contactOwnerButtonDidClick:(InterestSuiteTableViewCell *)interestSuiteTableViewCell;
- (void)signedDealButtonDidClick:(InterestSuiteTableViewCell *)interestSuiteTableViewCell;
- (void)deleteSuiteButtonDidClick:(InterestSuiteTableViewCell *)interestSuiteTableViewCell;

@end
