//
//  NSString+JSONCategories.m
//  room107
//
//  Created by ningxia on 15/9/23.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "NSString+JSONCategories.h"

@implementation NSString (JSONCategories)

- (id)JSONValue {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) {
        return nil;
    }
    
    return result;
}

@end
