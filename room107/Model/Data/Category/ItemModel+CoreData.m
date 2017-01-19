//
//  ItemModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/7/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ItemModel+CoreData.h"

@implementation ItemModel (CoreData)

+ (NSArray *)findAllItems {
    NSArray *results = [self getObjects];
    
    return results;
}

+ (ItemModel *)findItemByItemID:(int64_t)itemID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", itemID];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

+ (NSArray *)deleteAllItems {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation ItemModel (KVO)

+ (NSArray *)identityPropertyNames {
    //分租的主键为roomId，整租为id
    return [NSArray arrayWithObjects:@"id", @"roomId", nil];
}

@end

@implementation ItemModel (CoreDataHelpers)

@end
