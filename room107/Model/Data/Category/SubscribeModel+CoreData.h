//
//  SubscribeModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubscribeModel.h"

@interface SubscribeModel (CoreData)

+ (SubscribeModel *)findSubscribeByID:(NSNumber *)ID;
+ (NSArray *)findSubscribes;
+ (NSArray *)deleteSubscribes;

@end

@interface SubscribeModel (KVO)

@end

@interface SubscribeModel (CoreDataHelpers)

@end
