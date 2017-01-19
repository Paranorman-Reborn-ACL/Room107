//
//  HouseModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/6/23.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "HouseModel+CoreData.h"

@implementation HouseModel (CoreData)

+ (HouseModel *)findHouseByHouseID:(int64_t)houseID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", houseID];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

@end

@implementation HouseModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"id"];
}

+ (NSDictionary *)dictionaryKeyPathsForPropertyNames {
    return @{
             @"id" : @"id",
             @"rentType" : @"rentType",
             @"province" : @"province",
             @"city" : @"city",
             @"position" : @"position",
             @"status": @"status",
             @"price": @"price",
             @"roomNumber" : @"roomNumber",
             @"hallNumber" : @"hallNumber",
             @"kitchenNumber" : @"kitchenNumber",
             @"toiletNumber" : @"toiletNumber",
             @"floor" : @"floor",
             @"username" : @"username",
             @"houseDescription" : @"description",
             @"facilities" : @"facilities",
             @"name" : @"name",
             @"imageId" : @"imageId",
             @"area" : @"area",
             @"requiredGender" : @"requiredGender",
             @"auditStatus" : @"auditStatus",
             @"locationX" : @"locationX",
             @"locationY" : @"locationY",
             @"contact" : @"contact"
             };
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

@implementation HouseModel (CoreDataHelpers)

@end
