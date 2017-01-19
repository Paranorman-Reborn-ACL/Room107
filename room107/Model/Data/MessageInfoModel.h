//
//  MessageInfoModel.h
//  room107
//
//  Created by ningxia on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface MessageInfoModel : ManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * timestamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) id cards;
@property (nonatomic, retain) id buttons;

/*
 时间的格式均为yyyyMMddHHmmss
 
 Card为卡片，字段如下：
 Integer template;
 List<String> values;
 
 template目前有两种
 0表示LIST_ONE类型，values参数不定长的偶数个，分别为key0,value0,key1,value1...
 1表示PRICE_ONE类型，values参数为固定的5个：priceTitle, price, reasonTitle, reason, time
 
 Button为按钮，字段如下：
 Integer style;
 String name;
 String uri;
 String alert;
 Integer targetType;
 String successNote;
 Map<String, String> params;
 
 style表示按钮样式，目前有两种，0为MAIN主按钮，按钮绿色底；1为ASSITANT辅助按钮，无按钮底色
 alert表示点击按钮后的提示文字，若没有则直接跳转，否则弹出确定/取消并展示该文字
 targetType表示跳转类型，目前有两种，0为REDIRECT，根据uri跳转到响应页面；1为BACKGRAND，根据uri启动后台任务，成功后展示successNote
 */

@end
