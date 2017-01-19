//
//  PaymentInfoModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/9/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "PaymentInfoModel+CoreData.h"

@implementation PaymentInfoModel (CoreData)

+ (NSArray *)deletePaymentInfos {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation PaymentInfoModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"paymentId"];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"balance"]) {
            [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self setValue:obj forKey:key];
            }];
        } else {
            [self setValue:obj forKey:key];
        }
    }];
}

@end
