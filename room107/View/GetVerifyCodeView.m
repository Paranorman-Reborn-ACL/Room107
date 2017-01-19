//
//  GetVerifyCodeView.m
//  room107
//
//  Created by 107间 on 16/3/22.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "GetVerifyCodeView.h"
#import "AppPropertiesModel.h"
#import "SystemAgent.h"

static CGFloat cornerRadius = 4.0f; //圆角参数

@interface GetVerifyCodeView()

@property (nonatomic, strong) UIButton *getVerifyCodeButton; //获取验证码
@property (nonatomic, strong) UILabel *countdownLabel; //倒计时
@property (nonatomic, strong) NSTimer *verifyCodeTimer; //验证码定时器
@property (nonatomic, assign) NSUInteger countdown; //倒计时时间
@end

@implementation GetVerifyCodeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self.layer setCornerRadius:cornerRadius];
    self.layer.masksToBounds = YES;
    
    [self setBackgroundColor:[UIColor room107GrayColorC]];
    if (self) {
        self.getVerifyCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getVerifyCodeButton setFrame:self.bounds];
        [_getVerifyCodeButton.titleLabel setFont:[UIFont room107SystemFontTwo]];
        [_getVerifyCodeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [_getVerifyCodeButton setTitle:lang(@"GetVerifyCode") forState:UIControlStateNormal];
        [_getVerifyCodeButton addTarget:self action:@selector(getVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
        [_getVerifyCodeButton setBackgroundColor:[UIColor room107YellowColor]];
        [_getVerifyCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.countdownLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [_countdownLabel setBackgroundColor:[UIColor room107GrayColorC]];
        [_countdownLabel setTextColor:[UIColor whiteColor]];
        [_countdownLabel setFont:[UIFont room107SystemFontTwo]];
        _countdownLabel.textAlignment = NSTextAlignmentCenter;
        _countdownLabel.hidden = YES;
        
        [self addSubview:_countdownLabel];
        [self addSubview:_getVerifyCodeButton];
    }
    return self;
}

//获取验证码点击方法
- (IBAction)getVerifyCode:(id)sender {
    [self startCountdown];
    if ([self.delegate respondsToSelector:@selector(getVerifyCodeViewDidClick:)]) {
        [self.delegate getVerifyCodeViewDidClick:self];
    }
}

//开始倒计时
- (void)startCountdown {
    if (!_verifyCodeTimer) {
        _verifyCodeTimer = [NSTimer timerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(refreshCountdown)
                                                 userInfo:nil
                                                  repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:_verifyCodeTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop mainRunLoop] addTimer:_verifyCodeTimer forMode:UITrackingRunLoopMode];
        
    }
    AppPropertiesModel *appProperties = [[SystemAgent sharedInstance] getPropertiesFromLocal];
    self.countdown = [appProperties.verifyCodeInterval unsignedIntegerValue];
    if (_countdown == 0 ) {
        //第一次进入app没有网络，即appProperties为空，点击注册时候有网络，_countdown为0，给默认60；
        _countdown = 60;
    }
    [_countdownLabel setText:[NSString stringWithFormat:@"%lds", (unsigned long)_countdown]];
    _getVerifyCodeButton.hidden = YES;
    _countdownLabel.hidden = NO;

}

//刷新countdownlabel
- (void)refreshCountdown {
    _countdown -= 1;
    [_countdownLabel setText:[NSString stringWithFormat:@"%lds", (unsigned long)_countdown]];
    
    if (_countdown == 0) {
        //倒计时为0时候重新获取验证码
        [self stopCountdown];
        return;
    }
}

//停止倒计时
- (void)stopCountdown {
    [_verifyCodeTimer invalidate];
    _verifyCodeTimer = nil;
    _getVerifyCodeButton.hidden = NO;
    _countdownLabel.hidden = YES;
}

@end
