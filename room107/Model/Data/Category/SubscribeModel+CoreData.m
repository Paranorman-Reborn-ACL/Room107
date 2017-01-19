//
//  SubscribeModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SubscribeModel+CoreData.h"

@implementation SubscribeModel (CoreData)

+ (SubscribeModel *)findSubscribeByID:(NSNumber *)ID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%@", ID];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return results.count > 0 ? [results firstObject] : nil;
}

+ (NSArray *)findSubscribes {
    return [self getObjects];
}

+ (NSArray *)deleteSubscribes {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation SubscribeModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"id"];
}

@end

@implementation SubscribeModel (CoreDataHelpers)

@end
