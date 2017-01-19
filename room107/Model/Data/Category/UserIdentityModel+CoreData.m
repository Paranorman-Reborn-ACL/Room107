//
//  UserIdentityModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/4.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "UserIdentityModel+CoreData.h"

@implementation UserIdentityModel (CoreData)

+ (UserIdentityModel *)findUserIdentityByidCard:(NSString *)idCard {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idCard=%@", idCard];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

+ (NSArray *)deleteUserIdentityByidCard:(NSString *)idCard {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idCard=%@", idCard];
    NSArray *results = [self deleteObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

+ (NSArray *)deleteUserIdentities {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation UserIdentityModel (KVO)

//必须设置主键，否则表里只能存储一条重复数据
+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"idCard"];
}

@end

@implementation UserIdentityModel (CoreDataHelpers)

@end
