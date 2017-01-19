//
//  SuiteReportViewController.m
//  room107
//
//  Created by ningxia on 15/7/28.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SuiteReportViewController.h"
#import "CustomTextView.h"
#import "RoundedGreenButton.h"
#import "NXTextSwitch.h"
#import "SuiteAgent.h"
#import "NSString+Encoded.h"
#import "CustomLabel.h"

@interface SuiteReportViewController () <UITextViewDelegate>

@property (nonatomic, strong) CustomLabel  *thanksReport;
@property (nonatomic, strong) NXTextSwitch *suiteBeenRentedTextSwitch;
@property (nonatomic, strong) NXTextSwitch *reportBrokerTextSwitch;
@property (nonatomic, strong) NXTextSwitch *otherIssuesTextSwitch;
@property (nonatomic, strong) CustomTextView *otherIssuesTextView;
@property (nonatomic, strong) RoundedGreenButton *submitButton;
@property (nonatomic, strong) NSNumber *houseID;
@property (nonatomic, strong) NSNumber *roomID;
@property (nonatomic, assign) CGRect oldFrame;
@end

@implementation SuiteReportViewController

- (id)initWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID {
    self = [super init];
    if (self != nil) {
        _houseID = houseID;
        _roomID = roomID;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"Report")];
    
    self.thanksReport = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 11, self.view.frame.size.width, 20)];
    [_thanksReport setText:lang(@"ThanksReport")];
    [_thanksReport setFont:[UIFont room107SystemFontTwo]];
    [_thanksReport setTextColor:[UIColor room107YellowColor]];
    [_thanksReport setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_thanksReport];
    
    CGFloat originX = 20.0f;
    CGFloat textSwitchWidth = CGRectGetWidth(self.view.bounds) - 2 * originX;
    CGFloat textSwitchHeight = 30.0f;
    CGFloat originY = CGRectGetMaxY(_thanksReport.frame) + 33;
    
    _suiteBeenRentedTextSwitch = [[NXTextSwitch alloc] initWithFrame:(CGRect){originX, originY, textSwitchWidth, textSwitchHeight}];
    [_suiteBeenRentedTextSwitch setTitle:lang(@"SuiteBeenRented")];
    [self.view addSubview:_suiteBeenRentedTextSwitch];
    
    originY += CGRectGetHeight(_suiteBeenRentedTextSwitch.bounds) + 20;
    _reportBrokerTextSwitch = [[NXTextSwitch alloc] initWithFrame:(CGRect){originX, originY, textSwitchWidth, textSwitchHeight}];
    [_reportBrokerTextSwitch setTitle:lang(@"ReportBroker")];
    [self.view addSubview:_reportBrokerTextSwitch];
    
    originY += CGRectGetHeight(_reportBrokerTextSwitch.bounds) + 20;
    _otherIssuesTextSwitch = [[NXTextSwitch alloc] initWithFrame:(CGRect){originX, originY, textSwitchWidth, textSwitchHeight}];
    [_otherIssuesTextSwitch setTitle:lang(@"OtherIssues")];
    [self.view addSubview:_otherIssuesTextSwitch];
    WEAK_SELF weakSelf = self;
    [_otherIssuesTextSwitch setSwitchActionHandler:^(BOOL isOn) {
        weakSelf.otherIssuesTextView.hidden = !isOn;
    }];
    
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) - 2 * originX;
    CGFloat buttonHeight = 53.0f;
    CGRect frame = [CommonFuncs tableViewFrame];
    _submitButton = [[RoundedGreenButton alloc] initWithFrame:(CGRect){originX, frame.size.height - buttonHeight - 50 / 2, buttonWidth, buttonHeight}];
    [_submitButton setTitle:lang(@"Submit") forState:UIControlStateNormal];
    [_submitButton setTitle:lang(@"Submiting") forState:UIControlStateDisabled];
    [self.view addSubview:_submitButton];
    [_submitButton addTarget:self action:@selector(submitButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    originY += CGRectGetHeight(_otherIssuesTextSwitch.bounds) + 10;
    frame.origin.x += originX;
    frame.origin.y += originY;
    frame.size.width -= 2 * originX;
    frame.size.height -= originY + 50 + buttonHeight;

    _otherIssuesTextView = [[CustomTextView alloc] initWithFrame:frame];
    _otherIssuesTextView.hidden = YES;
    _otherIssuesTextView.delegate = self;
    [_otherIssuesTextView setPlaceholder:lang(@"ReportTips")];
    [self.view addSubview:_otherIssuesTextView];
    
    UITapGestureRecognizer *tapGestureRecgnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controlsResignFirstResponder)];
    [self.view addGestureRecognizer:tapGestureRecgnizer];
}

- (void)controlsResignFirstResponder {
    [_otherIssuesTextView resignFirstResponder];
}

- (IBAction)submitButtonDidClick:(id)sender {
    if (![_suiteBeenRentedTextSwitch isOn]) {
        if (![_reportBrokerTextSwitch isOn]) {
            if (![_otherIssuesTextSwitch isOn]) {
                [PopupView showMessage:lang(@"AtLeastOne")];
                
                return;
            } else {
                if ([_otherIssuesTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
                    [PopupView showMessage:lang(@"ContentIsEmpty")];
                    
                    return;
                }
            }
        }
    }
    
    _submitButton.enabled = NO;
    [_submitButton setBackgroundColor:[UIColor room107GrayColorC]];
    
    NSMutableDictionary *contentDic = [[NSMutableDictionary alloc] init];
    if ([_suiteBeenRentedTextSwitch isOn]) {
        [contentDic setObject:@"true" forKey:@"isRented"];
    }
    if ([_reportBrokerTextSwitch isOn]) {
        [contentDic setObject:@"true" forKey:@"isBroker"];
    }
    if ([_otherIssuesTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        [contentDic setObject:[[_otherIssuesTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] URLEncodedString] forKey:@"message"];
    }
    if (_houseID) {
        [contentDic setObject:_houseID forKey:@"houseId"];
    }
    if (_roomID) {
        [contentDic setObject:_roomID forKey:@"roomId"];
    }
    
    [self showLoadingView];
    [[SuiteAgent sharedInstance] reportSuiteWithContent:contentDic completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
        [self hideLoadingView];
        _submitButton.enabled = YES;
        [_submitButton setBackgroundColor:[UIColor room107GreenColor]];
        
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            [_suiteBeenRentedTextSwitch setOn:NO];
            [_reportBrokerTextSwitch setOn:NO];
            _otherIssuesTextView.text = @"";
            [PopupView showMessage:lang(@"ReportSuccess")];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [(CustomTextView *)textView showPlaceholder:textView.text.length == 0 ? YES : NO];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.submitButton.hidden = YES;
    self.oldFrame = self.view.frame;
    CGRect nowFrame = self.view.frame;
    nowFrame.origin.y -= 195.0f;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setFrame:nowFrame];
    }];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    self.submitButton.hidden = NO;
    [UIView animateWithDuration:0.25f animations:^{
        [self.view setFrame:self.oldFrame];
    }];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
