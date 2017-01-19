//
//  LandlordHouseItemModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "LandlordHouseItemModel+CoreData.h"

@implementation LandlordHouseItemModel (CoreData)

+ (LandlordHouseItemModel *)findItemByContractID:(int64_t)contractID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contractId=%lld", contractID];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

@end

@implementation LandlordHouseItemModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"contractId"];
}

@end

@implementation LandlordHouseItemModel (CoreDataHelpers)

@end
