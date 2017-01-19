//
//  HouseManageAgent.h
//  room107
//
//  Created by ningxia on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserIdentityModel+CoreData.h"
#import "LandlordSuiteItemModel+CoreData.h"

@interface HouseManageAgent : NSObject

+ (instancetype)sharedInstance;

/// 获取发房相关信息
- (void)getInfoForAddHouseWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *district2UserCount, NSString *telephone, NSString *imageToken, NSString *imageKeyPattern))completion;

/// 获取地址对应订阅人数及头像
- (void)getSubscribeNumberWithPosition:(NSString *)position completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *number, NSArray *subscribes, NSNumber *locationX, NSNumber *locationY))completion;

/// 获取图片上传token（房子图片、房产证）
- (void)getTokenAndImageKeyPatternWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *imageKeyPattern))completion;

/// 上传房源图片
- (void)uploadImagesWithImageKeys:(NSArray *)imageKeys completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *imagesString))completion;

/// 发布房源
- (void)submitSuiteWithSuiteInfo:(NSMutableDictionary *)suiteInfo completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *houseID, NSNumber *number, UserIdentityModel *id, NSString *credentialsImages))completion;

///上传用户账户信息
- (void)updateAccountInfoWithName:(NSString *)name andIDCard:(NSString *)idCard andDebitCard:(NSString *)debitCard completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

///上传房产证信息
- (void)updateCredentialsImagesWithHouseID:(NSNumber *)houseID andCredentialsImages:(NSString *)credentialsImages completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 保存房源草稿
- (LandlordSuiteItemModel *)saveLandlordSuiteItem:(NSMutableDictionary *)houseJSON;


/// 删除房子信息
- (void)deleteHouseJSON;

/// 获取房源草稿
- (NSMutableDictionary *)getHouseJSON;

/// 管理房子
- (void)manageHouseStatusWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *imageToken, NSString *imageKeyPattern, NSMutableDictionary *houseJSON))completion;

/// 填写房间两个价格
- (void)fillPriceWithUnits:(NSMutableArray *)units completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 更新房子信息
- (void)updateHouseWithHouseInfo:(NSMutableDictionary *)houseInfo completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 更新房子信息
- (void)updateRoomWithHouseID:(NSNumber *)houseID andRoomJSON:(NSMutableDictionary *)roomJSON completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *roomID))completion;

/// 更新房子状态
- (void)updateHouseStatusWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID andStatus:(NSNumber *)status completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 获取房间所有图片
- (void)getHouseImagesWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *imageIds, NSString *cover))completion;

/// 更新封面
- (void)updateHouseCoverWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID andImageURL:(NSString *)imageURL completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

@end
