//
//  RentedHouseListItemModel.h
//  room107
//
//  Created by ningxia on 15/9/11.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@class HouseListItemModel;

@interface RentedHouseListItemModel : ManagedObject

@property (nonatomic, retain) NSNumber * contractId;
@property (nonatomic, retain) NSNumber * monthlyPrice; //合同价格
@property (nonatomic, retain) NSString * telephone;
@property (nonatomic, retain) NSNumber * orderPrice; //待付账单
@property (nonatomic, retain) NSString * orderTime; //截止日期
@property (nonatomic, retain) NSString * checkinTime;
@property (nonatomic, retain) NSString * exitTime;
@property (nonatomic, retain) NSNumber * status; //RENTING, RENTED，对应于服务的“status”
@property (nonatomic, retain) NSNumber * hasNewUpdate; // 对应于服务器的“newUpdate”，表示是否有更新
@property (nonatomic, retain) NSString * address;

@property (nonatomic, retain) HouseListItemModel *houseListItem;

@end
