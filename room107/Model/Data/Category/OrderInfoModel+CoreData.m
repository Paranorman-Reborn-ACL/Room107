//
//  OrderInfoModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/5.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "OrderInfoModel+CoreData.h"

@implementation OrderInfoModel (CoreData)

+ (NSArray *)findAllOrderInfos {
    NSArray *results = [self getObjects];
    
    return results;
}

+ (NSArray *)deleteAllOrderInfos {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation OrderInfoModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"orderPlanId"];
}

@end

@implementation OrderInfoModel (CoreDataHelpers)

@end
