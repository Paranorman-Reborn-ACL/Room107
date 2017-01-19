//
//  LAGlanuchView.m
//  LanuchImageTest
//
//  Created by 刘安国 on 15/10/27.
//  Copyright (c) 2015年 刘安国. All rights reserved.
//

#define ScreenFrame [UIScreen mainScreen].bounds
#import "LAGlanuchView.h"
#import "CustomImageView.h"
#import "SystemAgent.h"

@interface LAGlanuchView()

@property (nonatomic, strong) CustomImageView *moveImageView; //移动视图 纹路 宽度屏幕100% 顶对齐
@property (nonatomic, strong) CustomImageView *logoImageView; //LOGO视图（上下左右居中 宽度屏幕60%）
@property (nonatomic, strong) CustomImageView *adImage;
@property (nonatomic, strong) UIButton *jumpButton;

@end

@implementation LAGlanuchView

- (CustomImageView *)moveImageView {
    if (nil == _moveImageView) {
        UIImage *moveImage = [UIImage imageNamed:@"launchSecond"];
        CGFloat imageHeight = ScreenFrame.size.width * moveImage.size.height/moveImage.size.width;
        _moveImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenFrame.size.width, imageHeight)];
        _moveImageView.image = moveImage;
    }
    return _moveImageView;
}

- (CustomImageView *)logoImageView {
    if (nil == _logoImageView) {
        UIImage *logoImage = [UIImage imageNamed:@"launchFirst"];
        CGFloat originX = ScreenFrame.size.width * 0.2;
        CGFloat imageWidth = originX * 3 ;
        CGFloat imageHeight = imageWidth * logoImage.size.height/logoImage.size.width;
        CGFloat originY = (ScreenFrame.size.height - imageHeight)/2;
        _logoImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(originX, originY, imageWidth, imageHeight)];
        _logoImageView.image = logoImage;
    }
    return _logoImageView;
}

- (CustomImageView *)adImage {
    if (nil == _adImage) {
        CGFloat height =ScreenFrame.size.width *1.78;
        CGFloat y = - height/2 + ScreenFrame.size.height/2;
        _adImage = [[CustomImageView alloc]initWithFrame:CGRectMake(0, y, ScreenFrame.size.width, height)];
        _adImage.userInteractionEnabled = YES ;
        [App.window addSubview:_adImage];
    }
    return _adImage;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.moveImageView];
        [self addSubview:self.logoImageView];
        [self addSubview:self.adImage];
    }
    return self;
}

- (UIButton *)jumpButton {
    if (nil == _jumpButton) {
        _jumpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _jumpButton.frame = CGRectMake(ScreenFrame.size.width-66, 22, 44, 22);
        [_jumpButton setTitle:@"跳过" forState:UIControlStateNormal];
        _jumpButton.backgroundColor = [UIColor whiteColor];
        _jumpButton.titleLabel.font = [UIFont room107FontTwo];
        _jumpButton.layer.cornerRadius = 3;
        _jumpButton.alpha = 0.8;
        [_jumpButton setTitleColor:[UIColor room107GrayColorD] forState:UIControlStateNormal];
        [_jumpButton addTarget:self action:@selector(jumpTo) forControlEvents:UIControlEventTouchUpInside];
    }
    return _jumpButton;
}
/**
 *  淡入动画效果
 */
-(void)changeFrameAndAlpha{
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [NSThread sleepForTimeInterval:kStopAnimationDuration];
        [_moveImageView setFrame:CGRectMake(0, -ScreenFrame.size.width/2, _moveImageView.frame.size.width, _moveImageView.frame.size.height)];
    } completion:^(BOOL finished) {
        [NSThread sleepForTimeInterval:kStopAnimationDuration];
        _moveImageView.alpha = 0.0f;
        _logoImageView.alpha = 0.0f;
        AppPropertiesModel *propertyInfo = [[SystemAgent sharedInstance]getPropertiesFromLocal];
        NSString *imageURL = propertyInfo.iosStartingAdImg;
        if (nil == imageURL) {
            [self hideStatusBar];
            self.hidden = YES;
        }else {
            WEAK_SELF weakSelf = self;
            WEAK(_jumpButton) weakJump = self.jumpButton;
            [_adImage setImageWithURL:imageURL withCompletionHandler:^(UIImage *image) {
                if (image) {
                [weakSelf addSubview:weakJump];
                }
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAdimageStopDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.backgroundColor = [UIColor clearColor];
                [self hideStatusBar];
                 [UIView animateWithDuration:0.8 animations:^{
                     self.jumpButton.alpha = 0.0f;
                     CGPoint center = _adImage.center;
                     CGRect frame   = _adImage.frame ;
                     _adImage.frame = CGRectMake(0, 0, frame.size.width*1.5, frame.size.height*1.5);
                     _adImage.center = center;
                     _adImage.alpha = 0;
                  } completion:^(BOOL finished) {
                      self.hidden = YES;
                 }];
            });
        }
    }];
}

- (void)jumpTo {
    self.backgroundColor = [UIColor clearColor];
    [self hideStatusBar];
    _moveImageView.alpha = 0.0f;
    _logoImageView.alpha = 0.0f;
    [UIView animateWithDuration:0.8 animations:^{
        self.jumpButton.alpha = 0.0f;
        CGPoint center = _adImage.center;
        CGRect frame   = _adImage.frame ;
        _adImage.frame = CGRectMake(0, 0, frame.size.width*1.5, frame.size.height*1.5);
        _adImage.center = center;
        _adImage.alpha = 0;
    }completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)hideStatusBar {
    if ([[AppClient sharedInstance] isLogin]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

@end
