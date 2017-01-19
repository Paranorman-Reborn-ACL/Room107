//
//  PhoneNumberVerifyView.m
//  room107
//
//  Created by ningxia on 15/7/10.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "PhoneNumberVerifyView.h"
#import "CustomImageView.h"
#import "CustomTextField.h"
#import "RoundedGreenButton.h"
#import "CustomLabel.h"
#import "RegularExpressionUtil.h"

@interface PhoneNumberVerifyView () <UITextFieldDelegate>

@property (nonatomic, strong) CustomTextField *phoneNumberTextField;
@property (nonatomic, assign) CGRect lastRect;

@end

@implementation PhoneNumberVerifyView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        CGFloat originY = 50.0f;
        CGFloat imageViewWidth = 44.0f;
        CustomImageView *logoImageView = [[CustomImageView alloc] initWithFrame:(CGRect){CGRectGetWidth(self.bounds) / 2 - imageViewWidth / 2, originY, imageViewWidth, imageViewWidth}];
        [logoImageView setImageWithName:@"loginprocess.png"];
        [self addSubview:logoImageView];
        
        originY += CGRectGetHeight(logoImageView.bounds);
        originY += 44;
        _phoneNumberTextField = [[CustomTextField alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), 50}];
        _phoneNumberTextField.delegate = self ;
        [_phoneNumberTextField setPlaceholder:lang(@"EnterPhoneNumber")];
        [_phoneNumberTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [_phoneNumberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:_phoneNumberTextField];
      
        originY = CGRectGetHeight(self.bounds) - 100;
        CGRect frame = (CGRect){0, originY, CGRectGetWidth(self.bounds), 100};
        SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"NextStep") andAssistantButtonTitle:@""];
        [self addSubview:mutualBottomView];
        [mutualBottomView setMainButtonDidClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nextStepButtonDidClick:)]) {
                [self.delegate nextStepButtonDidClick:self];
            }
        }];
        
        UITapGestureRecognizer *tapGestureRecgnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
        [self addGestureRecognizer:tapGestureRecgnizer];
        
        //增加监听，当键盘出现或改变时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
    }
    
    self.lastRect = _phoneNumberTextField.frame ;
    return self;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == _phoneNumberTextField) {
        NSUInteger maxDigit = 11;
        if (textField.text.length > maxDigit) {
            textField.text = [textField.text substringToIndex:maxDigit];
        }
    }
}

- (BOOL)resignFirstResponder {
    [_phoneNumberTextField resignFirstResponder];
    return YES;
}


- (NSNumber *)phoneNumber {
    NSDecimalNumber *phoneNumber = [[NSDecimalNumber alloc] initWithString:_phoneNumberTextField.text];
    return phoneNumber;
}

- (void)showTips:(NSString *)tips {
    [PopupView showMessage:tips];
}

#pragma marks - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.5 animations:^{
        textField.frame = self.lastRect ;
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _phoneNumberTextField) {
        //校验纯数字，兼容退格键
        return string.length > 0 ? [RegularExpressionUtil validNumber:string] : YES;
    }
    
    return YES;
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float height = keyboardRect.size.height;
    CGFloat bottomY = CGRectGetMaxY(_phoneNumberTextField.frame);
   
    LogDebug(@"%f",self.frame.size.height - bottomY);
    if (height > self.frame.size.height - bottomY && [self.phoneNumberTextField isFirstResponder]) {
        CGFloat moveHeight = height - self.frame.size.height + bottomY ;
        CGRect rect = _phoneNumberTextField.frame ;
        rect.origin.y -= moveHeight;
        _phoneNumberTextField.frame = rect;
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
}

@end
