//
//  RentedHouseListItemModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RentedHouseListItemModel.h"

@interface RentedHouseListItemModel (CoreData)

+ (NSArray *)findAllRentedHouseListItems;
+ (NSArray *)deleteAllRentedHouseListItems;

@end

@interface RentedHouseListItemModel (KVO)

@end

@interface RentedHouseListItemModel (CoreDataHelpers)

@end
