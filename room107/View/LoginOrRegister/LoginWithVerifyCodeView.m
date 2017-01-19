//
//  LoginWithVerifyCodeView.m
//  room107
//
//  Created by ningxia on 15/7/10.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "LoginWithVerifyCodeView.h"
#import "CustomImageView.h"
#import "CustomTextField.h"
#import "RoundedGreenButton.h"
#import "SearchTipLabel.h"
#import "CustomLabel.h"
#import "CircleGreenMarkView.h"
#import "SystemAgent.h"

@interface LoginWithVerifyCodeView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *view ;
@property (nonatomic, strong) CustomLabel *accountLabel ;
@property (nonatomic, strong) CustomTextField *passwordTextField;
@property (nonatomic, strong) CustomTextField *verifyCodeTextField;
@property (nonatomic, strong) CustomLabel *countdownLabel; //倒计时
@property (nonatomic, strong) RoundedGreenButton *getVerifyCodeButton;
@property (nonatomic, strong) NSTimer *verifyCodeTimer;
@property (nonatomic) NSUInteger countdown;
@property (nonatomic,assign) CGFloat move;

//记录UI空间初始frame
@property (nonatomic, assign) CGRect oldVerifyRect;
@property (nonatomic, assign) CGRect oldPasswordRect;
@property (nonatomic, assign) CGRect oldAccountLabelRect;
@property (nonatomic, assign) CGRect oldGetVerifyCodeButtonRect;
@property (nonatomic, assign) CGRect oldCountdownLabelRect;
@property (nonatomic, assign) CGRect oldViewRect;

@end

@implementation LoginWithVerifyCodeView

- (void) backFrame{
    self.verifyCodeTextField.frame = self.oldVerifyRect;
    self.passwordTextField.frame = self.oldPasswordRect ;
    self.accountLabel.frame = self.oldAccountLabelRect ;
    self.getVerifyCodeButton.frame = self.oldGetVerifyCodeButtonRect ;
    self.countdownLabel.frame = self.oldCountdownLabelRect ;
    self.view.frame = self.oldViewRect;
//    self.passwordTextField.hidden = YES ;
}

- (id)initWithFrame:(CGRect)frame withType:(LoginWithVerifyCodeViewType)type withUsername:(NSString *)username withNickname:(NSString *)nickname {
    self = [super initWithFrame:frame];
    
    if (self) {
        _type = type;
        
        CGFloat originX = 20.0f;
        CGFloat originY = 50.0f;
        CGFloat imageViewWidth = 44.0f;
        CustomImageView *logoImageView = [[CustomImageView alloc] initWithFrame:(CGRect){CGRectGetWidth(self.bounds) / 2 - imageViewWidth / 2, originY, imageViewWidth, imageViewWidth}];
        [logoImageView setImageWithName:@"loginprocess.png"];
        [self addSubview:logoImageView];
        
        originY += CGRectGetHeight(logoImageView.bounds);
        NSString *loginOrRegisterButtonTitle = lang(@"Register");
        SearchTipLabel *usernameTipLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), 50}];
        [usernameTipLabel setTextColor:[UIColor room107YellowColor]];
        [usernameTipLabel setText:[lang(@"WelcomeBack") stringByAppendingFormat:@"，%@", nickname]];
        [self addSubview:usernameTipLabel];

        originY += 20;
        switch (type) {
            case LoginWithVerifyCodeViewTypeNewPassword:
            case LoginWithVerifyCodeViewTypeRegister:
                if (type == LoginWithVerifyCodeViewTypeNewPassword) {
                    loginOrRegisterButtonTitle = lang(@"Confirm");
                }
                usernameTipLabel.hidden = YES;
                break;
            case LoginWithVerifyCodeViewTypeGrant:
                loginOrRegisterButtonTitle = lang(@"Done");
                break;
            default:
                break;
        }
        
       self.accountLabel = [[CustomLabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), 50}];
        [_accountLabel setBackgroundColor:[UIColor whiteColor]];
        [_accountLabel setTextAlignment:NSTextAlignmentCenter];
        [_accountLabel setText:username];
        [_accountLabel setTextColor:[UIColor room107GrayColorD]];
        [self addSubview:_accountLabel];
        
        originY += CGRectGetHeight(_accountLabel.bounds);
        CGFloat getVerifyCodeWidth = 100.0f;
        CGFloat textFieldHeight = 50;
        _verifyCodeTextField = [[CustomTextField alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), textFieldHeight}];
        [_verifyCodeTextField setPlaceholder:lang(@"EnterVerifyCode")];
        _verifyCodeTextField.delegate = self;
        [self addSubview:_verifyCodeTextField];
        
        CGRect frame = (CGRect){CGRectGetWidth(self.bounds) - getVerifyCodeWidth - 10, originY + 5, getVerifyCodeWidth, CGRectGetHeight(_verifyCodeTextField.bounds) - 10};
        _countdownLabel = [[CustomLabel alloc] initWithFrame:frame];
        [_countdownLabel setBackgroundColor:[UIColor whiteColor]];
        [_countdownLabel setTextAlignment:NSTextAlignmentCenter];
        [_countdownLabel setFont:_verifyCodeTextField.font];
        [_countdownLabel setTextColor:[UIColor room107GrayColorC]];
        [self addSubview:_countdownLabel];
        
        _getVerifyCodeButton = [[RoundedGreenButton alloc] initWithFrame:_countdownLabel.frame];
        [_getVerifyCodeButton setBackgroundColor:[UIColor room107YellowColor]];
        [_getVerifyCodeButton setTitle:lang(@"GetVerifyCode") forState:UIControlStateNormal];
        [_getVerifyCodeButton.titleLabel setFont:[UIFont room107SystemFontThree]];
        _getVerifyCodeButton.hidden = YES;
        [self startCountdown];
        [self addSubview:_getVerifyCodeButton];
        [_getVerifyCodeButton addTarget:self action:@selector(getVerifyCodeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        originY += CGRectGetHeight(_verifyCodeTextField.bounds);
        
        self.view = [[UIView alloc] initWithFrame:(CGRect){originX, originY - 0.5, CGRectGetWidth(self.bounds) - 2 * originX, 1}];
        [_view setBackgroundColor:[UIColor room107GrayColorC]];
        [self addSubview:_view];
        
        _passwordTextField = [[CustomTextField alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), textFieldHeight}];
        _passwordTextField.secureTextEntry = YES;
        [_passwordTextField setPlaceholder:lang(@"SetPassword")];
        _passwordTextField.delegate = self;
        [self addSubview:_passwordTextField];
        
        if (type == LoginWithVerifyCodeViewTypeRegister) {
            NSString *buttonTitle = lang(@"AgreeProtocalExplanation");
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buttonTitle];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontThree] range:NSMakeRange(0, buttonTitle.length)];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GrayColorC] range:NSMakeRange(0, buttonTitle.length - 4)];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GreenColor] range:NSMakeRange(buttonTitle.length - 4, 4)];
            originY += CGRectGetHeight(_passwordTextField.bounds) ;
            RoundedGreenButton *agreeButton = [[RoundedGreenButton alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), textFieldHeight}];
            [agreeButton setBackgroundColor:[UIColor clearColor]];
            [agreeButton setAttributedTitle:attributedString forState:UIControlStateNormal];
            [self addSubview:agreeButton];
            UIView *tapView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(agreeButton.frame) * 1 / 2 + 25, 10, 65 , 28)];
            [tapView setBackgroundColor:[UIColor clearColor]];
            [agreeButton addSubview:tapView];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(agreeButtonDidClick:)];
            [tapView addGestureRecognizer:tap];
//            [agreeButton addTarget:self action:@selector(agreeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        originY = CGRectGetHeight(self.bounds) - 100;
        frame = (CGRect){0, originY, CGRectGetWidth(self.bounds), 100};
        SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:loginOrRegisterButtonTitle andAssistantButtonTitle:lang(@"BackToPreviousStep")];
        [self addSubview:mutualBottomView];
        [mutualBottomView setMainButtonDidClickHandler:^{
            [self stopCountdown];
            
            if ([self.delegate respondsToSelector:@selector(loginOrRegisterButtonDidClick:)]) {
                [self.delegate loginOrRegisterButtonDidClick:self];
            }
        }];
        [mutualBottomView setAssistantButtonDidClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(prevStepButtonDidClick:)]) {
                [self.delegate prevStepButtonDidClick:self];
            }
        }];
        
        UITapGestureRecognizer *tapGestureRecgnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
        [self addGestureRecognizer:tapGestureRecgnizer];
        
        //增加监听，当键盘出现或改变时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        //当键盘回收时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        self.oldVerifyRect = self.verifyCodeTextField.frame;
        self.oldPasswordRect = self.passwordTextField.frame;
        self.oldAccountLabelRect = self.accountLabel.frame;
        self.oldGetVerifyCodeButtonRect = self.getVerifyCodeButton.frame;
        self.oldCountdownLabelRect = self.countdownLabel.frame;
        self.oldViewRect = self.view.frame;
    }
    return self;
}

- (IBAction)getVerifyCodeButtonDidClick:(id)sender {
    [self startCountdown];
    if ([self.delegate respondsToSelector:@selector(getVerifyCodeButtonDidClick:)]) {
        [self.delegate getVerifyCodeButtonDidClick:self];
    }
}

- (IBAction)agreeButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(agreeButtonDidClick:)]) {
        [self.delegate agreeButtonDidClick:self];
    }
}

- (void)startCountdown {
    if (!_verifyCodeTimer) {
        _verifyCodeTimer = [NSTimer timerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(refreshCountdown)
                                           userInfo:nil
                                            repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:_verifyCodeTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop mainRunLoop] addTimer:_verifyCodeTimer forMode:UITrackingRunLoopMode];
    }
    
    AppPropertiesModel *appProperties = [[SystemAgent sharedInstance] getPropertiesFromLocal];
    _countdown = [appProperties.verifyCodeInterval unsignedIntegerValue];
    if (_countdown == 0 ) {
        //第一次进入app没有网络，即appProperties为空，点击注册时候有网络，_countdown为0，给默认60；
        _countdown = 60;
    }
    [_countdownLabel setText:[NSString stringWithFormat:@"%lds", (unsigned long)_countdown]];
    _getVerifyCodeButton.hidden = YES;
    _countdownLabel.hidden = NO;
}

- (void)stopCountdown {
    [_verifyCodeTimer invalidate];
    _verifyCodeTimer = nil;
    _getVerifyCodeButton.hidden = NO;
    _countdownLabel.hidden = YES;
}

- (void)refreshCountdown {
    _countdown -= 1;
    [_countdownLabel setText:[NSString stringWithFormat:@"%lds", (unsigned long)_countdown]];
    
    if (_countdown == 0) {
        //倒计时为0时候重新获取验证码
        [self stopCountdown];
        return;
    }
}

- (BOOL)resignFirstResponder {
    [_passwordTextField resignFirstResponder];
    [_verifyCodeTextField resignFirstResponder];
    
    return YES;
}

- (NSString *)password {
    return _passwordTextField.text;
}

- (NSString *)verifyCode {
    return _verifyCodeTextField.text;
}

- (void)showTips:(NSString *)tips {
    [PopupView showMessage:tips];
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    CGFloat bottomY = CGRectGetMaxY(self.passwordTextField.frame) + 5;
    
    LogDebug(@"%f",self.frame.size.height - bottomY);
    if (height > self.frame.size.height - bottomY &&  [self.verifyCodeTextField isFirstResponder] | [self.passwordTextField isFirstResponder] ) {
        CGFloat moveHeight = height - self.frame.size.height + bottomY ;
        [self changeFrame:moveHeight];
        self.move = moveHeight ;
    }
}

- (void)keyboardWillHide:(NSNotification *)notif{
    LogDebug(@"键盘回收");
    [UIView animateWithDuration:0.5 animations:^{
        [self backFrame];
    }];
}


//点击输入框 布局上移
-(void)changeFrame:(CGFloat)moveHeight{
    CGRect verifyRect = self.verifyCodeTextField.frame ;
    verifyRect.origin.y -= moveHeight ;
    self.verifyCodeTextField.frame = verifyRect ;
    
    CGRect passwordRect = self.passwordTextField.frame ;
    passwordRect.origin.y -= moveHeight ;
    self.passwordTextField.frame = passwordRect ;
    
    CGRect accountLabelRect = self.accountLabel.frame ;
    accountLabelRect.origin.y -= moveHeight;
    self.accountLabel.frame = accountLabelRect ;
    
    CGRect getVerifyCodeButtonRect = self.getVerifyCodeButton.frame ;
    getVerifyCodeButtonRect.origin.y -= moveHeight;
    self.getVerifyCodeButton.frame = getVerifyCodeButtonRect;
    
    CGRect countdownLabelRect = self.countdownLabel.frame ;
    countdownLabelRect.origin.y -= moveHeight ;
    self.countdownLabel.frame = countdownLabelRect ;
    
    CGRect viewRect = self.view.frame ;
    viewRect.origin.y -= moveHeight ;
    self.view.frame = viewRect ;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}
@end
