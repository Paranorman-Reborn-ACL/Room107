//
//  RoomModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/6/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RoomModel.h"

@interface RoomModel (CoreData)

+ (RoomModel *)findRoomByID:(int64_t)ID;
+ (NSArray *)findRoomsByHouseID:(int64_t)houseID;
+ (NSArray *)deleteRoomByID:(int64_t)ID;

@end

@interface RoomModel (KVO)

@end

@interface RoomModel (CoreDataHelpers)

@end
