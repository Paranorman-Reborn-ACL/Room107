//
//  RentedHouseItemModel.h
//  room107
//
//  Created by ningxia on 15/9/11.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface RentedHouseItemModel : ManagedObject

@property (nonatomic, retain) NSString * checkinTime;
@property (nonatomic, retain) NSNumber * contractId;
@property (nonatomic, retain) NSString * deadline;
@property (nonatomic, retain) NSString * exitTime;
@property (nonatomic, retain) id expenseOrders; //待付账单
@property (nonatomic, retain) NSNumber * contractFee;
@property (nonatomic, retain) NSNumber * instalmentFeeRate;
@property (nonatomic, retain) NSNumber * instalmentFee; //分期付款
@property (nonatomic, retain) id historyOrders;
@property (nonatomic, retain) id incomeOrders;
@property (nonatomic, retain) NSNumber * monthlyPrice; //合同租金
@property (nonatomic, retain) NSNumber * payingOrderType;
@property (nonatomic, retain) NSNumber * payingType;
@property (nonatomic, retain) NSNumber * reletStatus; //TO_RELET, RELETING, RELETED, REFUSED，当值为RELETING(1)时，需要出现续租按钮
@property (nonatomic, retain) NSString * terminatedTime;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * coupon; //红包
@property (nonatomic, retain) NSNumber * balance; //余额
@property (nonatomic, retain) NSNumber * paymentId; //判断是否有正在支付账单
@property (nonatomic, retain) NSNumber * balanceCost;
@property (nonatomic, retain) NSNumber * couponCost;
@property (nonatomic, retain) NSNumber * paymentCost;
@property (nonatomic, retain) NSNumber * status;

@end
