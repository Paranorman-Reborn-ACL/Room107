//
//  RentedHouseListItemModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RentedHouseListItemModel+CoreData.h"
#import "HouseListItemModel+CoreData.h"

@implementation RentedHouseListItemModel (CoreData)

+ (NSArray *)findAllRentedHouseListItems {
    NSArray *results = [self getObjects];
    
    return results;
}

+ (NSArray *)deleteAllRentedHouseListItems {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation RentedHouseListItemModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"contractId"];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"houseListItem"]) {
            //houseListItem对象需要二次解析
//            [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//                [self setValue:obj forKey:key];
//            }];
            HouseListItemModel *houseListItem = [HouseListItemModel createObjectWithDictionary:obj];
            [self setValue:houseListItem forKey:key];
        } else if ([key isEqualToString:@"newUpdate"]) {
            [self setValue:obj forKey:@"hasNewUpdate"];
        } else {
            [self setValue:obj forKey:key];
        }
    }];
}

@end

@implementation RentedHouseListItemModel (CoreDataHelpers)

@end
