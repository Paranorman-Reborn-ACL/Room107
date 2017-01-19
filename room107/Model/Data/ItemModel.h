//
//  ItemModel.h
//  room107
//
//  Created by ningxia on 15/7/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface ItemModel : ManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) id cover;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * faviconUrl;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * roomId;
@property (nonatomic, retain) NSNumber * modifiedTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * rentType; //0：未知，1：单间，2：整租，3：不限
@property (nonatomic, retain) NSNumber * status;

@end
