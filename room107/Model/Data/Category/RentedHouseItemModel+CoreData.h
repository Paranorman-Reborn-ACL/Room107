//
//  RentedHouseItemModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/5.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RentedHouseItemModel.h"

@interface RentedHouseItemModel (CoreData)

+ (RentedHouseItemModel *)findItemByContractID:(int64_t)contractID;

@end

@interface RentedHouseItemModel (KVO)

@end

@interface RentedHouseItemModel (CoreDataHelpers)

@end
