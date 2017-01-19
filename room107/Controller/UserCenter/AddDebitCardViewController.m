//
//  AddDebitCardViewController.m
//  room107
//
//  Created by Naitong Yu on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "AddDebitCardViewController.h"
#import "UserAccountAgent.h"
#import "UIImageView+WebCache.h"


@interface AddDebitCardViewController () <UITextFieldDelegate>

@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) UILabel *bindCardTextLabel;
@property (nonatomic) UIView *debitCardBackgroundView;
@property (nonatomic) UIImageView *debitCardImageView;
@property (nonatomic) UIView *verticalSeperator;
@property (nonatomic) UITextField *debitCardNumberTextField;

@property (nonatomic) UILabel *nameAndIdCardPromptLabel;
@property (nonatomic) UIView *nameAndIdCardBackgroundView;
@property (nonatomic) UITextField *nameTextField;
@property (nonatomic) UIView *horizontalSeperator;
@property (nonatomic) UITextField *idCardTextField;

@property (nonatomic) UILabel *nameAndIdCardInfoLabel;

@property (nonatomic) UIButton *confirmButton;

@property (nonatomic) BOOL hasNameInfo;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *idCard;

@property (nonatomic) BOOL debitCardRecognized;
@property (nonatomic) UILabel *bankNameLabel;

@end

@implementation AddDebitCardViewController

- (instancetype)initWithName:(NSString *)name idCard:(NSString *)idCard {
    self = [super init];
    if (self) {
        self.debitCardRecognized = NO;
        self.name = name;
        self.idCard = idCard;
        if (name && idCard) {
            self.hasNameInfo = YES;
        } else {
            self.hasNameInfo = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tap];
    [self setup];
}

- (void)hideKeyboard:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)setup {
    [self setTitle:lang(@"AddDebitCard")];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:_scrollView];
    
    _bindCardTextLabel = [[UILabel alloc] init];
    _bindCardTextLabel.font = [UIFont room107FontTwo];
    _bindCardTextLabel.textColor = [UIColor room107GrayColorC];
    _bindCardTextLabel.text = lang(@"PleaseBindYourDebitCard");
    [self.scrollView addSubview:_bindCardTextLabel];
    
    _debitCardBackgroundView = [[UIView alloc] init];
    _debitCardBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:_debitCardBackgroundView];
    
    _debitCardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BankCardInvalid.png"]];
    _debitCardImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.debitCardBackgroundView addSubview:_debitCardImageView];
    
    _verticalSeperator = [[UIView alloc] init];
    _verticalSeperator.backgroundColor = [UIColor room107GrayColorC];
    [self.debitCardBackgroundView addSubview:_verticalSeperator];
    
    _debitCardNumberTextField = [[UITextField alloc] init];
    _debitCardNumberTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:lang(@"PleaseInputDebitCardNumber")
                                                                                      attributes:@{NSForegroundColorAttributeName: [UIColor room107GrayColorB]}];
    _debitCardNumberTextField.font = [UIFont room107FontThree];
    _debitCardNumberTextField.textColor = [UIColor room107GrayColorD];
    _debitCardNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    _debitCardNumberTextField.borderStyle = UITextBorderStyleNone;
    _debitCardNumberTextField.tag = 333;
    _debitCardNumberTextField.delegate = self;
    _debitCardNumberTextField.tintColor = [UIColor room107GreenColor];
    [self.debitCardBackgroundView addSubview:_debitCardNumberTextField];
    
    _bankNameLabel = [[UILabel alloc] init];
    _bankNameLabel.font = [UIFont room107FontThree];
    _bankNameLabel.textColor = [UIColor room107GrayColorD];
    _bankNameLabel.hidden = YES;
    [self.scrollView addSubview:_bankNameLabel];
    
    _nameAndIdCardPromptLabel = [[UILabel alloc] init];
    _nameAndIdCardPromptLabel.font = [UIFont room107FontTwo];
    _nameAndIdCardPromptLabel.textColor = [UIColor room107GrayColorC];
    if (self.hasNameInfo) {
        _nameAndIdCardPromptLabel.text = lang(@"ConfirmIdentityInfo");
    } else {
        _nameAndIdCardPromptLabel.text = lang(@"InputBankReservedInfo");
    }
    [self.scrollView addSubview:_nameAndIdCardPromptLabel];
    
    _nameAndIdCardBackgroundView = [[UIView alloc] init];
    _nameAndIdCardBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:_nameAndIdCardBackgroundView];
    
    _nameTextField = [[UITextField alloc] init];
    _nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:lang(@"PleaseInputCardHolderName")
                                                                           attributes:@{NSForegroundColorAttributeName: [UIColor room107GrayColorB]}];
    _nameTextField.font = [UIFont room107FontThree];
    _nameTextField.textColor = [UIColor room107GrayColorD];
    _nameTextField.returnKeyType = UIReturnKeyNext;
    _nameTextField.borderStyle = UITextBorderStyleNone;
    _nameTextField.delegate = self;
    _nameTextField.tag = 111;
    _nameTextField.tintColor = [UIColor room107GreenColor];
    [self.nameAndIdCardBackgroundView addSubview:_nameTextField];
    
    _horizontalSeperator = [[UIView alloc] init];
    _horizontalSeperator.backgroundColor = [UIColor room107GrayColorC];
    [self.nameAndIdCardBackgroundView addSubview:_horizontalSeperator];
    
    _idCardTextField = [[UITextField alloc] init];
    _idCardTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:lang(@"PleaseInputIdCardNumber")
                                                                             attributes:@{NSForegroundColorAttributeName: [UIColor room107GrayColorB]}];
    _idCardTextField.font = [UIFont room107FontThree];
    _idCardTextField.textColor = [UIColor room107GrayColorD];
    _idCardTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _idCardTextField.returnKeyType = UIReturnKeyDone;
    _idCardTextField.borderStyle = UITextBorderStyleNone;
    _idCardTextField.delegate = self;
    _idCardTextField.tag = 222;
    _idCardTextField.tintColor = [UIColor room107GreenColor];
    [self.nameAndIdCardBackgroundView addSubview:_idCardTextField];
    
    _nameAndIdCardInfoLabel = [[UILabel alloc] init];
    _nameAndIdCardInfoLabel.font = [UIFont room107FontThree];
    _nameAndIdCardInfoLabel.textColor = [UIColor room107GrayColorD];
    _nameAndIdCardInfoLabel.hidden = YES;
    [self.scrollView addSubview:_nameAndIdCardInfoLabel];
    
    if (self.hasNameInfo && _idCard.length == 18) {
        _nameAndIdCardInfoLabel.hidden = NO;
        _nameAndIdCardBackgroundView.hidden = YES;
        
        NSString *idCardPrefix = [self.idCard substringToIndex:4];
        NSString *idCardSuffix = [self.idCard substringFromIndex:16];
        NSString *str = [NSString stringWithFormat:@"%@ | %@** **** **** **%@", self.name, idCardPrefix, idCardSuffix];
        _nameAndIdCardInfoLabel.text = str;
    } else {
        _nameAndIdCardInfoLabel.hidden = YES;
        _nameAndIdCardBackgroundView.hidden = NO;
    }
    
    _confirmButton = [[UIButton alloc] init];
    [_confirmButton setTitle:lang(@"Confirm") forState:UIControlStateNormal];
    [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _confirmButton.titleLabel.font = [UIFont room107FontFour];
    _confirmButton.backgroundColor = [UIColor room107GreenColor];
    [_confirmButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:_confirmButton];
    
}

- (void)viewDidLayoutSubviews {
    CGRect frame = self.view.bounds;
    frame.origin.y = 0;
    frame.size.height -= 0;
    _scrollView.frame = frame;
    _scrollView.contentSize = frame.size;
    
    CGFloat originY = 11;
    CGFloat width = self.scrollView.bounds.size.width;
    CGFloat height = self.scrollView.bounds.size.height;
    
    [_bindCardTextLabel sizeToFit];
    frame = _bindCardTextLabel.frame;
    frame.origin = CGPointMake(22, originY);
    _bindCardTextLabel.frame = frame;
    originY += CGRectGetHeight(frame) + 5;
    
    _debitCardBackgroundView.frame = CGRectMake(0, originY, width, 46);
    _debitCardImageView.frame = CGRectMake(22, 12, 22, 22);
    _verticalSeperator.frame = CGRectMake(55, 7.5, 1, 31);
    _debitCardNumberTextField.frame = CGRectMake(67, 0, width - 67 - 22, 46);
    
    originY += 46 + 10;
    
    [_bankNameLabel sizeToFit];
    frame = _bankNameLabel.frame;
    frame.origin = CGPointMake(22, originY);
    _bankNameLabel.frame = frame;
    
    originY += CGRectGetHeight(frame) + 33;
    
    [_nameAndIdCardPromptLabel sizeToFit];
    frame = _nameAndIdCardPromptLabel.frame;
    frame.origin = CGPointMake(22, originY);
    _nameAndIdCardPromptLabel.frame = frame;
    originY += CGRectGetHeight(frame) + 5;
    
    if (self.hasNameInfo) {
        _nameAndIdCardInfoLabel.frame = CGRectMake(22, originY, width - 44, 30);
    } else {
        
        _nameAndIdCardBackgroundView.frame = CGRectMake(0, originY, width, 93);
        _nameTextField.frame = CGRectMake(22, 0, width - 44, 46);
        _idCardTextField.frame = CGRectMake(22, 47, width - 44, 46);
        _horizontalSeperator.frame = CGRectMake(22, 46, width - 44, 0.5);
    }
    
    originY += 93 + 44;
    
    if (height - 97 > originY) {
        _confirmButton.frame = CGRectMake(22, height - 97, width - 44, 53);
    } else {
        _confirmButton.frame = CGRectMake(22, originY, width - 44, 53);
        _scrollView.contentSize = CGSizeMake(width, originY + 97);
    }
    
    _confirmButton.layer.cornerRadius = 26;
    _confirmButton.layer.masksToBounds = YES;
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 111) {
        [textField resignFirstResponder];
        [self.idCardTextField becomeFirstResponder];
    } else if (textField.tag == 222) {
        [textField resignFirstResponder];
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 333) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([newString length] >= 6) {
            if (!self.debitCardRecognized) {
                WEAK_SELF weakSelf = self;
                [[UserAccountAgent sharedInstance] getBankInfoWithBankCardNumber:newString completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *bankInfo) {
                    if (errorMsg) {
                        
                    }
                    if (!weakSelf.debitCardRecognized) {
                        NSString *bankName = bankInfo[@"bankName"];
                        NSString *bankImage = bankInfo[@"bankImage"];
                        if (bankName && bankImage) {
                            weakSelf.debitCardRecognized = YES;
                            weakSelf.bankNameLabel.text = bankName;
                            [weakSelf.bankNameLabel sizeToFit];
                            [weakSelf.debitCardImageView sd_setImageWithURL:[NSURL URLWithString:bankImage] placeholderImage:[UIImage imageNamed:@"BankCardInvalid.png"]];
                        }
                    }
                }];
            }
        } else {
            self.debitCardRecognized = NO;
        }
    }
    return YES;
}

#pragma mark - setters

- (void)setDebitCardRecognized:(BOOL)debitCardRecognized {
    _debitCardRecognized = debitCardRecognized;
    if (debitCardRecognized) {
        _bankNameLabel.hidden = NO;
    } else {
        _bankNameLabel.hidden = YES;
        _debitCardImageView.image = [UIImage imageNamed:@"BankCardInvalid.png"];
    }
}

#pragma mark - action method

- (void)doneButtonPressed:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:lang(@"InputLoginPassword") message:nil delegate:self cancelButtonTitle:lang(@"Cancel") otherButtonTitles:lang(@"Confirm"), nil];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [[alertView textFieldAtIndex:0] setTintColor:[UIColor room107GreenColor]];
    [[alertView textFieldAtIndex:0] becomeFirstResponder];
    alertView.delegate = self ;
    
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
            [PopupView showMessage:lang(@"InvalidPassword")];
            return;
        }
        
        [self updateUserInfoWithPassword:[[alertView textFieldAtIndex:0] text]];
    }
}

- (void)updateUserInfoWithPassword:(NSString *)password {
    NSString *cardNumber = self.debitCardNumberTextField.text;
    NSString *name = self.name ? self.name : self.nameTextField.text;
    NSString *idCard = self.idCard ? self.idCard : self.idCardTextField.text;
    
    [self showLoadingView];
    WEAK_SELF weakSelf = self;
    [[UserAccountAgent sharedInstance] updateUserAccountInfoWithName:name idCard:idCard debitCard:cardNumber alipayNumber:nil andPassword:password andCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, BOOL success) {
        [weakSelf hideLoadingView];
        if (success) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else if (errorMsg) {
            
        }
    }];
}

@end
