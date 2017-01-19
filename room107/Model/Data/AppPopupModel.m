//
//  AppPopupModel.m
//  room107
//
//  Created by ningxia on 15/10/12.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "AppPopupModel.h"

@implementation AppPopupModel

// Insert code here to add functionality to your managed object subclass

+ (NSArray *)findAppPopups {
    NSArray *results = [self getObjects];
    
    return results;
}

+ (NSArray *)deleteAppPopups {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"id"];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"description"]) {
            [self setValue:obj forKey:@"popupDescription"];
        } else {
            [self setValue:obj forKey:key];
        }
    }];
}

@end
