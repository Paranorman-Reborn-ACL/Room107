//
//  SubscribeModel.h
//  room107
//
//  Created by ningxia on 15/8/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface SubscribeModel : ManagedObject

@property (nonatomic, retain) NSNumber *id;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSNumber * roomNumber;//0为不限，1-N表示几室
@property (nonatomic, retain) NSNumber * sortOrder; //0表示默认排序，1表示价格排序，2表示时间排序
@property (nonatomic, retain) NSNumber * rentType; //0：未知，1：单间，2：整租，3：不限
@property (nonatomic, retain) NSNumber * minPrice;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * maxPrice;
@property (nonatomic, retain) NSNumber * lastModifiedTime;

@end
