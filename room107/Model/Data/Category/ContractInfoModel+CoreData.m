//
//  ContractInfoModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/4.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ContractInfoModel+CoreData.h"

@implementation ContractInfoModel (CoreData)

+ (ContractInfoModel *)findContractInfoByContractID:(int64_t)contractID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contractId=%lld", contractID];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

+ (NSArray *)deleteContractInfoByContractID:(int64_t)contractID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contractId=%lld", contractID];
    NSArray *results = [self deleteObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

+ (NSArray *)deleteContractInfos {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation ContractInfoModel (KVO)

//必须设置主键，否则表里只能存储一条重复数据
+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"contractId"];
}

@end

@implementation ContractInfoModel (CoreDataHelpers)

@end
