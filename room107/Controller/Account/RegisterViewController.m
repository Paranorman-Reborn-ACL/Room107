//
//  RegisterViewController.m
//  room107
//
//  Created by 107间 on 16/3/22.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "RegisterViewController.h"
#import "CustomTextField.h"
#import "CustomLabel.h"
#import "RoundedGreenButton.h"
#import "GetVerifyCodeView.h"
#import "AuthenticationAgent.h"
#import "WXLoginView.h"
#import "WXApi.h"
#import "RegularExpressionUtil.h"

@interface RegisterViewController ()<GetVerifyCodeViewDelegate>

@property (nonatomic, strong) CustomTextField *phoneNumberTextField; //手机号输入框
@property (nonatomic, strong) CustomTextField *verifyCodeTextField;  //验证码输入框
@property (nonatomic, strong) CustomTextField *passwordTextField; //密码输入框
@property (nonatomic, strong) GetVerifyCodeView *getVerifyCodeView; //获取验证码
@property (nonatomic, strong) RoundedGreenButton *registerButton; //注册按钮
@end

@implementation RegisterViewController

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
    _passwordTextField.secureTextEntry = YES;
    [self.view addSubview:_passwordTextField];
    
    originY = CGRectGetMaxY(_passwordTextField.frame) + 22;
    self.registerButton = [[RoundedGreenButton alloc] initWithFrame:CGRectMake(originX, originY, viewWidth - 2 * originX, 53)];
    [_registerButton setTitle:lang(@"Register") forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(registerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerButton];
    
    originY = CGRectGetMaxY(_registerButton.frame) +11;
    NSString *buttonTitle = lang(@"AgreeProtocalExplanation");
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buttonTitle];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontThree] range:NSMakeRange(0, buttonTitle.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GrayColorC] range:NSMakeRange(0, buttonTitle.length - 4)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GreenColor] range:NSMakeRange(buttonTitle.length - 4, 4)];
    RoundedGreenButton *agreeButton = [[RoundedGreenButton alloc] initWithFrame:(CGRect){0, originY, viewWidth, 30}];
    [agreeButton setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [agreeButton setBackgroundColor:[UIColor clearColor]];
    [agreeButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    [self.view addSubview:agreeButton];
    UIView *tapView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(agreeButton.frame) * 1 / 2 + 25, 0, 65 , 30)];
    [tapView setBackgroundColor:[UIColor clearColor]];
    [agreeButton addSubview:tapView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(agreeButtonDidClick:)];
    [tapView addGestureRecognizer:tap];
    
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

- (IBAction)agreeButtonDidClick:(id)sender {
    [self viewProtocalExplanation];
}

- (IBAction)registerButtonClick:(id)sender {
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
    [[AuthenticationAgent sharedInstance] registerByPhoneNumber:[[NSDecimalNumber alloc] initWithString:_phoneNumberTextField.text]  andPassword:_passwordTextField.text andVerifyCode:_verifyCodeTextField.text completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        if (!errorCode) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
            if (_registerSuccessful) {
                _registerSuccessful();
            }
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
