//
//  HouseModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/6/23.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "HouseModel.h"

@interface HouseModel (CoreData)

+ (HouseModel *)findHouseByHouseID:(int64_t)houseID;

@end

@interface HouseModel (KVO)

@end

@interface HouseModel (CoreDataHelpers)

@end