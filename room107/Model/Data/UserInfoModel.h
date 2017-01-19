//
//  UserInfoModel.h
//  room107
//
//  Created by ningxia on 15/8/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface UserInfoModel : ManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * constellation; //{"白羊", "金牛", "双子", "巨蟹", "狮子", "处女", "天秤", "天蝎", "射手", "摩羯", "水瓶", "双鱼"}
@property (nonatomic, retain) NSString * faviconUrl;
@property (nonatomic, retain) NSString * gender; //{"", "男", "女"}
@property (nonatomic, retain) NSString * major;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * profession;
@property (nonatomic, retain) NSString * school;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * userDescription;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * telephone;
@property (nonatomic, retain) NSNumber * verifyStatus; //UNVERIFIED, VERIFIED_EMAIL, VERIFIED_CREDENTIAL, VERIFIED_RAPID
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * tenantType;
@property (nonatomic, retain) NSNumber * rapidVerifyBase; //int，极速认证总天数
@property (nonatomic, retain) NSNumber * rapidVerifyNumber; //int，极速认证当前天数
@property (nonatomic, retain) NSString * rapidVerifyStart; //String，极速认证开始时间（yyyy/mm/dd）
@property (nonatomic, retain) NSString * rapidVerifyFinish; //String，极速认证结束时间（yyyy/mm/dd）
@property (nonatomic, retain) NSString * wechatFavicon;  //String, 微信头像url
@property (nonatomic, retain) NSString * wechatName;   //String, 微信名称

@end
