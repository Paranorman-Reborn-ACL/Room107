//
//  RoomModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/6/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RoomModel+CoreData.h"

@implementation RoomModel (CoreData)

+ (RoomModel *)findRoomByID:(int64_t)ID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", ID];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

+ (NSArray *)findRoomsByHouseID:(int64_t)houseID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"houseId=%lld", houseID];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return results;
}

+ (NSArray *)deleteRoomByID:(int64_t)ID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", ID];
    NSArray *results = [self deleteObjectsWithPredicate:predicate];
    
    return results;
}

@end

@implementation RoomModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"id"];
}

@end

@implementation RoomModel (CoreDataHelpers)

@end
