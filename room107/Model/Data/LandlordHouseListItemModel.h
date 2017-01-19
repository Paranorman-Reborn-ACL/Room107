//
//  LandlordHouseListItemModel.h
//  room107
//
//  Created by ningxia on 15/9/14.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface LandlordHouseListItemModel : ManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) id cover;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * faviconUrl;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * houseType; //0为普通房，1为安心寓
@property (nonatomic, retain) NSNumber * modifiedTime; //时间
@property (nonatomic, retain) NSString * name;   //主卧 次卧
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * rentType; //0：未知，1：单间，2：整租，3：不限
@property (nonatomic, retain) NSNumber * requiredGender; // 0：未知，1：男性，2：女性，3：不限
@property (nonatomic, retain) NSNumber * roomId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * contractEnableStatus; //0:online，1:offline
@property (nonatomic, retain) NSString * houseDescription;
@property (nonatomic, retain) NSNumber * hasCover;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSNumber * isSubscribe;
@property (nonatomic, retain) id tagIds; //多个tagId，需要匹配AppProperties的houseTags属性
@property (nonatomic, retain) NSNumber * isInterest;
@property (nonatomic, retain) NSString * houseName;
@property (nonatomic, retain) NSString * roomName;

@property (nonatomic, retain) NSNumber * contractId;
@property (nonatomic, retain) NSNumber * hasNewUpdate; // 对应于服务器的“newUpdate”，表示是否有更新
@property (nonatomic, retain) NSNumber * houseStatus; //房间状态，0表示审核中，1表示审核失败，2表示对外出租，3暂不对外
@property (nonatomic, retain) NSNumber * contractStep; // 出租流程步骤，0表示审核，1表示待租，2表示签约，3表示出租
@property (nonatomic, retain) NSNumber * buttonType; // 按钮类型，0表示“签约交易”不可点；1表示“签约交易”，跳转到签约请求列表页；2表示“出租管理”，跳转到签约请求列表；3表示“出租管理”，跳转到出租管理详情
@property (nonatomic, retain) NSNumber * rentStatusButton; // 开放关闭按钮类型，0表示按钮为“打开房间”，1表示按钮为“关闭房间”，2表示不显示按钮。

@end
