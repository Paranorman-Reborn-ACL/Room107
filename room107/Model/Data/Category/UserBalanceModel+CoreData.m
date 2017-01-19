//
//  UserBalanceModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/5.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "UserBalanceModel+CoreData.h"

@implementation UserBalanceModel (CoreData)

+ (NSArray *)findAllUserBalances {
    NSArray *results = [self getObjects];
    
    return results;
}

+ (NSArray *)deleteAllUserBalances {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation UserBalanceModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"username"];
}

@end

@implementation UserBalanceModel (CoreDataHelpers)

@end
