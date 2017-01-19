//
//  InterestListItemModel.h
//  room107
//
//  Created by ningxia on 15/8/13.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface InterestListItemModel : ManagedObject

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

@property (nonatomic, retain) NSNumber * hasNewUpdate; //按钮小红点，true表示需要显示
@property (nonatomic, retain) NSNumber * buttonType; //按钮类型，0表示可线上签约；1表示不可线上签约；2表示”已租“
@property (nonatomic, retain) NSNumber * hasContract; //该房是否已进入签约流程，1是；0否

@end
