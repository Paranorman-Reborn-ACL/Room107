//
//  HomeInfoModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/9/16.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "HomeInfoModel+CoreData.h"

@implementation HomeInfoModel (CoreData)

+ (HomeInfoModel *)findHomeInfo {
    NSArray *results = [self getObjects];
    
    return results.count > 0 ? results[0] : nil;
}

+ (NSArray *)deleteHomeInfo {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end


@implementation HomeInfoModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"amount"];
}

@end