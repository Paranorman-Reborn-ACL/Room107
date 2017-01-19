//
//  LandlordHouseListItemModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "LandlordHouseListItemModel+CoreData.h"

@implementation LandlordHouseListItemModel (CoreData)

+ (NSArray *)findAllLandlordHouseListItems {
    NSArray *results = [self getObjects];
    
    return results;
}

+ (NSArray *)deleteAllLandlordHouseListItems {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation LandlordHouseListItemModel (KVO)

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

@implementation LandlordHouseListItemModel (CoreDataHelpers)

@end
