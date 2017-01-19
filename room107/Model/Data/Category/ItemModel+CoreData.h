//
//  ItemModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/7/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ItemModel.h"

@interface ItemModel (CoreData)

+ (NSArray *)findAllItems;
+ (ItemModel *)findItemByItemID:(int64_t)itemID;
+ (NSArray *)deleteAllItems;

@end

@interface ItemModel (KVO)

@end

@interface ItemModel (CoreDataHelpers)

@end
