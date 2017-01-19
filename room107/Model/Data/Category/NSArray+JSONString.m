//
//  NSArray+JSONString.m
//  room107
//
//  Created by ningxia on 15/6/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "NSArray+JSONString.h"

@implementation NSArray (JSONString)

- (NSString *)JSONRepresentationWithPrettyPrint:(BOOL)prettyPrint {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)(prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    if (jsonData == nil) {
        LogError(@"JSONRepresentationWithPrettyPrint: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
