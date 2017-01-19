//
//  RoomModel.h
//  room107
//
//  Created by ningxia on 15/6/23.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface RoomModel : ManagedObject

@property (nonatomic, retain) NSNumber * area;
@property (nonatomic, retain) NSNumber * houseId;
@property (nonatomic, retain) id imageIds;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * orientation;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * status; //OPEN, CLOSED
@property (nonatomic, retain) NSNumber * type; // 0：unknown，1：主卧，2：次卧，3：客厅，4：厨房，5：卫生间，6：其他
@property (nonatomic, retain) NSString * username;

@end
