//
//  LoginWithoutVerifyCodeView.m
//  room107
//
//  Created by ningxia on 15/7/10.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "LoginWithoutVerifyCodeView.h"
#import "CustomImageView.h"
#import "CustomTextField.h"
#import "RoundedGreenButton.h"
#import "SearchTipLabel.h"
#import "CustomLabel.h"
#import "CircleGreenMarkView.h"

@interface LoginWithoutVerifyCodeView ()

@property (nonatomic, strong) CustomTextField *passwordTextField;
@property (nonatomic, assign) CGFloat moveHeight ; //UI空间移动距离
@end

@implementation LoginWithoutVerifyCodeView

- (id)initWithFrame:(CGRect)frame withNickname:(NSString *)nickname {
    self = [super initWithFrame:frame];
    
    if (self) {
        CGFloat originX = 20.0f;
        CGFloat originY = 50.0f;
        CGFloat imageViewWidth = 44.0f;
        CustomImageView *logoImageView = [[CustomImageView alloc] initWithFrame:(CGRect){CGRectGetWidth(self.bounds) / 2 - imageViewWidth / 2, originY, imageViewWidth, imageViewWidth}];
        [logoImageView setImageWithName:@"loginprocess.png"];
        [self addSubview:logoImageView];
        
        originY += CGRectGetHeight(logoImageView.bounds);
        SearchTipLabel *usernameTipLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), 40}];
        [usernameTipLabel setTextAlignment:NSTextAlignmentCenter];
        [usernameTipLabel setTextColor:[UIColor room107YellowColor]];
        [usernameTipLabel setText:[lang(@"WelcomeBack") stringByAppendingFormat:@"，%@", nickname]];
        [self addSubview:usernameTipLabel];

        originY += CGRectGetHeight(usernameTipLabel.bounds) + 20;
        _passwordTextField = [[CustomTextField alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), 50}];
        _passwordTextField.secureTextEntry = YES;
        [_passwordTextField setPlaceholder:lang(@"EnterPassword")];
        [self addSubview:_passwordTextField];
        
        originY += CGRectGetHeight(_passwordTextField.bounds) + 5;
        RoundedGreenButton *forgetPasswordButton = [[RoundedGreenButton alloc] initWithFrame:(CGRect){originX, originY, 100, 30}];
        [forgetPasswordButton.titleLabel setFont:[UIFont room107FontThree]];
        [forgetPasswordButton setBackgroundColor:[UIColor clearColor]];
        [forgetPasswordButton setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateNormal];
        [forgetPasswordButton setTitle:lang(@"ForgetPassword") forState:UIControlStateNormal];
        //居左显示
        [forgetPasswordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self addSubview:forgetPasswordButton];
        [forgetPasswordButton addTarget:self action:@selector(forgetPasswordButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        originY = CGRectGetHeight(self.bounds) - 100;
        CGRect frame = (CGRect){0, originY, CGRectGetWidth(self.bounds), 100};
        SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"Login") andAssistantButtonTitle:lang(@"BackToPreviousStep")];
        [self addSubview:mutualBottomView];
        [mutualBottomView setMainButtonDidClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(loginButtonDidClick:)]) {
                [self.delegate loginButtonDidClick:self];
            }
        }];
        [mutualBottomView setAssistantButtonDidClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(prevStepButtonDidClick:)]) {
                [self.delegate prevStepButtonDidClick:self];
            }
        }];
        
        UITapGestureRecognizer *tapGestureRecgnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
        [self addGestureRecognizer:tapGestureRecgnizer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    
    return self;
}

//键盘回收时候调用
- (void)keyboardWillHide:(NSNotification *)notif {
    if ([self.passwordTextField isFirstResponder]) {
        CGRect rect = self.passwordTextField.frame ;
        rect.origin.y += self.moveHeight;
        self.passwordTextField.frame = rect ;
    }
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
    if (height > self.frame.size.height - bottomY && [self.passwordTextField isFirstResponder] ) {
        CGFloat moveHeight = height - self.frame.size.height + bottomY ;
        self.moveHeight = moveHeight ;
        CGRect rect = self.passwordTextField.frame;
        rect.origin.y -= moveHeight;
        self.passwordTextField.frame = rect;
    }
}


- (BOOL)resignFirstResponder {
    [_passwordTextField resignFirstResponder];
    
    return YES;
}

- (NSString *)password {
    return _passwordTextField.text;
}

- (void)showTips:(NSString *)tips {
    [PopupView showMessage:tips];
}

- (IBAction)forgetPasswordButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(forgetPasswordButtonDidClick:)]) {
        [self.delegate forgetPasswordButtonDidClick:self];
    }
}

@end
