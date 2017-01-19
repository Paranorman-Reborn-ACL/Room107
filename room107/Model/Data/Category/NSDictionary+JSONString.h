//
//  NSDictionary+JSONString.h
//  room107
//
//  Created by ningxia on 15/6/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONString)

- (NSString *)JSONRepresentationWithPrettyPrint:(BOOL)prettyPrint;
- (NSString *)JSONString;

@end
