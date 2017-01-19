//
//  LandlordHouseListItemModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LandlordHouseListItemModel.h"

@interface LandlordHouseListItemModel (CoreData)

+ (NSArray *)findAllLandlordHouseListItems;
+ (NSArray *)deleteAllLandlordHouseListItems;

@end

@interface LandlordHouseListItemModel (KVO)

@end

@interface LandlordHouseListItemModel (CoreDataHelpers)

@end
