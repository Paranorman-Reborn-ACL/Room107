//
//  RentalManageTableViewCell.h
//  room107
//
//  Created by ningxia on 15/7/31.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

@protocol RentalManageTableViewCellDelegate;

@interface RentalManageTableViewCell : Room107TableViewCell

@property (nonatomic, weak) id<RentalManageTableViewCellDelegate> delegate;

- (void)setItemDic:(NSDictionary *)itemDic;
- (void)setNextPaymentMoney:(NSNumber *)money andDate:(NSString *)date;
- (void)setRentedHouseStatus:(NSNumber *)status;
- (void)setNewUpdate:(NSNumber *)newUpdate;

@end

@protocol RentalManageTableViewCellDelegate <NSObject>

- (void)rentalManageButtonDidClick:(RentalManageTableViewCell *)rentalManageTableViewCell;

@end
