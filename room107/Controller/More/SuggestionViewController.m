//
//  SuggestionViewController.m
//  room107
//
//  Created by ningxia on 15/7/25.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SuggestionViewController.h"
#import "CustomTextView.h"
#import "RoundedGreenButton.h"
#import "SystemAgent.h"
#import "NSString+Encoded.h"
#import "CustomLabel.h"

@interface SuggestionViewController () <UITextViewDelegate>

@property (nonatomic, strong) CustomTextView *suggestionTextView;
@property (nonatomic, strong) RoundedGreenButton *submitButton;

@end

@implementation SuggestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"SuggestionBox")];
    
    CGFloat originX = 22.0f;
    CGFloat originY = CGRectGetHeight(self.view.bounds) - statusBarHeight - navigationBarHeight - 100;
    CGRect frame = (CGRect){0, originY, CGRectGetWidth(self.view.bounds), 100};
    SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"Submit") andAssistantButtonTitle:@""];
    [self.view addSubview:mutualBottomView];
    [mutualBottomView setMainButtonDidClickHandler:^{
        [self submitSuggestion];
    }];
    
    CGFloat labelHeight = 12;
    CGFloat spaceX = 22;
    CGFloat viewHeight = 60;
    originY -= spaceX / 2 + viewHeight + 5;
    CustomLabel *customerServiceLabel = [[CustomLabel alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth(self.view.bounds) - 2 * originX, labelHeight}];
    [customerServiceLabel setTextAlignment:NSTextAlignmentCenter];
    [customerServiceLabel setFont:[UIFont room107SystemFontOne]];
    [customerServiceLabel setTextColor:[UIColor room107GrayColorE]];
    [customerServiceLabel setText:lang(@"CustomerService")];
    [self.view addSubview:customerServiceLabel];
    
    labelHeight = 30;
    CustomTextView *textView = [[CustomTextView alloc] initWithFrame:(CGRect){originX, originY + CGRectGetHeight(customerServiceLabel.bounds) - 5, CGRectGetWidth(self.view.bounds) - 2 * originX, labelHeight}];
    textView.dataDetectorTypes = UIDataDetectorTypePhoneNumber; //使用UIDataDetectorTypes自动检测电话
    [textView setBackgroundColor:[UIColor clearColor]];
    textView.font = [UIFont room107FontThree];
    textView.textColor = [UIColor room107GreenColor];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    NSString *supportPhone = [[SystemAgent sharedInstance] getPropertiesFromLocal].supportPhone;
    NSString *support = [@"\ue65e " stringByAppendingString:supportPhone ? supportPhone : @"010-52882522"];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:[textView attributes]];
    [(NSMutableParagraphStyle *)attributes[NSParagraphStyleAttributeName] setAlignment:NSTextAlignmentCenter];
    [textView setAttributedText:[[NSAttributedString alloc] initWithString:support ? support : @"" attributes:attributes]];
    [self.view addSubview:textView];
    
    originY = 20;
    frame = self.view.frame;
    frame.origin.x += originX;
    frame.origin.y += originY;
    frame.size.width -= 2 * originX;
    frame.size.height -= statusBarHeight + navigationBarHeight + viewHeight + 100 + 2 * spaceX;
    _suggestionTextView = [[CustomTextView alloc] initWithFrame:frame];
    _suggestionTextView.delegate = self;
    [_suggestionTextView setPlaceholder:lang(@"SuggestionBoxTips")];
    [self.view addSubview:_suggestionTextView];

    UITapGestureRecognizer *tapGestureRecgnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controlsResignFirstResponder)];
    [self.view addGestureRecognizer:tapGestureRecgnizer];
}

- (void)controlsResignFirstResponder {
    [_suggestionTextView resignFirstResponder];
}

- (void)submitSuggestion {
    if ([_suggestionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [PopupView showMessage:lang(@"ContentIsEmpty")];
        
        return;
    }
    
    _submitButton.enabled = NO;
    [_submitButton setBackgroundColor:[UIColor room107GrayColorC]];
    NSString *suggestion = [[_suggestionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] URLEncodedString];
    
    [self showLoadingView];
    [[SystemAgent sharedInstance] feedbackWithMessage:suggestion completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
        [self hideLoadingView];
        _submitButton.enabled = YES;
        [_submitButton setBackgroundColor:[UIColor room107GreenColor]];
        
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            _suggestionTextView.text = @"";
            [PopupView showMessage:lang(@"SubmitSuccessTips")];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
            
            
        }
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    [(CustomTextView *)textView showPlaceholder:textView.text.length == 0 ? YES : NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
