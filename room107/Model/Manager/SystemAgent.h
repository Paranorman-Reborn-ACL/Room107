//
//  SystemAgent.h
//  room107
//
//  Created by ningxia on 15/7/23.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppPropertiesModel+CoreData.h"
#import "HomeInfoModel+CoreData.h"
#import "MessageInfoModel+CoreData.h"
#import "AppTextModel+CoreData.h"
#import "AppPopupModel.h"
@class AppPropertiesModel;

/*
 ERROR CODE：
 int UNLOGIN_CODE = 1000;              //未登录
 int UNVERIFIED_CODE = 1001;          //未认证
 int INVALID_PARAMS_CODE = 1002;  //输入有误
 int DUPLICATED_CODE = 1003;         //数据重复（如多次发房，用户名冲突等）
 int NOT_EXIST_CODE = 1004;           //数据不存在（如不存在该房间，不存在该合同等）
 int EXPIRED_CODE = 1005;               //数据过期，建议刷新
 int BUSINESS_ERROR_CODE = 1006; //业务限制（如查看电话次数限制，取现限制等）
 int INTERNAL_ERROR_CODE = 1007; //未知错误（如服务器异常等）
*/

@interface SystemAgent : NSObject

+ (instancetype)sharedInstance;

/// 意见箱
- (void)feedbackWithMessage:(NSString *)message completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 获取首页数据
- (void)getHomeV3Info:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards))completion;

/// 获取底部栏小红点
- (void)getHomeReddieV3;
- (void)getHomeReddieV3:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *homeReddie))completion;

/// 获取消息列表
- (void)getMessageList:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *messages))completion;
/// 分页获取消息列表
- (void)getMessageListIndexFrom:(NSNumber *)indexFrom indexTo:(NSNumber *)indexTo completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *messages))completion;

/// 获取消息详情
- (void)getMessageDetailWithMessageID:(NSNumber *)messageID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, MessageInfoModel *message))completion;

/// 删除消息
- (void)deleteMessageWithMessageID:(NSNumber *)messageID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;
///删除所有消息
- (void)deleteAllMessageWithType:(NSNumber *)type completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;
//已读所有消息
- (void)cleanAllMessageWithType:(NSNumber *)type completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 以下为每次app打开拉取一下
/// 获取配置
- (void)getPropertiesFromServer;
- (void)getPropertiesFromServer:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, AppPropertiesModel *model))completion;
- (AppPropertiesModel *)getPropertiesFromLocal;

/// 获取文本配置数据
- (void)getTextPropertiesFromServer;
- (NSArray *)getTextPropertiesFromLocal;
- (AppTextModel *)getTextPropertyByID:(NSNumber *)ID;

/// 获取弹窗配置数据
- (void)getPopupPropertiesFromServer;
- (NSArray *)getPopupPropertiesFromLocal;

/// 获取侧边栏小红点
- (void)getAppMenuReddies:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *reddies))completion;

/// 获取地铁配置数据
- (void)getSubwayLines:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *subwayLines))completion;
- (NSArray *)getSubwayLinesFromLocal;

// 获取个人页数据
- (void)getPersonalInfo:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards))completion;

//获取帮助中心页面
- (void)getHelpCenter:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards))completion;

//消息中心
- (void)getMessageCenter:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards))completion;

//消息分类列表
- (void)getMessageSublistWithParams:(NSDictionary *)params complete:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards))completion;

@end
