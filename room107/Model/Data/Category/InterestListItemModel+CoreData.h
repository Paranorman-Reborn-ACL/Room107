//
//  InterestListItemModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/7/27.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "InterestListItemModel.h"

@interface InterestListItemModel (CoreData)

+ (NSArray *)findAllInterestItems;
+ (NSArray *)deleteAllInterestItems;
+ (NSArray *)deleteInterestItemByID:(int64_t)ID;

@end

@interface InterestListItemModel (KVO)

@end

@interface InterestListItemModel (CoreDataHelpers)

@end
