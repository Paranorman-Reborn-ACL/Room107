//
//  ContractRequestModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ContractRequestModel+CoreData.h"

@implementation ContractRequestModel (CoreData)

+ (NSArray *)findAllContractRequests {
    NSArray *results = [self getObjects];
    
    return results;
}

+ (NSArray *)deleteAllContractRequests {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation ContractRequestModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"contractId"];
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

@implementation ContractRequestModel (CoreDataHelpers)

@end
