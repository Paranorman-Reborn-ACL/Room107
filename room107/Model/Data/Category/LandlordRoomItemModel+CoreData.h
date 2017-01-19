//
//  LandlordRoomItemModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LandlordRoomItemModel.h"

@interface LandlordRoomItemModel (CoreData)

+ (NSArray *)findAllRooms;
+ (NSArray *)deleteAllRooms;

@end


@interface LandlordRoomItemModel (KVO)

@end

@interface LandlordRoomItemModel (CoreDataHelpers)

@end