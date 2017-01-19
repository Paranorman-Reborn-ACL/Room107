//
//  MessageInfoModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "MessageInfoModel+CoreData.h"

@implementation MessageInfoModel (CoreData)

+ (MessageInfoModel *)findMessageInfoByID:(int64_t)ID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", ID];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return results.count > 0 ? results[0] : nil;
}

+ (NSArray *)deleteMessageInfoByID:(int64_t)ID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", ID];
    NSArray *results = [self deleteObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

@end


@implementation MessageInfoModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"id"];
}

@end