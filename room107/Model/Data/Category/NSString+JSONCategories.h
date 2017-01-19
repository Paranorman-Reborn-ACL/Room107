//
//  NSString+JSONCategories.h
//  room107
//
//  Created by ningxia on 15/9/23.
//  Copyright © 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSONCategories)

// 将JSON格式的NSString转为标准的JSON
- (id)JSONValue;

@end
