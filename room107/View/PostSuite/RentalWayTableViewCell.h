//
//  RentalWayTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/19.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"
@class NXIconTextField;

static CGFloat rentalWayTableViewCellHeight = 220.0f;

@interface RentalWayTableViewCell : Room107TableViewCell

@property (nonatomic, strong) NXIconTextField *priceTextField;
@property (nonatomic, copy) void (^showOrNotDiscount)(BOOL);

- (void)setSelectRentTypeHandler:(void(^)(NSInteger type))handler;
- (void)setRentType:(NSInteger)rentType;
- (void)setPrice:(NSNumber *)price;
- (void)setRequiredGender:(NSInteger)requiredGender;
- (NSInteger)rentType;
- (NSNumber *)price;
- (NSInteger)requiredGender;

@end
