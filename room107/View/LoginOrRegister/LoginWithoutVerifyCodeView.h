//
//  LoginWithoutVerifyCodeView.h
//  room107
//
//  Created by ningxia on 15/7/10.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginWithoutVerifyCodeViewDelegate;

@interface LoginWithoutVerifyCodeView : UIView

@property (nonatomic, weak) id<LoginWithoutVerifyCodeViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame withNickname:(NSString *)nickname;
- (NSString *)password;
- (void)showTips:(NSString *)tips;

@end

@protocol LoginWithoutVerifyCodeViewDelegate <NSObject>

- (void)loginButtonDidClick:(LoginWithoutVerifyCodeView *)loginWithoutVerifyCodeView;
- (void)prevStepButtonDidClick:(LoginWithoutVerifyCodeView *)loginWithoutVerifyCodeView;
- (void)forgetPasswordButtonDidClick:(LoginWithoutVerifyCodeView *)loginWithoutVerifyCodeView;

@end
