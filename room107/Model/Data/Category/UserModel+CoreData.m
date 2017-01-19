//
//  UserModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/6/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "UserModel+CoreData.h"

@implementation UserModel (CoreData)

+ (UserModel *)findUserByUsername:(NSString *)username {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username=%@", username];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

@end

@implementation UserModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"username"];
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

@implementation UserModel (CoreDataHelpers)

@end