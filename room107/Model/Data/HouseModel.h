//
//  HouseModel.h
//  room107
//
//  Created by ningxia on 15/7/1.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@class ContactModel;

/*
 对应于服务器的HouseItem
 enum RentType {
 
 UNKNOWN, BY_ROOM, BY_HOUSE, BY_ROOM_AND_HOUSE;
 
 }
*/

@interface HouseModel : ManagedObject

@property (nonatomic, retain) NSNumber * area;
@property (nonatomic, retain) NSNumber * auditStatus; //0：可线上签约
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) id facilities;
@property (nonatomic, retain) NSNumber * floor;
@property (nonatomic, retain) NSNumber * hallNumber;
@property (nonatomic, retain) NSNumber * hasImageId;
@property (nonatomic, retain) NSString * houseDescription;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * houseType; //0为普通房，1为安心寓
@property (nonatomic, retain) id imageId;
@property (nonatomic, retain) NSNumber * kitchenNumber;
@property (nonatomic, retain) NSNumber * locationX;
@property (nonatomic, retain) NSNumber * locationY;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * province;
@property (nonatomic, retain) NSNumber * rentType; // 0：未知，1：单间，2：整租，3：不限（返回的rentType为1或2）UNKNOWN, BY_ROOM, BY_HOUSE, BY_ROOM_AND_HOUSE;
@property (nonatomic, retain) NSNumber * requiredGender; // 0：未知，1：男性，2：女性，3：不限
@property (nonatomic, retain) NSNumber * roomNumber;
@property (nonatomic, retain) NSNumber * status; //0：OPEN，1：CLOSED
@property (nonatomic, retain) NSNumber * toiletNumber;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) ContactModel *contact;
@property (nonatomic, retain) NSNumber * contractEnableStatus; //0:online，1:offline
@property (nonatomic, retain) id tagIds; //多个tagId，需要匹配AppProperties的houseTags属性
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSNumber * lastModifiedTime; //发布时间（毫秒数）
@property (nonatomic, retain) id extraFees; //租客自付费用，字符串，见House.EXTRA_FEES常量。所有选中费用以“|”分隔构成整体上传。
@property (nonatomic, retain) NSString * checkinTime; //最早入住时间，string，格式yyyyMMdd

@end
