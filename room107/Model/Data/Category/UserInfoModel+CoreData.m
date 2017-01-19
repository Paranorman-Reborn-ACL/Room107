//
//  UserInfoModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "UserInfoModel+CoreData.h"

@implementation UserInfoModel (CoreData)

+ (UserInfoModel *)findUserByID:(int64_t)ID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", ID];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

+ (NSArray *)deleteUserInfo {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

+ (UserInfoModel *)findUserInfo {
    NSArray *results = [self getObjectsWithPredicate:nil];
    
    return [results firstObject];
}

+ (NSArray *)deleteUserByID:(int64_t)ID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", ID];
    NSArray *results = [self deleteObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

+ (void)updateUserSetFaviconURL:(NSString *)url byID:(int64_t)ID {
    if (url) {
        [self createOrUpdateObjectAndSaveWithDictionary:@{@"id":[NSNumber numberWithLongLong:ID], @"faviconUrl":url} completion:^(ManagedObject *object) {
            NSArray *results = [self getObjectsWithPredicate:nil];
        }];
    }
}

@end

@implementation UserInfoModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"id"];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"description"]) {
            [self setValue:obj forKey:@"userDescription"];
        } else {
            [self setValue:obj forKey:key];
        }
    }];
}

@end

@implementation UserInfoModel (CoreDataHelpers)

@end
