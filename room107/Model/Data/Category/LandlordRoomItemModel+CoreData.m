//
//  LandlordRoomItemModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "LandlordRoomItemModel+CoreData.h"

@implementation LandlordRoomItemModel (CoreData)

+ (NSArray *)findAllRooms {
    NSArray *results = [self getObjects];
    
    return results;
}

+ (NSArray *)deleteAllRooms {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation LandlordRoomItemModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"id"];
}

@end

@implementation LandlordRoomItemModel (CoreDataHelpers)

@end
