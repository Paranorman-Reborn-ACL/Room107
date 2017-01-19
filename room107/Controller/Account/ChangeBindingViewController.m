//
//  ChangeBindingViewController.m
//  room107
//
//  Created by 107间 on 16/3/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "ChangeBindingViewController.h"
#import "CustomTextField.h"
#import "RoundedGreenButton.h"
#import "CustomLabel.h"
#import "AppPropertiesModel.h"
#import "SystemAgent.h"
#import "AuthenticationAgent.h"
#import "GetVerifyCodeView.h"

@interface ChangeBindingViewController ()<UITextFieldDelegate, GetVerifyCodeViewDelegate>

@property (nonatomic, strong) UIView *clearBackGroundView;//背景视图
@property (nonatomic, strong) CustomLabel *nowPhoneLabel; //当前绑定手机号
@property (nonatomic, strong) NSString *currentPhoneNumber;
@property (nonatomic, strong) CustomTextField *phoneNumberTextField; //手机号输入框
@property (nonatomic, strong) CustomTextField *verifyCodeTextField;  //验证码输入框
@property (nonatomic, strong) GetVerifyCodeView *getVerifyCodeView; //获取验证码
@property (nonatomic, strong) RoundedGreenButton *changeBindingButton; //更换绑定按钮
@property (nonatomic, strong) NSTimer *verifyCodeTimer; //验证码定时器

@end

@implementation ChangeBindingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:lang(@"ChangeBinding")];
    [self creatBaseInterface];
}

- (void)creatBaseInterface {
    self.clearBackGroundView = [[UIView alloc] initWithFrame:self.view.frame];
    [_clearBackGroundView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_clearBackGroundView];
    
    CGFloat originY = 22;
    CGFloat originX = 20;
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat textFieldHeight = 50.0f;

    self.nowPhoneLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, originY, viewWidth, 20)];
    [_nowPhoneLabel setFont:[UIFont room107SystemFontOne]];
    [_nowPhoneLabel setTextColor:[UIColor room107GrayColorC]];
    [_nowPhoneLabel setText:[lang(@"CurrentTelephoneNumber") stringByAppendingString:_currentPhoneNumber ? _currentPhoneNumber : @""]];
    [_nowPhoneLabel setTextAlignment:NSTextAlignmentCenter];
    [self.clearBackGroundView addSubview:_nowPhoneLabel];
    
    originY = CGRectGetMaxY(_nowPhoneLabel.frame) + 22;
    self.phoneNumberTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(0, originY, viewWidth, textFieldHeight)];
    _phoneNumberTextField.delegate = self;
    [_phoneNumberTextField setPlaceholder:lang(@"EnterNewPhoneNumber")];
    [self.clearBackGroundView addSubview:_phoneNumberTextField];
    
    originY = CGRectGetMaxY(_phoneNumberTextField.frame);
    UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){originX, originY - 0.5, viewWidth - 2 * originX, 1}];
    [lineView setBackgroundColor:[UIColor room107GrayColorC]];
    [self.clearBackGroundView addSubview:lineView];
    
    originY = CGRectGetMaxY(_phoneNumberTextField.frame);
    self.verifyCodeTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(0, originY, viewWidth, textFieldHeight)];
    _verifyCodeTextField.clearButtonMode = UITextFieldViewModeNever;
    _verifyCodeTextField.delegate = self;
    [_verifyCodeTextField setPlaceholder:lang(@"EnterVerifyCode")];
    
    CGFloat width = 85.f;
    CGFloat height = 31;
    originY = 9.5f;
    self.getVerifyCodeView = [[GetVerifyCodeView alloc] initWithFrame:CGRectMake(viewWidth - originX - width, originY, width, height)];
    _getVerifyCodeView.delegate = self;
    [_verifyCodeTextField addSubview:_getVerifyCodeView];

    [self.clearBackGroundView addSubview:_verifyCodeTextField];

    CGFloat greenButtonHeight = 44;
    originY = self.view.frame.size.height - 2 * greenButtonHeight - statusBarHeight - navigationBarHeight;
    self.changeBindingButton = [[RoundedGreenButton alloc] initWithFrame:CGRectMake(originX, originY, viewWidth - 2 * originX, greenButtonHeight)];
    [_changeBindingButton setBackgroundColor:[UIColor room107GreenColor]];
    [_changeBindingButton setTitle:lang(@"ChangeBinding") forState:UIControlStateNormal];
    [_changeBindingButton.titleLabel setFont:[UIFont room107FontFour]];
    [_changeBindingButton addTarget:self action:@selector(changeBindingButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_changeBindingButton];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

//更换绑定点击
- (IBAction)changeBindingButtonDidClick:(id)sender {
    NSNumber *newPhoneNumber = [[NSDecimalNumber alloc] initWithString:_phoneNumberTextField.text];
    NSString *verifyCode = _verifyCodeTextField.text;
    [self showLoadingView];
    [[AuthenticationAgent sharedInstance] resetPhoneNumberByPhoneNumber:newPhoneNumber andUsername:nil andToken:nil andVerifyCode:verifyCode completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *telephoneNumber) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        if (!errorCode) {
            [PopupView showMessage:lang(@"BindingTelephoneSuccessfully")];
            [_nowPhoneLabel setText:[lang(@"CurrentTelephoneNumber") stringByAppendingString:telephoneNumber ? telephoneNumber : @""]];
            if (_bindingSuccessful) {
                _bindingSuccessful(telephoneNumber);
            }
        } else {
            
        }
    }];
}

//单击隐藏键盘手势
- (void)hideKeyboard {
    [self.view endEditing:YES];
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

- (void)setCurrentTelephoneNumber:(NSString *)telephoneNumber {
    self.currentPhoneNumber = telephoneNumber;
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
