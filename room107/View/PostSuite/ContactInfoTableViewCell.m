//
//  ContactInfoTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ContactInfoTableViewCell.h"
#import "NXIconTextField.h"
#import "NXSwitch.h"

@interface ContactInfoTableViewCell ()

@property (nonatomic, strong) NXSwitch *telephoneSwitch;

@end

@implementation ContactInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        CGFloat textFieldHeight = 60.0f;
        _telephoneTextField = [[NXIconTextField alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], textFieldHeight}];
        _telephoneTextField.enabled = NO;
        [_telephoneTextField setIconString:@"\ue618"];
        _telephoneTextField.clearButtonMode = UITextFieldViewModeNever;
        [self addSubview:_telephoneTextField];
        
        //原生UISwitch的宽和高固定为51、31
        _telephoneSwitch = [[NXSwitch alloc] initWithFrame:(CGRect){CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX] - 51, originY + (textFieldHeight - 31) / 2, 51, 31}];
        [_telephoneSwitch setOn:YES];
        [_telephoneSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_telephoneSwitch];
        
        originY += CGRectGetHeight(_telephoneTextField.bounds) + 1;
        _wechatTextField = [[NXIconTextField alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], textFieldHeight}];
        [_wechatTextField setIconString:@"\ue612"];
        [_wechatTextField setPlaceholder:lang(@"WechatTips")];
        [self.contentView addSubview:_wechatTextField];

        originY += CGRectGetHeight(_wechatTextField.bounds) + 1;
        _qqTextField = [[NXIconTextField alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], textFieldHeight}];
        [_qqTextField setKeyboardType:UIKeyboardTypeEmailAddress];
        [_qqTextField setIconString:@"\ue616"];
        [_qqTextField setPlaceholder:lang(@"QQTips")];
        [self.contentView addSubview:_qqTextField];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, contactInfoTableViewCellHeight);
}

- (void)setTelephone:(NSString *)telephone withOn:(BOOL)on {
    [_telephoneTextField setText:telephone];
    [_telephoneTextField setTextColor:on ? [UIColor room107GrayColorD] : [UIColor room107GrayColorC]];
    [_telephoneSwitch setOn:on];
}

- (void)setTelephone:(NSString *)telephone {
    [_telephoneTextField setText:telephone];
    [_telephoneTextField setTextColor:[UIColor room107GrayColorD]];
}

- (void)setWechat:(NSString *)wechat {
    [_wechatTextField setText:wechat];
}

- (void)setQQ:(NSString *)qq {
    [_qqTextField setText:qq];
}

- (BOOL)isTelephoneOn {
    return [_telephoneSwitch isOn];
}

- (NSString *)telephone {
    return _telephoneTextField.text;
}

- (NSString *)wechat {
    return _wechatTextField.text;
}

- (NSString *)qq {
    return _qqTextField.text;
}

- (IBAction)switchAction:(id)sender {
    NXSwitch *onOffSwitch = (NXSwitch *)sender;
    [_telephoneTextField setTextColor:onOffSwitch.isOn ? [UIColor room107GrayColorD] : [UIColor room107GrayColorC]];
}

@end
