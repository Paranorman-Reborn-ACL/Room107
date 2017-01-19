//
//  MessageInfoModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageInfoModel.h"

@interface MessageInfoModel (CoreData)

+ (MessageInfoModel *)findMessageInfoByID:(int64_t)ID;
+ (NSArray *)deleteMessageInfoByID:(int64_t)ID;

@end


@interface MessageInfoModel (KVO)

@end