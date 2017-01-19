//
//  LoginWithVerifyCodeView.h
//  room107
//
//  Created by ningxia on 15/7/10.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LoginWithVerifyCodeViewTypeGrant = 1000, //第三方登录
    LoginWithVerifyCodeViewTypeRegister, //新用户注册
    LoginWithVerifyCodeViewTypeNewPassword, //新密码
} LoginWithVerifyCodeViewType;

@protocol LoginWithVerifyCodeViewDelegate;

@interface LoginWithVerifyCodeView : UIView

@property (nonatomic, weak) id<LoginWithVerifyCodeViewDelegate> delegate;
@property (nonatomic) LoginWithVerifyCodeViewType type;

- (id)initWithFrame:(CGRect)frame withType:(LoginWithVerifyCodeViewType)type withUsername:(NSString *)username withNickname:(NSString *)nickname;
- (NSString *)password;
- (NSString *)verifyCode;
- (void)showTips:(NSString *)tips;

@end

@protocol LoginWithVerifyCodeViewDelegate <NSObject>

- (void)loginOrRegisterButtonDidClick:(LoginWithVerifyCodeView *)loginWithVerifyCodeView;
- (void)prevStepButtonDidClick:(LoginWithVerifyCodeView *)loginWithVerifyCodeView;
- (void)getVerifyCodeButtonDidClick:(LoginWithVerifyCodeView *)loginWithVerifyCodeView;
- (void)agreeButtonDidClick:(LoginWithVerifyCodeView *)loginWithVerifyCodeView;

@end
