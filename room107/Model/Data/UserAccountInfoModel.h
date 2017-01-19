//
//  UserAccountInfoModel.h
//  room107
//
//  Created by Naitong Yu on 15/9/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserAccountInfoModel : ManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * balance;
@property (nonatomic, retain) NSNumber * balanceNewUpdate;
@property (nonatomic, retain) NSNumber * coupon;
@property (nonatomic, retain) NSNumber * couponNewUpdate;
@property (nonatomic, retain) NSNumber * unpaidContractId;
@property (nonatomic, retain) NSNumber * unpaidUserType; //UNKNOWN, TENANT, LANDLORD

@end
