//
//  AddAlipayViewController.m
//  room107
//
//  Created by Naitong Yu on 15/9/24.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "AddAlipayViewController.h"
#import "UserAccountAgent.h"

@interface AddAlipayViewController () <UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) UILabel *bindCardTextLabel;
@property (nonatomic) UIView *alipayBackgroundView;
@property (nonatomic) UIImageView *alipayImageView;
@property (nonatomic) UIView *verticalSeperator;
@property (nonatomic) UITextField *alipayNumberTextField;

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

@end

@implementation AddAlipayViewController

- (instancetype)initWithName:(NSString *)name idCard:(NSString *)idCard {
    self = [super init];
    if (self) {
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
    [self setTitle:lang(@"AddAlipay")];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:_scrollView];
    
    _bindCardTextLabel = [[UILabel alloc] init];
    _bindCardTextLabel.font = [UIFont room107FontTwo];
    _bindCardTextLabel.textColor = [UIColor room107GrayColorC];
    _bindCardTextLabel.text = lang(@"PleaseBindYourAlipay");
    [self.scrollView addSubview:_bindCardTextLabel];
    
    _alipayBackgroundView = [[UIView alloc] init];
    _alipayBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:_alipayBackgroundView];
    
    _alipayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlipayInvalid.png"]];
    _alipayImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.alipayBackgroundView addSubview:_alipayImageView];
    
    _verticalSeperator = [[UIView alloc] init];
    _verticalSeperator.backgroundColor = [UIColor room107GrayColorC];
    [self.alipayBackgroundView addSubview:_verticalSeperator];
    
    _alipayNumberTextField = [[UITextField alloc] init];
    _alipayNumberTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:lang(@"PleaseInputAlipayNumber")
                                                                                      attributes:@{NSForegroundColorAttributeName: [UIColor room107GrayColorB]}];
    _alipayNumberTextField.font = [UIFont room107FontThree];
    _alipayNumberTextField.textColor = [UIColor room107GrayColorD];
    _alipayNumberTextField.borderStyle = UITextBorderStyleNone;
    _alipayNumberTextField.returnKeyType = UIReturnKeyDone;
    _alipayNumberTextField.tag = 333;
    _alipayNumberTextField.delegate = self;
    _alipayNumberTextField.tintColor = [UIColor room107GreenColor];
    [self.alipayBackgroundView addSubview:_alipayNumberTextField];
    
    _nameAndIdCardPromptLabel = [[UILabel alloc] init];
    _nameAndIdCardPromptLabel.font = [UIFont room107FontTwo];
    _nameAndIdCardPromptLabel.textColor = [UIColor room107GrayColorC];
    if (self.hasNameInfo) {
        _nameAndIdCardPromptLabel.text = lang(@"ConfirmIdentityInfo");
    } else {
        _nameAndIdCardPromptLabel.text = lang(@"YourNameAndIdCardNumber");
    }
    [self.scrollView addSubview:_nameAndIdCardPromptLabel];
    
    _nameAndIdCardBackgroundView = [[UIView alloc] init];
    _nameAndIdCardBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:_nameAndIdCardBackgroundView];
    
    _nameTextField = [[UITextField alloc] init];
    _nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:lang(@"AlipayCardHolderName")
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
    _idCardTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:lang(@"AlipayIdCardNumber")
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
    
    _alipayBackgroundView.frame = CGRectMake(0, originY, width, 46);
    _alipayImageView.frame = CGRectMake(22, 12, 22, 22);
    _verticalSeperator.frame = CGRectMake(55, 7.5, 1, 31);
    _alipayNumberTextField.frame = CGRectMake(67, 0, width - 67 - 22, 46);
    
    originY += 46 + 10 + 33;
    
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
    } else if (textField.tag == 333) {
        [textField resignFirstResponder];
    }
    return NO;
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
    NSString *alipayNumber = self.alipayNumberTextField.text;
    NSString *name = self.name ? self.name : self.nameTextField.text;
    NSString *idCard = self.idCard ? self.idCard : self.idCardTextField.text;
    
    [self showLoadingView];
    WEAK_SELF weakSelf = self;
    [[UserAccountAgent sharedInstance] updateUserAccountInfoWithName:name idCard:idCard debitCard:nil alipayNumber:alipayNumber andPassword:password andCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, BOOL success) {
        [weakSelf hideLoadingView];
        if (success) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else if (errorMsg) {
            
        }
    }];
}

@end
