//
//  MessageListItemModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageListItemModel.h"

@interface MessageListItemModel (CoreData)

+ (NSArray *)findAllMessageListItems;
+ (NSArray *)deleteAllMessageListItems;
+ (NSArray *)deleteMessageListItemByID:(int64_t)ID;

@end

@interface MessageListItemModel (KVO)

@end