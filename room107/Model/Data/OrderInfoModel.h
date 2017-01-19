//
//  OrderInfoModel.h
//  room107
//
//  Created by ningxia on 15/8/5.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface OrderInfoModel : ManagedObject

@property (nonatomic, retain) NSNumber * orderPlanId;
@property (nonatomic, retain) NSNumber * orderType;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * originPrice;
@property (nonatomic, retain) NSNumber * fee;
@property (nonatomic, retain) NSString * deadline;
@property (nonatomic, retain) NSString * startTime;
@property (nonatomic, retain) NSString * finishTime;

@end
