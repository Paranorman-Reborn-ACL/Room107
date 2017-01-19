//
//  WithdrawAlipayView.m
//  room107
//
//  Created by Naitong Yu on 15/9/23.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "WithdrawAlipayView.h"
#import "AddAlipayViewController.h"
#import "UserAccountAgent.h"
#import "RoundedGreenButton.h"
#import "NSString+IsPureNumer.h"

@interface WithdrawAlipayView () <UIAlertViewDelegate>

@property (nonatomic) UILabel *withdrawAmountTextLabel; //提现金额
@property (nonatomic) UILabel *arrivalTimeTextLabel;    //预计2小时 到账

@property (nonatomic) UIView *blankView;
@property (nonatomic) UITextField *withdrawAmountTextField; //输入框
@property (nonatomic) RoundedGreenButton *withdrawAllButton; //全部体现按钮

@property (nonatomic) UILabel *withdrawToAlipayTextLabel;  //提现到支付宝
@property (nonatomic) UIView *alipayBackgroundView;
@property (nonatomic) UIImageView *alipayIconView;
@property (nonatomic) UILabel *alipayNameLabel;
@property (nonatomic) UILabel *alipayNumberLabel;

@property (nonatomic) RoundedGreenButton *addAlipayOrWithdrawButton;

@end

@implementation WithdrawAlipayView

#pragma mark - setup and layout

- (void)setup {
    _withdrawAmountTextLabel = [[UILabel alloc] init];
    _withdrawAmountTextLabel.font = [UIFont room107SystemFontTwo];
    _withdrawAmountTextLabel.textColor = [UIColor room107GrayColorC];
    _withdrawAmountTextLabel.text = lang(@"CashAmount");
    [self addSubview:_withdrawAmountTextLabel];
    
    _arrivalTimeTextLabel = [[UILabel alloc] init];
    _arrivalTimeTextLabel.font = [UIFont room107SystemFontThree];
    _arrivalTimeTextLabel.textColor = [UIColor room107GrayColorC];
    _arrivalTimeTextLabel.text = lang(@"ArrivalTimeThreeDays");
    _arrivalTimeTextLabel.numberOfLines = 0;
    [self addSubview:_arrivalTimeTextLabel];
    
    _blankView = [[UIView alloc] init];
    _blankView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_blankView];
    
    _withdrawAmountTextField = [[UITextField alloc] init];
    _withdrawAmountTextField.font = [UIFont room107SystemFontThree];
    _withdrawAmountTextField.textColor = [UIColor room107GrayColorD];
    _withdrawAmountTextField.borderStyle = UITextBorderStyleNone;
    _withdrawAmountTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _withdrawAmountTextField.tintColor = [UIColor room107GreenColor];
    [self.blankView addSubview:_withdrawAmountTextField];
    
    
    _withdrawAllButton = [[RoundedGreenButton alloc] init];
    [_withdrawAllButton.titleLabel setFont:[UIFont room107SystemFontTwo]];
    _withdrawAllButton.backgroundColor = [UIColor room107YellowColor];
    [_withdrawAllButton setTitle:lang(@"WithdrawAll") forState:UIControlStateNormal];
    [_withdrawAllButton addTarget:self action:@selector(withdrawAll:) forControlEvents:UIControlEventTouchUpInside];
    [_withdrawAllButton setCornerRadius:4];
    [self.blankView addSubview:_withdrawAllButton];
    
    _withdrawToAlipayTextLabel = [[UILabel alloc] init];
    _withdrawToAlipayTextLabel.font = [UIFont room107SystemFontTwo];
    _withdrawToAlipayTextLabel.textColor = [UIColor room107GrayColorC];
    _withdrawToAlipayTextLabel.text = lang(@"WithdrawToAlipay");
    _withdrawToAlipayTextLabel.hidden = YES;
    [self addSubview:_withdrawToAlipayTextLabel];
    
    _alipayBackgroundView = [[UIView alloc] init];
    _alipayBackgroundView.backgroundColor = [UIColor whiteColor];
    _alipayBackgroundView.hidden = YES;
    UITapGestureRecognizer *tapClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [_alipayBackgroundView addGestureRecognizer:tapClick];
    [self addSubview:_alipayBackgroundView];
    
    _alipayIconView = [[UIImageView alloc] init];
    _alipayIconView.contentMode = UIViewContentModeScaleAspectFill;
    _alipayIconView.image = [UIImage imageNamed:@"Alipay.png"];
    [self.alipayBackgroundView addSubview:_alipayIconView];
    
    _alipayNameLabel = [[UILabel alloc] init];
    _alipayNameLabel.font = [UIFont room107FontThree];
    _alipayNameLabel.textColor = [UIColor room107GrayColorD];
    [self.alipayBackgroundView addSubview:_alipayNameLabel];
    
    _alipayNumberLabel = [[UILabel alloc] init];
    _alipayNumberLabel.font = [UIFont room107FontThree];
    _alipayNumberLabel.textColor = [UIColor room107GrayColorD];
    [self.alipayBackgroundView addSubview:_alipayNumberLabel];
    
    _addAlipayOrWithdrawButton = [[RoundedGreenButton alloc] init];
    [_addAlipayOrWithdrawButton setTitle:lang(@"AddAlipay") forState:UIControlStateNormal];
    [_addAlipayOrWithdrawButton addTarget:self action:@selector(addAlipayOrWithdraw:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addAlipayOrWithdrawButton];
}

- (void)tapClick {
    if (_clickAliPay) {
        _clickAliPay();
    }
}

- (void)layoutSubviews {
    CGFloat originY = 22;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    [_withdrawAmountTextLabel sizeToFit];
    CGRect frame = _withdrawAmountTextLabel.frame;
    frame.origin = CGPointMake(22, originY);
    _withdrawAmountTextLabel.frame = frame;
    originY += CGRectGetHeight(frame) + 5;

    CGSize size = CGSizeMake(width - 44 , 2000);
    CGRect labelRect = [_arrivalTimeTextLabel.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107SystemFontThree]} context:nil];
    [_arrivalTimeTextLabel setFrame:CGRectMake(22, CGRectGetMaxY(_withdrawAmountTextLabel.frame), width - 44,  labelRect.size.height)];
    originY += CGRectGetHeight(_arrivalTimeTextLabel.frame) + 5;
    
    _blankView.frame = CGRectMake(0, originY, width, 46);
    [_withdrawAmountTextField sizeToFit];
    _withdrawAmountTextField.frame = CGRectMake(22, 0, width - 22 - 110, 46);
    
    _withdrawAllButton.frame = CGRectMake(width - 22 - 80, 7.5, 90, 31);
    [_withdrawAllButton setContentEdgeInsets:UIEdgeInsetsMake(9, 16, 9, 16)];
    [_withdrawAllButton setCornerRadius:4];
    originY += 46 + 33;
    
    if (self.hasAlipay) {
        [_withdrawToAlipayTextLabel sizeToFit];
        frame = _withdrawToAlipayTextLabel.frame;
        frame.origin = CGPointMake(22, originY);
        _withdrawToAlipayTextLabel.frame =frame;
        originY += CGRectGetHeight(frame) + 6;
        
        _alipayBackgroundView.frame = CGRectMake(11, originY, width - 22, 77);
        _alipayBackgroundView.layer.cornerRadius = 8;
        _alipayBackgroundView.layer.borderWidth = 0.5;
        _alipayBackgroundView.layer.borderColor = [[UIColor room107GrayColorC] CGColor];
        _alipayBackgroundView.layer.masksToBounds = YES;
        
        _alipayIconView.frame = CGRectMake(16.5, 16.5, 44, 44);
        _alipayNameLabel.frame = CGRectMake(77, 16.5, width - 22 - 77, 22);
        _alipayNumberLabel.frame = CGRectMake(77, 16.5+22, width - 22 - 77, 22);
    }
    
    _addAlipayOrWithdrawButton.frame = CGRectMake(22, height - 97, width - 44, 53);
    _addAlipayOrWithdrawButton.layer.cornerRadius = 26;
    _addAlipayOrWithdrawButton.layer.masksToBounds = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.withdrawAmountTextField resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - actions

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [[alertView textFieldAtIndex:0] resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 点击确定
        double amount = [self.withdrawAmountTextField.text doubleValue] * 100.0f;
        NSString *password = [alertView textFieldAtIndex:0].text;
        if (amount > 0 && [password length] > 0) {
            [self.controller showLoadingView];
            [[UserAccountAgent sharedInstance] withdrawWithType:1 amount:amount password:password completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, BOOL success) {
                [self.controller hideLoadingView];
                if (success) {
                    [self.controller showAlertViewWithTitle:lang(@"WithdrawSuccess") message:lang(@"WithdrawSuccessTips")];
                    //点击确定按钮提现成功 delegate执行监听方法 刷新textfield
                    [self.delegate withdrawAlipayViewClickConfirmButton];
                } else if (errorMsg) {
                    
                }
            }];
        } else {
            [PopupView showMessage:lang(@"PleaseInputPassword")];
        }
    }
}


- (void)addAlipayOrWithdraw:(UIButton *)sender {
    if (self.hasAlipay) {
        BOOL isInt = [NSString isPureInt:self.withdrawAmountTextField.text];
        BOOL isFloat = [NSString isPureFloat:self.withdrawAmountTextField.text];
        if (isInt || isFloat) {//输入金额是整数或者小数
            
             double amount = [self.withdrawAmountTextField.text doubleValue];
             NSArray *array = [self.withdrawAmountTextField.text componentsSeparatedByString:@"."];
             if (1 == array.count) {//输入金额为整数 不带小数点
                
                if (amount > 0 && amount <= self.maxWithdrawAmount ) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:lang(@"PleaseInputPassword") message:nil delegate:self cancelButtonTitle:lang(@"Cancel") otherButtonTitles:lang(@"Confirm"), nil];
                    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    [[alertView textFieldAtIndex:0] setTintColor:[UIColor room107GreenColor]];
                    [[alertView textFieldAtIndex:0] becomeFirstResponder];
                    [alertView show];
                } else {
                    [PopupView showMessage:lang(@"PleaseInputAmount")];
                }
                
             }else if (2 == array.count) { //输入金额为小数
                //金额大于0 小于最大值  且小数点后最多2位
                if (amount > 0 && amount <= self.maxWithdrawAmount && [array[1] length] <=2 ) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:lang(@"PleaseInputPassword") message:nil delegate:self cancelButtonTitle:lang(@"Cancel") otherButtonTitles:lang(@"Confirm"), nil];
                    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    [[alertView textFieldAtIndex:0] setTintColor:[UIColor room107GreenColor]];
                    [[alertView textFieldAtIndex:0] becomeFirstResponder];
                    [alertView show];
                } else {
                    [PopupView showMessage:lang(@"PleaseInputAmount")];
                }
                
             }else if (array.count >= 3) { //输入金额多位小数 无效金额
                [PopupView showMessage:lang(@"PleaseInputAmount")];
             }
            
        }else {//输入金额携带英文 或者其他特殊字符
            [PopupView showMessage:lang(@"PleaseInputAmount")];
        }
        
    } else {
        AddAlipayViewController *aavc = [[AddAlipayViewController alloc] initWithName:self.name idCard:self.idCard];
        [self.controller.navigationController pushViewController:aavc animated:YES];
    }
}

- (void)withdrawAll:(UIButton *)sender {
    NSString *allAmountString = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:self.maxWithdrawAmount] numberStyle:NSNumberFormatterDecimalStyle];
    self.withdrawAmountTextField.text = [allAmountString stringByReplacingOccurrencesOfString:@"," withString:@""];
    [self.withdrawAmountTextField resignFirstResponder];
}

#pragma mark - setters and/or getters

- (void)setMaxWithdrawAmount:(double)maxWithdrawAmount {
    _maxWithdrawAmount = maxWithdrawAmount;
    NSString *prefix = lang(@"MaxWithdrawAmount");
    NSString *placeholderText = [prefix stringByAppendingString:[CommonFuncs moneyStrByDouble:maxWithdrawAmount] ? [CommonFuncs moneyStrByDouble:maxWithdrawAmount] : @""];
    _withdrawAmountTextField.placeholder = placeholderText;
}

- (void)setHasAlipay:(BOOL)hasAlipay {
    _hasAlipay = hasAlipay;
    if (hasAlipay) {
        [_addAlipayOrWithdrawButton setTitle:lang(@"Confirm") forState:UIControlStateNormal];
        self.alipayBackgroundView.hidden = NO;
        self.withdrawToAlipayTextLabel.hidden = NO;
    } else {
        [_addAlipayOrWithdrawButton setTitle:lang(@"AddAlipay") forState:UIControlStateNormal];
        self.alipayBackgroundView.hidden = YES;
        self.withdrawToAlipayTextLabel.hidden = YES;
    }
    [self setNeedsLayout];
}

- (void)setName:(NSString *)name {
    _name = name;
    self.alipayNameLabel.text = name;
}

- (void)setAlipayNumber:(NSString *)alipayNumber {
    _alipayNumber = alipayNumber;
    self.alipayNumberLabel.text = alipayNumber;
}

#pragma mark - init methods

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

@end
