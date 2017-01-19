//
//  HouseListItemModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "HouseListItemModel+CoreData.h"

@implementation HouseListItemModel (CoreData)

+ (HouseListItemModel *)findItemByID:(NSNumber *)ID andRoomID:(NSNumber *)roomID {
    NSString *username = platformKey;
    if ([[AppClient sharedInstance] isLogin]) {
        username = [[AppClient sharedInstance] username];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username=%@ and id=%d", username, [ID intValue]];
    if (roomID != 0) {
        predicate = [NSPredicate predicateWithFormat:@"username=%@ and id=%d and roomId=%d", username, [ID intValue], [roomID intValue]];
    }
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

+ (void)updateItemToReadByID:(NSNumber *)ID andRoomID:(NSNumber *)roomID {
    NSString *username = platformKey;
    if ([[AppClient sharedInstance] isLogin]) {
        username = [[AppClient sharedInstance] username];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username=%@ and id=%d", username, [ID intValue]];
    if (roomID != 0) {
        predicate = [NSPredicate predicateWithFormat:@"username=%@ and id=%d and roomId=%d", username, [ID intValue], [roomID intValue]];
    }
    NSArray *results = [self getObjectsWithPredicate:predicate];
    HouseListItemModel *houseListItem = [results firstObject];
    if (houseListItem) {
        houseListItem.isRead = @1;
        [houseListItem save];
    }
}

+ (NSArray *)findAllItems {
    NSString *username = platformKey;
    if ([[AppClient sharedInstance] isLogin]) {
        username = [[AppClient sharedInstance] username];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username=%@", username];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return results;
}

+ (NSArray *)findItemsBySubscribe:(NSNumber *)subscribe {
    NSString *username = platformKey;
    if ([[AppClient sharedInstance] isLogin]) {
        username = [[AppClient sharedInstance] username];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username=%@ and isSubscribe=%d", username, [subscribe intValue]];
    //加入排序规则
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"modifiedTime" ascending:NO];
    NSArray *results = [self getObjectsWithSort:sort predicate:predicate];
    
    return results;
}

+ (NSArray *)deleteAllItems {
    NSString *username = platformKey;
    if ([[AppClient sharedInstance] isLogin]) {
        username = [[AppClient sharedInstance] username];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username=%@", username];
    NSArray *results = [self deleteObjectsWithPredicate:predicate];
    
    return results;
}

+ (NSArray *)deleteAllSearchItems {
    NSString *username = platformKey;
    if ([[AppClient sharedInstance] isLogin]) {
        username = [[AppClient sharedInstance] username];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username=%@ and isSubscribe=%@", username,  @0];
    NSArray *results = [self deleteObjectsWithPredicate:predicate];
    
    return results;
}

+ (void)clearAllReadSubscribes {
    NSString *username = platformKey;
    if ([[AppClient sharedInstance] isLogin]) {
        username = [[AppClient sharedInstance] username];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username=%@ and isSubscribe=%@ and isRead=%@", username, @1, @1];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    for (HouseListItemModel *houseListItem in results) {
        if (houseListItem) {
            houseListItem.isSubscribe = @0;
            [houseListItem save];
        }
    }
}

@end

@implementation HouseListItemModel (KVO)

+ (NSArray *)identityPropertyNames {
    //分租的主键为roomId，整租为id，增加username
    return [NSArray arrayWithObjects:@"id", @"roomId", @"username", nil];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"description"]) {
            [self setValue:obj forKey:@"houseDescription"];
        } else {
            [self setValue:obj forKey:key];
        }
    }];
}

@end

@implementation HouseListItemModel (CoreDataHelpers)

@end
