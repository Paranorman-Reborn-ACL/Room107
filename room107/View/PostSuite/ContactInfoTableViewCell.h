//
//  ContactInfoTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"
@class NXIconTextField;

static CGFloat contactInfoTableViewCellHeight = 250.0f;

@interface ContactInfoTableViewCell : Room107TableViewCell

@property (nonatomic, strong) NXIconTextField *telephoneTextField;
@property (nonatomic, strong) NXIconTextField *wechatTextField;
@property (nonatomic, strong) NXIconTextField *qqTextField;

- (void)setTelephone:(NSString *)telephone withOn:(BOOL)on;
- (void)setTelephone:(NSString *)telephone;
- (void)setWechat:(NSString *)wechat;
- (void)setQQ:(NSString *)qq;
- (BOOL)isTelephoneOn;
- (NSString *)telephone;
- (NSString *)wechat;
- (NSString *)qq;

@end
