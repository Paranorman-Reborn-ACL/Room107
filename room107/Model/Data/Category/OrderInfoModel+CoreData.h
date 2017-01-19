//
//  OrderInfoModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/5.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderInfoModel.h"

@interface OrderInfoModel (CoreData)

+ (NSArray *)findAllOrderInfos;
+ (NSArray *)deleteAllOrderInfos;

@end

@interface OrderInfoModel (KVO)

@end

@interface OrderInfoModel (CoreDataHelpers)

@end
