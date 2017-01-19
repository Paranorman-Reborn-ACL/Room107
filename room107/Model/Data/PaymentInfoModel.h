//
//  PaymentInfoModel.h
//  room107
//
//  Created by ningxia on 15/9/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface PaymentInfoModel : ManagedObject

@property (nonatomic, retain) NSNumber * balance;
@property (nonatomic, retain) NSNumber * balanceCost;
@property (nonatomic, retain) NSNumber * coupon;
@property (nonatomic, retain) NSNumber * couponCost;
@property (nonatomic, retain) NSString * deadline;
@property (nonatomic, retain) id expenseOrders;
@property (nonatomic, retain) id incomeOrders;
@property (nonatomic, retain) NSNumber * paymentCost;
@property (nonatomic, retain) NSNumber * paymentId;
@property (nonatomic, retain) NSNumber * status; //UNPAID, PAYING, PAID, DISCARD
@property (nonatomic, retain) NSString * username;

@end
