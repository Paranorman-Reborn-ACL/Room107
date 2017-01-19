//
//  ContractInfoModel.h
//  room107
//
//  Created by ningxia on 15/8/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface ContractInfoModel : ManagedObject

@property (nonatomic, retain) NSString * checkinTime;
@property (nonatomic, retain) NSNumber * contractId;
@property (nonatomic, retain) NSString * exitTime;
@property (nonatomic, retain) NSString * landlordIdCard;
@property (nonatomic, retain) NSString * landlordMoreinfo;
@property (nonatomic, retain) NSString * landlordName;
@property (nonatomic, retain) NSString * landlordTelephone;
@property (nonatomic, retain) NSNumber * monthlyPrice;
@property (nonatomic, retain) NSNumber * payingType; //MONTHLY, QUARTERLY, SEMI_ANNUAL, ANNUAL;
@property (nonatomic, retain) NSString * rentAddress;
@property (nonatomic, retain) NSString * tenantIdCard;
@property (nonatomic, retain) NSString * tenantMoreinfo;
@property (nonatomic, retain) NSString * tenantName;
@property (nonatomic, retain) NSString * tenantTelephone;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * credentialsImages;
@property (nonatomic, retain) NSString * contractNumber;
@property (nonatomic, retain) NSNumber * deposit;
@property (nonatomic, retain) NSNumber * contractFee; //单位为“分”
@property (nonatomic, retain) NSNumber * instalmentFeeRate;
@property (nonatomic, retain) NSNumber * instalmentFee; //单位为“分”

@end
