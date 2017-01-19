//
//  SubwayLineModel.m
//  room107
//
//  Created by ningxia on 16/1/25.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SubwayLineModel.h"

@implementation SubwayLineModel

// Insert code here to add functionality to your managed object subclass

+ (NSArray *)findSubwayLines {
    NSArray *results = [self getObjects];
    
    return results;
}

+ (NSArray *)deleteSubwayLines {
    NSArray *results = [self deleteObjectsWithPredicate:nil];
    
    return results;
}

+ (NSArray *)identityPropertyNames {
    return [NSArray arrayWithObject:@"name"];
}

@end
