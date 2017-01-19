//
//  LandlordHouseItemModel.h
//  room107
//
//  Created by ningxia on 15/9/16.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface LandlordHouseItemModel : ManagedObject

@property (nonatomic, retain) NSNumber * balance;
@property (nonatomic, retain) NSNumber * balanceCost;
@property (nonatomic, retain) NSString * checkinTime;
@property (nonatomic, retain) NSNumber * contractId;
@property (nonatomic, retain) NSNumber * coupon;
@property (nonatomic, retain) NSNumber * couponCost;
@property (nonatomic, retain) NSString * exitTime;
@property (nonatomic, retain) id expenseOrders;
@property (nonatomic, retain) id historyOrders;
@property (nonatomic, retain) id incomeOrders;
@property (nonatomic, retain) NSNumber * monthlyPrice;
@property (nonatomic, retain) NSNumber * payingType;
@property (nonatomic, retain) NSNumber * paymentCost;
@property (nonatomic, retain) NSNumber * paymentId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * terminatedTime;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * deadline;

@end
