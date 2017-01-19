//
//  SendPaperContractViewController.m
//  room107
//
//  Created by Naitong Yu on 10/9/15.
//  Copyright © 2015 107room. All rights reserved.
//

#import "SendPaperContractViewController.h"
#import "UserAccountAgent.h"

@interface SendPaperContractViewController () <UITextFieldDelegate>

@property (nonatomic) NSNumber *contractId;

@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) UILabel *promptLabel;

@property (nonatomic) UILabel *receiverAddressTextLabel;
@property (nonatomic) UIView *receiverAddressBackgroundView;
@property (nonatomic) UITextField *receiverAddressTextField;

@property (nonatomic) UILabel *receiverInfoTextLabel;
@property (nonatomic) UIView *receiverInfoBackgroundView;
@property (nonatomic) UITextField *receiverNameTextField;
@property (nonatomic) UIView *seperator;
@property (nonatomic) UITextField *receiverPhoneTextField;

@property (nonatomic) UIButton *confirmButton;

@property (nonatomic,assign) CGFloat heightKeyboard; //键盘高度
@end

@implementation SendPaperContractViewController

- (instancetype)initWithContractId:(NSNumber *)contractId {
    self = [super init];
    if (self) {
        self.contractId = contractId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [self setup];
}

- (void)hideKeyboard:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)setup {
    [self setTitle:lang(@"SendPaperContract")];
    
    _scrollView = [[UIScrollView alloc] init];
//    [_scrollView setBackgroundColor:[UIColor redColor]];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:_scrollView];
    
    _promptLabel = [[UILabel alloc] init];
    _promptLabel.font = [UIFont room107FontThree];
    _promptLabel.textColor = [UIColor room107YellowColor];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.numberOfLines = 0;
    _promptLabel.text = lang(@"SendPaperContractPrompt");
    [self.scrollView addSubview:_promptLabel];
    
    //收件人地址
    _receiverAddressTextLabel = [[UILabel alloc] init];
    _receiverAddressTextLabel.font = [UIFont room107FontTwo];
    _receiverAddressTextLabel.textColor = [UIColor room107GrayColorC];
    _receiverAddressTextLabel.text = lang(@"ReceiverAddress");
    [self.scrollView addSubview:_receiverAddressTextLabel];
    
    _receiverAddressBackgroundView = [[UIView alloc] init];
    _receiverAddressBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:_receiverAddressBackgroundView];
    //输入详细地址
    _receiverAddressTextField = [[UITextField alloc] init];
    _receiverAddressTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:lang(@"InputDetailAddress") attributes:@{NSForegroundColorAttributeName: [UIColor room107GrayColorB]}];
    _receiverAddressTextField.font = [UIFont room107FontThree];
    _receiverAddressTextField.textColor = [UIColor room107GrayColorD];
    _receiverAddressTextField.borderStyle = UITextBorderStyleNone;
    _receiverAddressTextField.tag = 111;
    _receiverAddressTextField.delegate = self;
    _receiverAddressTextField.tintColor = [UIColor room107GreenColor];
    _receiverAddressTextField.returnKeyType = UIReturnKeyContinue;
    [self.receiverAddressBackgroundView addSubview:_receiverAddressTextField];
    
    //收件人信息
    _receiverInfoTextLabel = [[UILabel alloc] init];
    _receiverInfoTextLabel.font = [UIFont room107FontTwo];
    _receiverInfoTextLabel.textColor = [UIColor room107GrayColorC];
    _receiverInfoTextLabel.text = lang(@"ReceiverInfo");
//    _receiverInfoTextLabel.text = @"2";
    [self.scrollView addSubview:_receiverInfoTextLabel];
    
    _receiverInfoBackgroundView = [[UIView alloc] init];
    _receiverInfoBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:_receiverInfoBackgroundView];
    
    //输入收件人姓名输入框
    _receiverNameTextField = [[UITextField alloc] init];
    _receiverNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:lang(@"InputReceiverName") attributes:@{NSForegroundColorAttributeName: [UIColor room107GrayColorB]}];
    _receiverNameTextField.font = [UIFont room107FontThree];
    _receiverNameTextField.textColor = [UIColor room107GrayColorD];
    _receiverNameTextField.borderStyle = UITextBorderStyleNone;
    _receiverNameTextField.tag = 222;
    _receiverNameTextField.delegate = self;
    _receiverNameTextField.tintColor = [UIColor room107GreenColor];
    _receiverNameTextField.returnKeyType = UIReturnKeyContinue;
    [self.receiverInfoBackgroundView addSubview:_receiverNameTextField];
    
    //分割线
    _seperator = [[UIView alloc] init];
    _seperator.backgroundColor = [UIColor room107GrayColorC];
    [self.receiverInfoBackgroundView addSubview:_seperator];
    
    //输入收件人电话号码
    _receiverPhoneTextField = [[UITextField alloc] init];
    _receiverPhoneTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:lang(@"InputReceiverPhone") attributes:@{NSForegroundColorAttributeName: [UIColor room107GrayColorB]}];
    _receiverPhoneTextField.font = [UIFont room107FontThree];
    _receiverPhoneTextField.textColor = [UIColor room107GrayColorD];
    _receiverPhoneTextField.borderStyle = UITextBorderStyleNone;
    _receiverPhoneTextField.tag = 333;
    _receiverPhoneTextField.delegate = self;
    _receiverPhoneTextField.tintColor = [UIColor room107GreenColor];
    _receiverPhoneTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _receiverPhoneTextField.returnKeyType = UIReturnKeyDone;
    [self.receiverInfoBackgroundView addSubview:_receiverPhoneTextField];
    
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
    _scrollView.frame = frame;
    _scrollView.contentSize = frame.size;
    
    CGFloat originY = 11;
    CGFloat width = self.scrollView.bounds.size.width;
    CGFloat height = self.scrollView.bounds.size.height;
    
    [_promptLabel sizeToFit];
    frame = _promptLabel.frame;
    frame.origin = CGPointMake(width / 2 - CGRectGetWidth(frame) / 2, originY);
    _promptLabel.frame = frame;
    originY += CGRectGetHeight(frame) + 11;
    
    [_receiverAddressTextLabel sizeToFit];
    frame = _receiverAddressTextLabel.frame;
    frame.origin = CGPointMake(22, originY);
    _receiverAddressTextLabel.frame = frame;
    originY += CGRectGetHeight(frame) + 5;
    
    _receiverAddressBackgroundView.frame = CGRectMake(22, originY, width - 44, 46);
    _receiverAddressTextField.frame = CGRectMake(11, 0, width - 66, 46);
    originY += 46 + 33;
    
    [_receiverInfoTextLabel sizeToFit];
    frame = _receiverInfoTextLabel.frame;
    frame.origin = CGPointMake(22, originY);
    _receiverInfoTextLabel.frame = frame;
    originY += CGRectGetHeight(frame) + 5;
    
    _receiverInfoBackgroundView.frame = CGRectMake(22, originY, width - 44, 93);
    _receiverNameTextField.frame = CGRectMake(11, 0, width - 66, 46);
    _receiverPhoneTextField.frame = CGRectMake(11, 47, width - 66, 46);
    _seperator.frame = CGRectMake(11, 46, width - 66, 0.5);
    
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
    switch (textField.tag) {
        case 111:
            [textField resignFirstResponder];
            [self.receiverNameTextField becomeFirstResponder];
            break;
        case 222:
            [textField resignFirstResponder];
            [self.receiverPhoneTextField becomeFirstResponder];
            break;
        case 333:
            [textField resignFirstResponder];
            break;
        default:
            break;
    }
    return NO;
}

//开始编辑输入框的时候，软键盘出现，执行此事件
- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    LogDebug(@"%d",textField.tag);
//    
//    CGRect frame = textField.frame;
//    if (textField.tag == 111) {
//        frame = [self.view convertRect:frame fromView:self.receiverAddressBackgroundView];
//    }
//    else {
//        frame = [self.view convertRect:frame fromView:self.receiverInfoBackgroundView];
//    }
//    int offset = frame.origin.y + 46 - (self.view.frame.size.height - 216); //keyboard height 216
//    NSTimeInterval animationDuration = 0.30f;
//    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    
//    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
//    if(offset > 0)
//        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
//    
//    [UIView commitAnimations];
    CGFloat bottomY = CGRectGetMaxY(_receiverInfoBackgroundView.frame);
    LogDebug(@"%f   ===  %f ",self.view.frame.size.height-bottomY-64,self.heightKeyboard);
    
    CGFloat difference = self.heightKeyboard - (self.view.frame.size.height - bottomY - 64) ;
    if (difference>0) {
    switch (textField.tag) {
        case 111:{
           [UIView animateWithDuration:0.5 animations:^{
               _scrollView.contentOffset = CGPointMake(0, 0);
           }];
            break;
        }
        case 222:{
            [UIView animateWithDuration:0.5 animations:^{
                _scrollView.contentOffset = CGPointMake(0, difference/2 + 5);
            }];
            break;
        }
        default:
            [UIView animateWithDuration:0.5 animations:^{
                _scrollView.contentOffset = CGPointMake(0, difference + 5);
            }];
            break;
        }
    }
}

//输入框编辑完成以后，将视图恢复到原始状态
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.view.frame = CGRectMake(0, statusBarHeight + navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        _scrollView.contentOffset = CGPointMake(0, 0);
    }];
}


//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    self.heightKeyboard = keyboardRect.size.height;
}


#pragma mark - action method
- (void)doneButtonPressed:(UIButton *)sender {
    NSString *address =  self.receiverAddressTextField.text;
    NSString *name = self.receiverNameTextField.text;
    NSString *phone = self.receiverPhoneTextField.text;
    
    if (!address || address.length == 0) {
        [PopupView showMessage:lang(@"InputDetailAddress")];
        return;
    }
    if (!name || name.length == 0) {
        [PopupView showMessage:lang(@"InputReceiverName")];
        return;
    }
    if (!phone || phone.length == 0) {
        [PopupView showMessage:lang(@"InputReceiverPhone")];
        return;
    }
    
    [self showLoadingView];
    [[UserAccountAgent sharedInstance] sendContractWithContractId:self.contractId address:address receiverName:name receiverPhone:phone completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, BOOL success) {
        [self hideLoadingView];
        if (success) {
            [self showAlertViewWithTitle:lang(@"MailApplySuccess") message:lang(@"ArriveTime")];
        } else if (errorMsg) {
            
        }
    }];
}

@end
