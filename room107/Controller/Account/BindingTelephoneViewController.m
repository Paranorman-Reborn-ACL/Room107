//
//  BindingTelephoneViewController.m
//  room107
//
//  Created by 107间 on 16/3/22.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "BindingTelephoneViewController.h"
#import "CustomTextField.h"
#import "GetVerifyCodeView.h"
#import "RoundedGreenButton.h"
#import "AuthenticationAgent.h"
#import "RegularExpressionUtil.h"

@interface BindingTelephoneViewController ()<GetVerifyCodeViewDelegate>

@property (nonatomic, strong) CustomTextField *phoneNumberTextField; //手机号输入框
@property (nonatomic, strong) CustomTextField *verifyCodeTextField;  //验证码输入框
@property (nonatomic, strong) GetVerifyCodeView *getVerifyCodeView; //获取验证码
@property (nonatomic, strong) RoundedGreenButton *bindingTelephoneButton; //注册按钮
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *username;

@end

@implementation BindingTelephoneViewController

- (instancetype)initWithToken:(NSString *)token andUsername:(NSString *)username {
    self = [super init];
    if (self) {
        _token = token;
        _username = username;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:lang(@"BindingTelephone")];
    
    CGFloat originY = 11.0f;
    CGFloat originX = 22.0f;
    CGFloat textFieldHeight = 44.0f;
    CGFloat viewWidth = self.view.frame.size.width;
    
    CGFloat imageWidth = 27.5f;
    CGFloat imageHeight = 45.f;
    
    UIImageView *bindingTelephoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(viewWidth/2 - imageWidth/2, originY, imageWidth, imageHeight)];
    [bindingTelephoneImageView setImage:[UIImage imageNamed:@"bindingTelephone"]];
    [self.view addSubview:bindingTelephoneImageView];
    
    originY = CGRectGetMaxY(bindingTelephoneImageView.frame) + 11;
    CGFloat labelWidth =276.0f;
    CGFloat imageX = viewWidth/2 - (labelWidth + 20)/2;
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, originY, 15, 15)];
    iconImageView.layer.cornerRadius = 7.5;
    iconImageView.layer.masksToBounds = YES;
    [iconImageView setBackgroundColor:[UIColor room107GreenColor]];
    [self.view addSubview:iconImageView];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame) + 5, originY, labelWidth, 15)];
    [textLabel setText:lang(@"BindingTelephoneGetMoreInfo")];
    [textLabel setTextColor:[UIColor room107GrayColorD]];
    [textLabel setFont:[UIFont room107SystemFontOne]];
    [self.view addSubview:textLabel];
    
    originY = CGRectGetMaxY(textLabel.frame) + 11;
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
    
    originY = CGRectGetMaxY(_verifyCodeTextField.frame) + 22;
    self.bindingTelephoneButton = [[RoundedGreenButton alloc] initWithFrame:CGRectMake(originX, originY, viewWidth - 2 * originX, 53)];
    [_bindingTelephoneButton setTitle:lang(@"BindAction") forState:UIControlStateNormal];
    [_bindingTelephoneButton addTarget:self action:@selector(bindingTelePhoneClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_bindingTelephoneButton];

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

- (IBAction)bindingTelePhoneClick:(id)sender {
    if (![RegularExpressionUtil validPhoneNumber:_phoneNumberTextField.text]) {
        [PopupView showMessage:lang(@"WrongPhoneNumber")];
        return;
    }
    if (_verifyCodeTextField.text.length == 0) {
        [PopupView showMessage:lang(@"EmptyVerifyCode")];
        return;
    }
    [self showLoadingView];
    [[AuthenticationAgent sharedInstance] resetPhoneNumberByPhoneNumber:[[NSDecimalNumber alloc] initWithString:_phoneNumberTextField.text] andUsername:_username andToken:_token andVerifyCode:_verifyCodeTextField.text completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *telephoneNumber) {
        [self hideLoadingView];
        
        if (!errorCode) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            NSNotification *notification = [NSNotification notificationWithName:BindingTelephoneDismissNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        } else if ([errorCode isEqual:@1003]){
            //手机号已经被其他绑定过
            RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{

            }];
            
            RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:[lang(@"Confirm") substringToIndex:2] action:^{
                [self showLoadingView];
                [[AuthenticationAgent sharedInstance] rebindGrantWithOauthPlatform:@3 andUsername:_username andTelePhone:[[NSDecimalNumber alloc] initWithString:_phoneNumberTextField.text] andToken:_token andVerifyCode:_verifyCodeTextField.text completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *username) {
                    [self hideLoadingView];
                    if (errorTitle || errorMsg) {
                        [PopupView showTitle:errorTitle message:errorMsg];
                    }
                    if (!errorCode) {
                        NSNotification *notification = [NSNotification notificationWithName:BindingTelephoneDismissNotification object:nil];
                        [[NSNotificationCenter defaultCenter] postNotification:notification];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    } else {
                    }
                }];
            }];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"HasBinding") message:lang(@"ReBinding") cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
            [alert show];
        } else {
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
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
