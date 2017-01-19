//
//  LandlordSuiteItemModel.h
//  room107
//
//  Created by ningxia on 15/8/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface LandlordSuiteItemModel : ManagedObject

@property (nonatomic, retain) NSNumber * area;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * rentType; //0：未知，1：单间，2：整租，3：不限
@property (nonatomic, retain) NSNumber * district;
@property (nonatomic, retain) NSNumber * roomNumber;
@property (nonatomic, retain) NSNumber * hallNumber;
@property (nonatomic, retain) NSNumber * kitchenNumber;
@property (nonatomic, retain) NSNumber * toiletNumber;
@property (nonatomic, retain) NSNumber * floor;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * suiteDescription;
@property (nonatomic, retain) NSString * facilities;
@property (nonatomic, retain) NSNumber * requiredGender; // 0：未知，1：男性，2：女性，3：不限
@property (nonatomic, retain) NSString * telephone;
@property (nonatomic, retain) NSString * qq;
@property (nonatomic, retain) NSString * wechat;
@property (nonatomic, retain) NSString * hallPhotos;
@property (nonatomic, retain) NSString * kitchenPhotos;
@property (nonatomic, retain) NSString * toiletPhotos;
@property (nonatomic, retain) NSString * otherPhotos;
@property (nonatomic, retain) NSString * extraFees;
@property (nonatomic, retain) NSString * checkinTime;
@property (nonatomic, retain) id rooms;

@end
