//
//  LandlordSuiteItemModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/8/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "LandlordSuiteItemModel+CoreData.h"

@implementation LandlordSuiteItemModel (CoreData)

+ (LandlordSuiteItemModel *)findSuite {
    NSArray *results = [self getObjects];
    
    return results.count > 0 ? results[0] : nil;
}

+ (NSArray *)deleteSuite {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation LandlordSuiteItemModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"id"];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"description"]) {
            [self setValue:obj forKey:@"suiteDescription"];
        } else {
            [self setValue:obj forKey:key];
        }
    }];
}

//将Model对象转换为JSON对象，处理特殊Key值
//- (NSDictionary *)dictionaryWithValuesForAllKeys {
//    NSEntityDescription *entify = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:App.managedObjectContext];
//    NSDictionary *attributes = [entify attributesByName];
//    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
//    [mutableAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        if ([key isEqualToString:@"suiteDescription"]) {
//            [mutableAttributes setObject:obj forKey:@"description"];
//            [mutableAttributes removeObjectForKey:key];
//        }
//    }];
//    attributes = [mutableAttributes copy];
//    
//    return [self dictionaryWithValuesForKeys:attributes.allKeys];
//}

@end

@implementation LandlordSuiteItemModel (CoreDataHelpers)

@end
