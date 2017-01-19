//
//  AppPropertiesModel.h
//  room107
//
//  Created by ningxia on 15/9/14.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface AppPropertiesModel : ManagedObject

@property (nonatomic, retain) NSString * supportPhone; //客服电话
@property (nonatomic, retain) NSNumber * verifyCodeInterval; //验证码等待时间
@property (nonatomic, retain) id orderTypeNames; //订单类型对应名称，List<String>类型，按照下标依次对应一种订单
@property (nonatomic, retain) NSString * newestIosAppVersion; //最新app版本号
@property (nonatomic, retain) NSString * recommendedIosAppVersion; //推荐app版本号（当用户版本低于该版本时，弹出一次升级提示）
@property (nonatomic, retain) NSString * recommendedIosAppUpdateTitle; //推荐升级的标题
@property (nonatomic, retain) NSString * recommendedIosAppUpdateContent; //推荐升级的正文
@property (nonatomic, retain) NSString * supportedIosAppVersion; //支持app版本号（当用户版本低于该版本时，强制升级）
@property (nonatomic, retain) NSString * supportedIosAppUpdateTitle; //强制升级的标题
@property (nonatomic, retain) NSString * supportedIosAppUpdateContent; //强制升级的正文
@property (nonatomic, retain) NSString * popupVersion; //弹窗控制数据版本号（有更新时需要更新popup配置）
@property (nonatomic, retain) NSString * textVersion; //页面文本数据版本号（有更新时需要更新text配置）
@property (nonatomic, retain) NSString * iosAppUrl;
@property (nonatomic, retain) NSNumber * iosRecommendedInterval; //推荐升级弹窗间隔时间（单位毫秒）
@property (nonatomic, retain) NSString * iosStartingAdImg; //开机广告页图片（若为空或无表示跳过广告页）
@property (nonatomic, retain) NSString * defaultMapSearchPosition; //默认坐标
@property (nonatomic, retain) id houseTags; //每个houseTag包含appTargetUrl、color、content、id、imageUrl、title、webTargetUrl
@property (nonatomic, retain) NSString * staticResourceDomain; //来自网络的静态资源文件的domain
@property (nonatomic, retain) NSString * subwayVersion; //地铁数据版本号（有更新时需要更新subway配置）
@property (nonatomic, retain) NSNumber * rapidVerifySwitch; //Boolean，是否支持极速认证的开关，true表示valid，false表示invalid
@property (nonatomic, retain) NSNumber * rapidVerifyAmount; //int，极速认证价格，单位分
@property (nonatomic, retain) id rapidVerifyPicture; //picture类型，极速认证的图片
@property (nonatomic, retain) NSNumber * subscribeRefreshInterval; //单位：ms，找房页搜索结果的刷新间隔
@property (nonatomic, retain) id iosRecommendPaymentTypes; //推荐的支付方式
@property (nonatomic, retain) id iosPaymentTypes; //支持的支付方式，微信支付0，支付宝1，招行5

@end
