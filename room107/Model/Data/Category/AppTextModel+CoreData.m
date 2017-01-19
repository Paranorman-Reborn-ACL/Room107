//
//  AppTextModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/10/14.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "AppTextModel+CoreData.h"

@implementation AppTextModel (CoreData)

+ (AppTextModel *)findAppTextByID:(NSNumber *)ID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", [ID longLongValue]];
    NSArray *results = [self getObjectsWithPredicate:predicate];
    
    return [results firstObject];
}

+ (NSArray *)findAppTexts {
    NSArray *results = [self getObjects];
    
    return results;
}

+ (NSArray *)deleteAppTexts {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end

@implementation AppTextModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"id"];
}

@end
