//
//  ContractRequestModel.h
//  room107
//
//  Created by ningxia on 15/8/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

/*
 public static enum RequestStatus {
 FILLING, CONFIRMING, RENTING, TERMINATED, CLOSE_BY_ADMIN, CLOSE_BY_LANDLORD, CLOSE_BY_TENANT
 }
*/

@interface ContractRequestModel : ManagedObject

@property (nonatomic, retain) NSString * checkinTime;
@property (nonatomic, retain) NSNumber * contractId;
@property (nonatomic, retain) NSString * exitTime;
@property (nonatomic, retain) NSString * tenantName;
@property (nonatomic, retain) NSString * tenantUsername;
@property (nonatomic, retain) NSString * tenantFavicon;
@property (nonatomic, retain) NSString * tenantTelephone;
@property (nonatomic, retain) NSNumber * requestStatus; //FILLING, CONFIRMING, RENTING, TERMINATED, CLOSE_BY_ADMIN, CLOSE_BY_LANDLORD, CLOSE_BY_TENANT
@property (nonatomic, retain) NSNumber * waitOtherContract;
@property (nonatomic, retain) NSNumber * hasNewUpdate;

@end
