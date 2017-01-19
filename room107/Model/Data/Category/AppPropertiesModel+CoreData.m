//
//  AppPropertiesModel+CoreData.m
//  room107
//
//  Created by ningxia on 15/9/14.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "AppPropertiesModel+CoreData.h"

@implementation AppPropertiesModel (CoreData)

+ (AppPropertiesModel *)findAppProperties {
    NSArray *results = [self getObjects];
    
    return results.count > 0 ? results[0] : nil;
}

+ (NSArray *)deleteAppProperties {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

@end


@implementation AppPropertiesModel (KVO)

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"newestIosAppVersion"];
}

@end
