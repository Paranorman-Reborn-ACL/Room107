//
//  FullAddressTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"
@class CustomTextField;

static CGFloat fullAddressTableViewCellMinHeight = 120.0f;
static CGFloat fullAddressTableViewCellHeight = 185.0f;

@interface FullAddressTableViewCell : Room107TableViewCell

@property (nonatomic, strong) CustomTextField *fullAddressTextField;
@property (nonatomic, copy) void(^cellBlock)(void);
- (void)setTextFieldDidEndEditingHandler:(void(^)(NSString *text))handler;
- (void)setCountOfSubscriber:(NSString *)count;
- (void)setPosition:(NSString *)position;
- (NSString *)position;
- (void)setAddressPlaceholder:(NSString *)placeholder;
- (void)setAddressShouldBeginEditingHandler:(void(^)())handler;

@end
