//
//  WXLoginView.m
//  room107
//
//  Created by 107间 on 16/3/24.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "WXLoginView.h"
#import "WXApi.h"
#import "AuthenticationAgent.h"

@interface WXLoginView()<WXApiDelegate>

@end

@implementation WXLoginView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat labelWidth = 85;
        CGFloat labelHeight = 15;
        CGFloat originX = frame.size.width/2 - labelWidth/2;
        UILabel *wechatLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, 0, labelWidth, labelHeight)];
        [wechatLabel setTextColor:[UIColor room107GrayColorC]];
        [wechatLabel setFont:[UIFont room107SystemFontOne]];
        [wechatLabel setText:lang(@"WechatLogin")];
        [self addSubview:wechatLabel];
        
        CGFloat lineWidth = frame.size.width/2 - 66/2 - labelWidth/2;
        UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(22, 7.5, lineWidth, 1)];
        [leftLineView setBackgroundColor:[UIColor room107GrayColorC]];
        [self addSubview:leftLineView];
        
        UIView *rightLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(wechatLabel.frame) + 11, 7.5, lineWidth, 1)];
        [rightLineView setBackgroundColor:[UIColor room107GrayColorC]];
        [self addSubview:rightLineView];
        
        CGFloat buttonWidth = 60;
        originX = frame.size.width/2 - buttonWidth/2;
        CGFloat originY = CGRectGetMaxY(wechatLabel.frame) + 22;
        UIButton *wechatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [wechatButton setFrame:CGRectMake(originX, originY, buttonWidth, buttonWidth)];
        [wechatButton setBackgroundImage:[UIImage imageNamed:@"wechatLogin.png"] forState:UIControlStateNormal];
        [wechatButton addTarget:self action:@selector(wechatLogin:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:wechatButton];
    }
    return self;
}

- (IBAction)wechatLogin:(id)sender {
    [[AuthenticationAgent sharedInstance] getGrantParamsWithOauthPlatform:@3 comlpetion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *params, NSNumber *oauthPlatform) {
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        if (!errorCode) {
            NSString *scope = params[@"scope"];
            NSString *state = params[@"state"];
            SendAuthReq *req = [[SendAuthReq alloc] init];
            req.scope = scope;
            req.state = state;
            //第三方向微信终端发送一个SendAuthReq消息结构
            [WXApi sendReq:req];
        }
    }];
    if (_wechatLogin) {
        _wechatLogin();
    }
}

@end
