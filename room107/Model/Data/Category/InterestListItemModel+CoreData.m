//
//  InterestListItemModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/7/27.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "InterestListItemModel+CoreData.h"
#import "ItemModel.h"

@implementation InterestListItemModel (CoreData)

+ (NSArray *)findAllInterestItems {
    NSArray *results = [self getObjects];
    
    return results;
}

+ (NSArray *)deleteAllInterestItems {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

+ (NSArray *)deleteInterestItemByID:(int64_t)ID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", ID];
    NSArray *results = [self deleteObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

@end

@implementation InterestListItemModel (KVO)

//必须设置主键，否则表里只能存储一条重复数据
+ (NSArray *)identityPropertyNames {
    //分租的主键为roomId，整租为id
    return [NSArray arrayWithObjects:@"id", @"roomId", nil];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"newUpdate"]) {
            [self setValue:obj forKey:@"hasNewUpdate"];
        } else if ([key isEqualToString:@"description"]) {
            [self setValue:obj forKey:@"houseDescription"];
        } else {
            [self setValue:obj forKey:key];
        }
    }];
}

@end

@implementation InterestListItemModel (CoreDataHelpers)

@end
