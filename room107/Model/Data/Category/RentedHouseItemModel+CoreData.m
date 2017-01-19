//
//  RentedHouseItemModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/5.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RentedHouseItemModel+CoreData.h"

@implementation RentedHouseItemModel (CoreData)

+ (RentedHouseItemModel *)findItemByContractID:(int64_t)contractID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contractId=%lld", contractID];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

@end

@implementation RentedHouseItemModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"contractId"];
}

@end

@implementation RentedHouseItemModel (CoreDataHelpers)

@end
