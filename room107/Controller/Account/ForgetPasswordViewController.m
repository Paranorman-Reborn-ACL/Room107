//
//  ForgetPasswordViewController.m
//  room107
//
//  Created by 107间 on 16/3/22.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "CustomTextField.h"
#import "RoundedGreenButton.h"
#import "GetVerifyCodeView.h"
#import "AuthenticationAgent.h"
#import "WXLoginView.h"
#import "WXApi.h"
#import "RegularExpressionUtil.h"

@interface ForgetPasswordViewController ()<GetVerifyCodeViewDelegate>

@property (nonatomic, strong) CustomTextField *phoneNumberTextField; //手机号输入框
@property (nonatomic, strong) CustomTextField *verifyCodeTextField;  //验证码输入框
@property (nonatomic, strong) CustomTextField *passwordTextField; //密码输入框
@property (nonatomic, strong) RoundedGreenButton *confirmButton; //注册按钮
@property (nonatomic, strong) GetVerifyCodeView *getVerifyCodeView; //获取验证码

@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:lang(@"ForgotYourPassword")];
    [self setInputView];
}

- (void)setInputView {
    CGFloat originY = 11.0f;
    CGFloat originX = 22.0f;
    CGFloat textFieldHeight = 44.0f;
    CGFloat viewWidth = self.view.frame.size.width;
    
    self.phoneNumberTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(0, originY, viewWidth, textFieldHeight)];
    [_phoneNumberTextField setPlaceholder:lang(@"EnterPhoneNumber")];
    [_phoneNumberTextField setLeftViewWidth:originX];
    [self.view addSubview:_phoneNumberTextField];
    
    originY = CGRectGetMaxY(_phoneNumberTextField.frame);
    UIView *upLineView = [[UIView alloc] initWithFrame:CGRectMake(originX, originY - 0.5, viewWidth - 2 * originX, 1)];
    [upLineView setBackgroundColor:[UIColor room107GrayColorC]];
    [self.view addSubview:upLineView];
    
    self.verifyCodeTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(0, originY, viewWidth, textFieldHeight)];
    _verifyCodeTextField.clearButtonMode = UITextFieldViewModeNever;
    [_verifyCodeTextField setPlaceholder:lang(@"EnterVerifyCode")];
    [_verifyCodeTextField setLeftViewWidth:originX];
    [self.view addSubview:_verifyCodeTextField];
    
    CGFloat width = 85.f;
    CGFloat height = 31;
    originY = 6.5f;
    
    self.getVerifyCodeView = [[GetVerifyCodeView alloc] initWithFrame:CGRectMake(viewWidth - originX - width, originY, width, height)];
    _getVerifyCodeView.delegate = self;
    [_verifyCodeTextField addSubview:_getVerifyCodeView];

    originY = CGRectGetMaxY(_verifyCodeTextField.frame);
    UIView *downLineView = [[UIView alloc] initWithFrame:CGRectMake(originX, originY - 0.5, viewWidth - 2 * originX, 1)];
    [downLineView setBackgroundColor:[UIColor room107GrayColorC]];
    [self.view addSubview:downLineView];
    
    self.passwordTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(0, originY, viewWidth, textFieldHeight)];
    [_passwordTextField setPlaceholder:lang(@"EnterPassword")];
    [_passwordTextField setLeftViewWidth:originX];
    [self.view addSubview:_passwordTextField];
    
    originY = CGRectGetMaxY(_passwordTextField.frame) + 22;
    self.confirmButton= [[RoundedGreenButton alloc] initWithFrame:CGRectMake(originX, originY, viewWidth - 2 * originX, 53)];
    [_confirmButton setTitle:lang(@"Confirm") forState:UIControlStateNormal];
    [_confirmButton addTarget:self action:@selector(resetPasswordConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_confirmButton];
    

    if ([WXApi isWXAppInstalled]) {
        CGFloat wechatLoginViewHeight = 119.0f;
        originY = self.view.frame.size.height - wechatLoginViewHeight - statusBarHeight - navigationBarHeight;
        WXLoginView *wechatLoginView = [[WXLoginView alloc] initWithFrame:CGRectMake(0, originY, viewWidth, wechatLoginViewHeight)];
        wechatLoginView.wechatLogin = ^(void){
            //微信登录回调
        };
        [self.view addSubview:wechatLoginView];
    }

}

#pragma mark - GetVerifyCodeViewDelegate
//获取验证码点击回调
- (void)getVerifyCodeViewDidClick:(GetVerifyCodeView *)getVerifyCodeView {
    [self showLoadingView];
    WEAK_SELF weakSelf = self;
    [[AuthenticationAgent sharedInstance] getVerifyCodeByPhoneNumber:[[NSDecimalNumber alloc] initWithString:_phoneNumberTextField.text] completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        if (!errorCode) {
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
            [weakSelf.getVerifyCodeView stopCountdown];
        }
    }];
    
}

- (IBAction)resetPasswordConfirm:(id)sender {
    if (![RegularExpressionUtil validPhoneNumber:_phoneNumberTextField.text]) {
        [PopupView showMessage:lang(@"WrongPhoneNumber")];
        return;
    }
    if (_verifyCodeTextField.text.length == 0) {
        [PopupView showMessage:lang(@"EmptyVerifyCode")];
        return;
    }
    [self showLoadingView];
    WEAK_SELF weakSelf = self;
    [[AuthenticationAgent sharedInstance] resetPasswordByPhoneNumber:[[NSDecimalNumber alloc] initWithString:_phoneNumberTextField.text] andPassword:_passwordTextField.text andVerifyCode:_verifyCodeTextField.text completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        
        if (!errorCode) {
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
