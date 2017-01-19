//
//  HouseAgent.h
//  room107
//
//  Created by ningxia on 15/6/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HouseModel.h"

/**
 * @class HouseAgent
 *
 * @brief 房源数据及操作Agent类
 *
 * TODO: 实现CoreData的本地缓存
 */
@interface HouseAgent : NSObject

+ (instancetype)sharedInstance;

/// 获取指定ID的房源
- (void)getHouseByID:(NSUInteger)houseID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, HouseModel *house))completion;

@end
