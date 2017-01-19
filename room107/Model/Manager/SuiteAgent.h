//
//  SuiteAgent.h
//  room107
//
//  Created by ningxia on 15/6/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuiteModel.h"
#import "RentedHouseItemModel.h"
#import "LandlordHouseItemModel.h"
#import "SubscribeModel.h"

/**
 * @class SuiteAgent
 *
 * @brief 房源数据及操作Agent类
 *
 *
 */
@interface SuiteAgent : NSObject

+ (instancetype)sharedInstance;

/// 查看联系方式
- (void)getContactWithHouseID:(NSNumber *)houseID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *contact, NSNumber *authStatus))completion;

/// 获取指定ID的房源
- (void)getSuiteByID:(NSNumber *)ID andRentType:(NSUInteger)type completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, SuiteModel *suite))completion;

/// 搜索符合filters的所有房源，total：表示结果个数
- (void)getItemsWithFilter:(NSMutableDictionary *)filter completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items, NSString *position, NSString *total))completion;
/// 地图找房
/*
 position：搜索地址，若没有则是没有找到合适地址
 locationX：搜索地址X坐标，若没有则是无定位坐标
 locationY：搜索地址Y坐标，若没有则是无定位坐标
 alert：boolean，返回结果弹窗标志位，若为true则弹出弹窗
 alertTitle：string，返回结果弹窗title
 alertContent：string，返回结果弹窗content
 total:string，搜索结果总数
*/
- (void)getMapItemsWithFilter:(NSMutableDictionary *)filter completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items, NSString *position, NSString *locationX, NSString *locationY, NSNumber *alert, NSString *alertTitle, NSString *alertContent, NSString *total))completion;

/// 获取精品房子
- (void)getRecommends:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items))completion;

/// 获取订阅结果
- (void)getSubscribes:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items))completion;
/// 获取本地订阅数据
- (NSArray *)getSubscribesFromLocal;

/// 更新订阅房子为已读
- (void)updateSubscribeItemToReadByHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID;

/// 清空已读订阅
- (void)clearAllReadSubscribes;

/// 获取订阅条件
- (void)getSubscribeConditions:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *subscribes))completion;

/// 取消订阅
- (void)cancelSubscribeWithID:(NSNumber *)ID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 更新订阅条件
- (void)updateSubscribeWithFilter:(NSMutableDictionary *)filter completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, SubscribeModel *subscribe))completion;

/// 上报目标房源
- (void)addInterestWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 获取目标房源
- (void)getInterest:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *interestItems, NSDictionary *bottomAd))completion;

/// 举报房源
- (void)reportSuiteWithContent:(NSMutableDictionary *)content completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 删除目标房源
- (void)removeInterestWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 获取租客租住管理列表
- (void)getTenantHouseList:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items))completion;

/// 获取租客租住管理页详情
- (void)getTenantHouseManageWithContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, RentedHouseItemModel *item))completion;

/* 获取房东发房管理页列表
items，表示所有该房东的出租房间，数据类型List<LandlordHouseListItemV2>，字段如下：
houseListItem，房间信息
houseStatus，房间状态，0表示审核中，1表示审核失败，2表示对外出租，3暂不对外，4租住中
displayStatus，房间展示状态
newUpdate，按钮小红点，true为出现
pushNumber，推送次数
viewNumber，浏览次数
interestNumber，收藏次数
requestNumber，申请次数
*/
- (void)getLandlordHouseList:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items))completion;

/* 获取房东出租详情页信息
 item，数据类型LandlordHouseListItemV2
 requests，数据类型List<ContractRequest>，所有合同请求
*/
- (void)getLandlordHouseSuiteByHouseID:houseID andRoomID:roomID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *item, NSArray *requests))completion;

/// 获取房东签约请求列表
- (void)getLandlordContractListWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items, NSArray *expiredItems))completion;

/// 获取房东出租管理详情
- (void)getLandlordHouseManageWithContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, LandlordHouseItemModel *item))completion;

/// 添加合租意向
- (void)addCotenantWithHouseID:(NSNumber *)houseID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 删除合租意向
- (void)removeCotenantWithHouseID:(NSNumber *)houseID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 获取合租人的手机号
- (void)contactCotenantWithHouseID:(NSNumber *)houseID andUserID:(NSNumber *)userID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *telephone))completion;

@end
