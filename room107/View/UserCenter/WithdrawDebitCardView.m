//
//  WithdrawDebitCardView.m
//  room107
//
//  Created by Naitong Yu on 15/9/16.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "WithdrawDebitCardView.h"
#import "AddDebitCardViewController.h"
#import "UIImageView+WebCache.h"
#import "UserAccountAgent.h"
#import "RoundedGreenButton.h"
#import "NSString+IsPureNumer.h"

@interface WithdrawDebitCardView () <UIAlertViewDelegate>

@property (nonatomic) UILabel *withdrawAmountTextLabel;
@property (nonatomic) UILabel *arrivalTimeTextLabel;

@property (nonatomic) UIView *blankView;
@property (nonatomic) UITextField *withdrawAmountTextField;
@property (nonatomic) RoundedGreenButton *withdrawAllButton;

@property (nonatomic) UILabel *withdrawToDebitCardTextLabel;
@property (nonatomic) UIView *debitCardBackgroundView;
@property (nonatomic) UIImageView *debitCardIconView;
@property (nonatomic) UILabel *debitCardNameLabel;
@property (nonatomic) UILabel *debitCardNumberLabel;

@property (nonatomic) RoundedGreenButton *addDebitCardOrWithdrawButton;

@end

@implementation WithdrawDebitCardView

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
    _arrivalTimeTextLabel.numberOfLines = 0 ;
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
    [self.blankView addSubview:_withdrawAllButton];
    
    _withdrawToDebitCardTextLabel = [[UILabel alloc] init];
    _withdrawToDebitCardTextLabel.font = [UIFont room107SystemFontTwo];
    _withdrawToDebitCardTextLabel.textColor = [UIColor room107GrayColorC];
    _withdrawToDebitCardTextLabel.text = lang(@"WithdrawToDebitCard");
    _withdrawToDebitCardTextLabel.hidden = YES;
    [self addSubview:_withdrawToDebitCardTextLabel];
    
    _debitCardBackgroundView = [[UIView alloc] init];
    _debitCardBackgroundView.backgroundColor = [UIColor whiteColor];
    _debitCardBackgroundView.hidden = YES;
    [self addSubview:_debitCardBackgroundView];
    UITapGestureRecognizer *tapClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [_debitCardBackgroundView addGestureRecognizer:tapClick];
    
    _debitCardIconView = [[UIImageView alloc] init];
    _debitCardIconView.contentMode = UIViewContentModeScaleAspectFill;
    _debitCardIconView.image = [UIImage imageNamed:@"BankCardInvalid.png"];
    [self.debitCardBackgroundView addSubview:_debitCardIconView];
    
    _debitCardNameLabel = [[UILabel alloc] init];
    _debitCardNameLabel.font = [UIFont room107FontThree];
    _debitCardNameLabel.textColor = [UIColor room107GrayColorD];
    [self.debitCardBackgroundView addSubview:_debitCardNameLabel];
    
    _debitCardNumberLabel = [[UILabel alloc] init];
    _debitCardNumberLabel.font = [UIFont room107FontThree];
    _debitCardNumberLabel.textColor = [UIColor room107GrayColorD];
    [self.debitCardBackgroundView addSubview:_debitCardNumberLabel];
    
    _addDebitCardOrWithdrawButton = [[RoundedGreenButton alloc] init];
    [_addDebitCardOrWithdrawButton setTitle:lang(@"AddDebitCard") forState:UIControlStateNormal];
    [_addDebitCardOrWithdrawButton addTarget:self action:@selector(addDebitCardOrWithdraw:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addDebitCardOrWithdrawButton];
}

- (void)tapClick {
    if (_clickDebit) {
        _clickDebit();
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
    NSLog(@"%@",NSStringFromCGRect(labelRect));
    [_arrivalTimeTextLabel setFrame:CGRectMake(22, CGRectGetMaxY(_withdrawAmountTextField.frame), width - 44,  labelRect.size.height)];
    originY += CGRectGetHeight(_arrivalTimeTextLabel.frame) + 5;
    
    _blankView.frame = CGRectMake(0, originY, width, 46);
    [_withdrawAmountTextField sizeToFit];
    _withdrawAmountTextField.frame = CGRectMake(22, 0, width - 22 - 110, 46);
    
    _withdrawAllButton.frame = CGRectMake(width - 22 - 80, 7.5, 90, 31);
    [_withdrawAllButton setContentEdgeInsets:UIEdgeInsetsMake(9, 16, 9, 16)];
    [_withdrawAllButton setCornerRadius:4];
    originY +=  46 + 33;
    
    if (self.hasCreditCard) {
        [_withdrawToDebitCardTextLabel sizeToFit];
        frame = _withdrawToDebitCardTextLabel.frame;
        frame.origin = CGPointMake(22, originY);
        _withdrawToDebitCardTextLabel.frame =frame;
        originY += CGRectGetHeight(frame) + 5;
        
        _debitCardBackgroundView.frame = CGRectMake(11, originY, width - 22, 77);
        _debitCardBackgroundView.layer.cornerRadius = 8;
        _debitCardBackgroundView.layer.borderWidth = 0.5;
        _debitCardBackgroundView.layer.borderColor = [[UIColor room107GrayColorC] CGColor];
        _debitCardBackgroundView.layer.masksToBounds = YES;
        
        _debitCardIconView.frame = CGRectMake(16.5, 16.5, 44, 44);
        _debitCardNameLabel.frame = CGRectMake(77, 16.5, width - 22 - 77, 22);
        _debitCardNumberLabel.frame = CGRectMake(77, 16.5+22, width - 22 - 77, 22);
    }
    
    _addDebitCardOrWithdrawButton.frame = CGRectMake(22, height - 97, width - 44, 53);
    _addDebitCardOrWithdrawButton.layer.cornerRadius = 26;
    _addDebitCardOrWithdrawButton.layer.masksToBounds = YES;
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
            [[UserAccountAgent sharedInstance] withdrawWithType:0 amount:amount password:password completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, BOOL success) {
                [self.controller hideLoadingView];
                if (success) {
                    [self.controller showAlertViewWithTitle:lang(@"WithdrawSuccess") message:lang(@"WithdrawSuccessTips")];
                    [self.delegate withdrawDebitCardViewClickConfirmButton];
                } else if (errorMsg) {
                    
                }
            }];
        } else {
            [PopupView showMessage:lang(@"PleaseInputPassword")];
        }
    }
}

- (void)addDebitCardOrWithdraw:(UIButton *)sender {
    if (self.hasCreditCard) {

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
        AddDebitCardViewController *adcvc = [[AddDebitCardViewController alloc] initWithName:self.name idCard:self.idCard];
        [self.controller.navigationController pushViewController:adcvc animated:YES];
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

- (void)setHasCreditCard:(BOOL)hasCreditCard {
    _hasCreditCard = hasCreditCard;
    if (hasCreditCard) {
        [_addDebitCardOrWithdrawButton setTitle:lang(@"Confirm") forState:UIControlStateNormal];
        self.debitCardBackgroundView.hidden = NO;
        self.withdrawToDebitCardTextLabel.hidden = NO;
    } else {
        [_addDebitCardOrWithdrawButton setTitle:lang(@"AddDebitCard") forState:UIControlStateNormal];
        self.debitCardBackgroundView.hidden = YES;
        self.withdrawToDebitCardTextLabel.hidden = YES;
    }
    [self setNeedsLayout];
}

- (void)setName:(NSString *)name {
    _name = name;
    [self updateCardNameLabel];
}

- (void)setBankName:(NSString *)bankName {
    _bankName = bankName;
    [self updateCardNameLabel];
}

- (void)setBankImage:(NSString *)bankImage {
    _bankImage = bankImage;
    NSURL *imageURL = [NSURL URLWithString:bankImage];
    if (imageURL) {
        [self.debitCardIconView sd_setImageWithURL:imageURL];
    }
}

- (void)updateCardNameLabel {
    if (self.name && self.bankName) {
        self.debitCardNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.name, self.bankName];
    } else if (self.name) {
        self.debitCardNameLabel.text = self.name;
    } else {
        self.debitCardNameLabel.text = self.bankName;
    }
}

- (void)setDebitCard:(NSString *)debitCard {
    _debitCard = debitCard;
    if (debitCard.length >= 15) { //银行卡号一般是16-19位
        NSString *prefix = [debitCard substringToIndex:4];
        NSUInteger suffixLength = [debitCard length] % 4 == 0 ? 4 : [debitCard length] % 4;
        
        NSInteger groupsCount = ([debitCard length] - suffixLength) / 4 - 1;
        
        if (groupsCount >= 0) {
            for (NSUInteger i = 0; i < groupsCount; i++) {
                prefix = [prefix stringByAppendingString:@" ****"];
            }
        }
        
        NSString *string = [NSString stringWithFormat:@" %@", [debitCard substringFromIndex:[debitCard length] - suffixLength]];
        prefix = [prefix stringByAppendingString:string ? string : @""];
        
        self.debitCardNumberLabel.text = prefix;
    } else {
        self.debitCardNumberLabel.text = debitCard;
    }
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
