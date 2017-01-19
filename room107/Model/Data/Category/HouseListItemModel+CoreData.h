//
//  HouseListItemModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HouseListItemModel.h"

@interface HouseListItemModel (CoreData)

+ (HouseListItemModel *)findItemByID:(NSNumber *)ID andRoomID:(NSNumber *)roomID;
+ (void)updateItemToReadByID:(NSNumber *)ID andRoomID:(NSNumber *)roomID;
+ (NSArray *)findAllItems;
+ (NSArray *)findItemsBySubscribe:(NSNumber *)subscribe;
+ (NSArray *)deleteAllItems;
+ (NSArray *)deleteAllSearchItems;
+ (void)clearAllReadSubscribes;

@end

@interface HouseListItemModel (KVO)

@end

@interface HouseListItemModel (CoreDataHelpers)

@end
