//
//  LoginViewController.m
//  room107
//
//  Created by 107间 on 16/3/22.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "LoginViewController.h"
#import "CustomTextField.h"
#import "RoundedGreenButton.h"
#import "ForgetPasswordViewController.h"
#import "AuthenticationAgent.h"
#import "WXLoginView.h"
#import "BindingTelephoneViewController.h"
#import "WXApi.h"
#import "RegularExpressionUtil.h"

@interface LoginViewController ()

@property (nonatomic, strong) CustomTextField *phoneNumberTextField; //手机号输入框
@property (nonatomic, strong) CustomTextField *passwordTextField; //密码输入框
@property (nonatomic, strong) RoundedGreenButton *loginGreenButton; //登录按钮
@property (nonatomic, strong) UIButton *forgetPasswordButton; //忘记密码
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setInputView];
}

- (void)setInputView {
    CGFloat originY = 11.0f;
    CGFloat originX = 22.0f;
    CGFloat textFieldHeight = 44.0f;
    CGFloat viewWidth = self.view.frame.size.width;
    
    self.phoneNumberTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(0, originY, viewWidth, textFieldHeight)];
    [_phoneNumberTextField setPlaceholder:lang(@"EnterPhoneNumber")];
    _phoneNumberTextField.font = [UIFont room107SystemFontThree];
    [_phoneNumberTextField setLeftViewWidth:originX];
    [self.view addSubview:_phoneNumberTextField];
    
    originY = CGRectGetMaxY(_phoneNumberTextField.frame);
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(originX, originY - 0.5, viewWidth - 2*originX, 1)];
    [lineView setBackgroundColor:[UIColor room107GrayColorC]];
    [self.view addSubview:lineView];
    
    originY = CGRectGetMaxY(_phoneNumberTextField.frame);
    self.passwordTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(0, originY, viewWidth, textFieldHeight)];
    [_passwordTextField setPlaceholder:lang(@"EnterPassword")];
    _passwordTextField.font = [UIFont room107SystemFontThree];
    _passwordTextField.secureTextEntry = YES;
    [_passwordTextField setLeftViewWidth:originX];
    [self.view addSubview:_passwordTextField];
    
    originY = CGRectGetMaxY(_passwordTextField.frame) + originX;
    self.loginGreenButton = [[RoundedGreenButton alloc] initWithFrame:CGRectMake(originX, originY, viewWidth - 2*originX, 53)];
    [_loginGreenButton setTitle:lang(@"Login") forState:UIControlStateNormal];
    [_loginGreenButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginGreenButton];
    
    originY = CGRectGetMaxY(_loginGreenButton.frame) + 11;
    self.forgetPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forgetPasswordButton setFrame:CGRectMake(originX, originY, 100, 20)];
    [_forgetPasswordButton setTitle:lang(@"ForgetPassword") forState:UIControlStateNormal];
    [_forgetPasswordButton setTitleColor:[UIColor room107GreenColor] forState:UIControlStateNormal];
    [_forgetPasswordButton addTarget:self action:@selector(forgetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [_forgetPasswordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.view addSubview:_forgetPasswordButton];
    
    UILabel *yellowTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, CGRectGetMaxY(_forgetPasswordButton.frame) + 11, viewWidth - originX * 2, 30)];
    [yellowTextLabel setFont:[UIFont room107SystemFontOne]];
    [yellowTextLabel setTextAlignment:NSTextAlignmentLeft];
    [yellowTextLabel setText:lang(@"ForgetPasswordTips")];
    [yellowTextLabel setNumberOfLines:0];
    [yellowTextLabel setTextColor:[UIColor room107YellowColor]];
    [self.view addSubview:yellowTextLabel];
    
    if ([WXApi isWXAppInstalled]) {
        CGFloat wechatLoginViewHeight = 119.0f;
        originY = self.view.frame.size.height - wechatLoginViewHeight - statusBarHeight - navigationBarHeight - 40;
        WXLoginView *wechatLoginView = [[WXLoginView alloc] initWithFrame:CGRectMake(0, originY, viewWidth, wechatLoginViewHeight)];
        wechatLoginView.wechatLogin = ^(void){
            //微信登录回调
        };
        [self.view addSubview:wechatLoginView];
    }
}

//登录按钮
- (IBAction)login:(id)sender {
    if (![RegularExpressionUtil validPhoneNumber:_phoneNumberTextField.text]) {
        [PopupView showMessage:lang(@"WrongPhoneNumber")];
        return;
    }
    [self showLoadingView];
    [[AuthenticationAgent sharedInstance] loginByPhoneNumber:[[NSDecimalNumber alloc] initWithString:_phoneNumberTextField.text] andPassword:_passwordTextField.text completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        if (!errorCode) {
            [_navigationController popViewControllerAnimated:YES];
            if (_loginSuccessful) {
                _loginSuccessful();
            }
        } 
    }];

}

//忘记密码
- (IBAction)forgetPassword:(id)sender {
    ForgetPasswordViewController *forgetPasswordViewcontroller = [[ForgetPasswordViewController alloc] init];
    [_navigationController pushViewController:forgetPasswordViewcontroller animated:YES];
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
