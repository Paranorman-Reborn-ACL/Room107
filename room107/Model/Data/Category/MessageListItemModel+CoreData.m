//
//  MessageListItemModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "MessageListItemModel+CoreData.h"

@implementation MessageListItemModel (CoreData)

+ (NSArray *)findAllMessageListItems {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    NSArray *results = [self getObjectsWithSort:sort];
    
    return results;
}

+ (NSArray *)deleteAllMessageListItems {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

+ (NSArray *)deleteMessageListItemByID:(int64_t)ID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId=%lld", ID];
    NSArray *results = [self deleteObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

@end

@implementation MessageListItemModel (KVO)

//必须设置主键，否则表里只能存储一条重复数据
+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"messageId"];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"newUpdate"]) {
            [self setValue:obj forKey:@"hasNewUpdate"];
        } else {
            [self setValue:obj forKey:key];
        }
    }];
}

@end
