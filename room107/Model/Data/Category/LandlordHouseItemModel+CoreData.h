//
//  LandlordHouseItemModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LandlordHouseItemModel.h"

@interface LandlordHouseItemModel (CoreData)

+ (LandlordHouseItemModel *)findItemByContractID:(int64_t)contractID;

@end

@interface LandlordHouseItemModel (KVO)

@end

@interface LandlordHouseItemModel (CoreDataHelpers)

@end
