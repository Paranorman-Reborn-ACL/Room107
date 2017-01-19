//
//  EmailAuthenticateView.m
//  room107
//
//  Created by ningxia on 15/7/22.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "EmailAuthenticateView.h"
#import "SearchTipLabel.h"
#import "CustomTextField.h"
#import "RoundedGreenButton.h"
#import "CustomLabel.h"
#import "YellowColorTextLabel.h"
#import "TitleGreenColorTextLabel.h"

@interface EmailAuthenticateView ()

@property (nonatomic, strong) CustomTextField *emailTextField;
@property (nonatomic, strong) UIScrollView *authenticateView;
@property (nonatomic, strong) UIScrollView *resultView;
@property (nonatomic, strong) CustomLabel *emailLabel;
@property (nonatomic, assign) CGRect oldFrame;

@end

@implementation EmailAuthenticateView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        //frame的origin置0，避免位置偏移
        frame.origin.x = 0;
        frame.origin.y = 0;
        if (!_authenticateView) {
            _authenticateView = [[UIScrollView alloc] initWithFrame:frame];
            [_authenticateView setBackgroundColor:[UIColor clearColor]];
            [self addSubview:_authenticateView];
            
            CGFloat originX = 20.0f;
            CGFloat originY = 22.0f;
            
            CGRect frame = (CGRect){0, originY, self.bounds.size.width, 60};
            TitleGreenColorTextLabel *titleGreenColorTextLabel = [[TitleGreenColorTextLabel alloc] initWithFrame:CGRectMake(0, originY, self.bounds.size.width, 100) withTitle:lang(@"WhyAuthenticate") withContent:lang(@"ReasonAuthenticate")];
            [_authenticateView addSubview:titleGreenColorTextLabel];
            
            originY += CGRectGetHeight(titleGreenColorTextLabel.frame) + 22;
            UIView *separatedView = [[UIView alloc] initWithFrame:CGRectMake(22, originY, self.frame.size.width - 44, 1)];
            [separatedView setBackgroundColor:[UIColor room107GrayColorC]];
            [_authenticateView addSubview:separatedView];
            
            originY = CGRectGetMaxY(separatedView.frame) + 22;
            SearchTipLabel *emailAuthenticateTipsLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth(self.bounds) - originX, 18}];
            [emailAuthenticateTipsLabel setText:lang(@"EmailAuthenticateTips")];
            [_authenticateView addSubview:emailAuthenticateTipsLabel];
            
            originY += CGRectGetHeight(emailAuthenticateTipsLabel.bounds) + 5;
            _emailTextField = [[CustomTextField alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), 50}];
            _oldFrame = _emailTextField.frame;
            [_emailTextField setPlaceholder:lang(@"EmailAuthenticatePlaceholder")];
            [_authenticateView addSubview:_emailTextField];
            
            originY += CGRectGetHeight(_emailTextField.bounds) + 44;
            frame = (CGRect){0, originY, CGRectGetWidth(self.bounds), 100};
            SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"SendAuthenticateEmail") andAssistantButtonTitle:@""];
            [_authenticateView addSubview:mutualBottomView];
            [mutualBottomView setMainButtonDidClickHandler:^{
                if ([self.delegate respondsToSelector:@selector(sendAuthenticateEmailButtonDidClick:)]) {
                    [self.delegate sendAuthenticateEmailButtonDidClick:self];
                }
            }];
            
            [_authenticateView setContentSize:CGSizeMake(CGRectGetWidth(self.bounds), originY + CGRectGetHeight(mutualBottomView.bounds))];
        }
        
        if (!_resultView) {
            _resultView = [[UIScrollView alloc] initWithFrame:frame];
            [_resultView setBackgroundColor:[UIColor clearColor]];
            [self addSubview:_resultView];
            
            CGFloat originY = 22.0f;
            _emailLabel = [[CustomLabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), 30}];
            [_emailLabel setFont:[UIFont room107SystemFontFive]];
            [_emailLabel setTextAlignment:NSTextAlignmentCenter];
            [_emailLabel setTextColor:[UIColor room107GreenColor]];
            [_resultView addSubview:_emailLabel];
            
            originY += CGRectGetHeight(_emailLabel.bounds) + 11;
            CustomLabel *authenticateLinkBeenSentLabel = [[CustomLabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), 20}];
            [authenticateLinkBeenSentLabel setNumberOfLines:0];
            [authenticateLinkBeenSentLabel setText:lang(@"AuthenticateLinkBeenSent")];
            [authenticateLinkBeenSentLabel setFont:[UIFont room107SystemFontThree]];
            [authenticateLinkBeenSentLabel setTextAlignment:NSTextAlignmentCenter];
            [authenticateLinkBeenSentLabel setTextColor:[UIColor room107GrayColorD]];
            [_resultView addSubview:authenticateLinkBeenSentLabel];
            
            originY += CGRectGetHeight(authenticateLinkBeenSentLabel.bounds);
            CGRect frame = (CGRect){0, originY, CGRectGetWidth(self.bounds), 100};
            SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:@"" andAssistantButtonTitle:lang(@"ChangeEmail")];
            [_resultView addSubview:mutualBottomView];
            [mutualBottomView setAssistantButtonDidClickHandler:^{
                if ([self.delegate respondsToSelector:@selector(changeEmailButtonDidClick:)]) {
                    [self.delegate changeEmailButtonDidClick:self];
                }
            }];
            
            [_resultView setContentSize:CGSizeMake(CGRectGetWidth(self.bounds), originY + CGRectGetHeight(mutualBottomView.bounds))];
        }
        
        UITapGestureRecognizer *tapGestureRecgnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
        [self addGestureRecognizer:tapGestureRecgnizer];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    return self;
}

- (void)keyboardWillShow:(NSNotification *)senderNotification {
    //获取键盘的高度
    NSDictionary *userInfo = [senderNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    CGRect frame = _emailTextField.frame;
    CGFloat textFieldBottom = frame.origin.y + frame.size.height;
    CGFloat textHeight = CGRectGetHeight(self.bounds) - textFieldBottom;
    if (height > textHeight) {
        frame.origin.y -= height - textHeight;
        [UIView animateWithDuration:1 animations:^{
            _emailTextField.frame = frame;
        }];
    }
}

- (void)keyboardwillHide:(NSNotification *)senderNotification {
    [UIView animateWithDuration:0.5 animations:^{
        _emailTextField.frame = self.oldFrame;
    }];
}
- (BOOL)resignFirstResponder {
    [_emailTextField resignFirstResponder];
    
    return YES;
}

- (void)showStep:(NSUInteger)step {
    if (step == 1) {
        _authenticateView.hidden = NO;
        _resultView.hidden = YES;
    } else {
        _authenticateView.hidden = YES;
        _resultView.hidden = NO;
    }
}

- (NSString *)authenticateEmail {
    return [_emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setAuthenticateEmail:(NSString *)email {
    [_emailLabel setText:email];
}

@end
