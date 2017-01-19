//
//  OnlineContractCommitmentViewController.m
//  room107
//
//  Created by 107间 on 15/12/1.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "OnlineContractCommitmentViewController.h"
#import "CustomImageView.h"
#import "CustomLabel.h"
#import "CustomButton.h"
#import "RoundedGreenButton.h"
#import "PostSuiteViewController.h"
#import "LicenseAgreementView.h"

@interface OnlineContractCommitmentViewController()

@property (nonatomic, strong) CustomImageView *imageView;
@property (nonatomic, strong) CustomButton *learnMore; //了解更多按钮
@property (nonatomic, strong) LicenseAgreementView *licenseAgreementView; //接受线上签约
@property (nonatomic, strong) CustomLabel *graycLabel;
@property (nonatomic, strong) RoundedGreenButton *bottomNextStep;//底部按钮 green 高106 距左右44 距底88 内部4号字 上下左右居中 white
@property (nonatomic, strong) UIScrollView *bkgScroll;
@property (nonatomic) OnlineContractCommitmentViewType onlineContractCommitmentViewType;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, assign) BOOL toNext;  //”下一步“或者“了解更多”页面

@end

@implementation OnlineContractCommitmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = lang(@"OnlineContractCommitment");
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _onlineContractCommitmentViewType = OnlineContractCommitmentViewTypeNew;
    
    self.bkgScroll = [[UIScrollView alloc]initWithFrame:self.view.frame];
    _bkgScroll.showsVerticalScrollIndicator = NO ;
    [_bkgScroll setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_bkgScroll];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = width * 1120/640;
    self.imageView = [[CustomImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [_imageView setImageWithName:@"postSuiteAD"];
    [_bkgScroll addSubview:_imageView];
    
    CGFloat learnWidth = 100.0f;
    CGFloat originX = 11.0f;
    CGFloat between = 33.0f;
    CGFloat moreHeight = 20.0f;
    self.learnMore = [CustomButton buttonWithType:UIButtonTypeCustom];
    [_learnMore setFrame:CGRectMake( width - learnWidth - originX, CGRectGetMaxY(_imageView.frame) - moreHeight, learnWidth, moreHeight)];
    [_learnMore setTitle:[lang(@"LearnMore") stringByAppendingString:@">>"] forState:UIControlStateNormal];
    [_learnMore.titleLabel setFont:[UIFont room107SystemFontTwo]];
    [_learnMore addTarget:self action:@selector(getMore) forControlEvents:UIControlEventTouchUpInside];
    [_bkgScroll addSubview:_learnMore];
    
    _licenseAgreementView = [[LicenseAgreementView alloc] initWithFrame:(CGRect){originX - 2, CGRectGetMaxY(_learnMore.frame) + between, width - originX * 2 + 6, 45} withContent:lang(@"AcceptOnlineSign")];
    [_bkgScroll addSubview:_licenseAgreementView];

    self.graycLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(originX, CGRectGetMaxY(_licenseAgreementView.frame)+originX/2, width - originX * 2 , 55)];
    [_graycLabel setTextColor:[UIColor room107GrayColorC]];
    [_graycLabel setFont:[UIFont room107FontOne]];
    [_graycLabel setAttributedText:[self getLineSpaceStringWithString:lang(@"FriendshipPrompt") andLineSpace:5]];
    [_graycLabel setTextAlignment:NSTextAlignmentLeft];
    [_graycLabel setNumberOfLines:0];
    [_bkgScroll addSubview:_graycLabel];
    
    self.bottomNextStep = [[RoundedGreenButton alloc]initWithFrame:CGRectMake(originX, CGRectGetMaxY(_graycLabel.frame) + originX*2, width - originX * 2 , 53)];
    [_bottomNextStep setBackgroundColor:[UIColor room107GreenColor]];
    [_bottomNextStep.titleLabel setFont:[UIFont room107FontFour]];
    [_bottomNextStep setTitle:lang(@"NextStep") forState:UIControlStateNormal];
    [_bottomNextStep addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [_bkgScroll addSubview:_bottomNextStep];
    
    [_bkgScroll setContentSize:CGSizeMake(0, CGRectGetMaxY(_bottomNextStep.frame) + originX*2 + statusBarHeight + navigationBarHeight)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_onlineContractCommitmentViewType != OnlineContractCommitmentViewTypeManage) {
        if (![[AppClient sharedInstance] isLogin]) {
            if (_toNext) {
                [self.navigationController popViewControllerAnimated:YES];
                _toNext = NO;
            } else {
                [[NXURLHandler sharedInstance] handleOpenURL:userLoginURI params:nil context:self];
                _toNext = YES;
            }
        } else {
            _toNext = NO;
        }
    } else {
        _toNext = NO;
    }
}

/*
 URLParams:{
  "rootViewController":viewController
 }
 */
- (void)setURLParams:(NSDictionary *)URLParams {
    _rootViewController = URLParams[@"rootViewController"];
}

- (id)initWithRootViewController:(UIViewController *)viewController {
    self = [super init];
    if (self != nil) {
        _rootViewController = viewController;
    }
    
    return self;
}

- (OnlineContractCommitmentViewType)onlineContractCommitmentViewType {
    return _onlineContractCommitmentViewType;
}

- (NSMutableAttributedString *)getLineSpaceStringWithString:(NSString *)str andLineSpace:(CGFloat)lineSpace {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:str ? str : @""];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
    return attributedString;
}

- (void)nextStep {
    _toNext = YES ;
    if (_licenseAgreementView.status) {
        [self.navigationController pushViewController:[[PostSuiteViewController alloc] initWithRootViewController:_rootViewController] animated:YES];
    } else {
        [self showAlertViewWithTitle:lang(@"NotAccept") message:lang(@"PleaseAccept")];
    }
}

- (void)getMore {
    _toNext = YES;
    [self viewSignExplanation];
}

@end
