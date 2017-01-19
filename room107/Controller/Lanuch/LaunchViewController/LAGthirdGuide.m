//
//  LAGthirdGuide.m
//  LanuchImageTest
//
//  Created by 刘安国 on 15/10/27.
//  Copyright (c) 2015年 刘安国. All rights reserved.
//
#define proportionX  ([UIScreen mainScreen].bounds.size.width)/320
#define proportionY  ([UIScreen mainScreen].bounds.size.height)/480

#import "LAGthirdGuide.h"

@interface LAGthirdGuide()

@property (nonatomic, strong) UIView      *headView;          //状态栏View

@property (nonatomic, strong) UIView *backView; //动画背景图
@property (nonatomic, strong) UIImageView *personView;//人物图案
@property (nonatomic, strong) UIImageView *shieldView;//盾牌图案
@property (nonatomic, strong) UIImageView *lockView;  //锁图案
@property (nonatomic, strong) UIImageView *libraView; //天平图案
@property (nonatomic, strong) UIImageView *moneyView; //钱包图案

/*
@property (nonatomic, strong) UILabel *upLabel;               //4号字label
@property (nonatomic, strong) UILabel *downLabel;             //2号字label
@property (nonatomic, strong) UIButton *leftButton;           //登陆/注册按钮
@property (nonatomic, strong) UIButton *rightButton;          //随便看看按钮
*/

@end
@implementation LAGthirdGuide

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backView];
        
//        [self addSubview:self.upLabel];
//        [self addSubview:self.downLabel];
//        [self addSubview:self.leftButton];
//        [self addSubview:self.rightButton];
        
        [self addSubview:self.headView];
        [self addSubview:self.sameView];
    }
    return self;
}

- (UIView *)headView{
    if ( nil == _headView ) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width , 44 * proportionY)];
        [_headView setBackgroundColor:[UIColor room107BlueColor]];
//        UIImageView * logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 33*proportionY * 271/88, 33*proportionY)];
//        
//        [_headView addSubview:logoImage];
//        logoImage.image = [UIImage imageNamed:@"左上logo"];
    }
    return _headView;
}


- (UIView *)backView{
    if (nil == _backView ) {
        //动画视图父视图
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 44 * proportionY , self.frame.size.width, self.frame.size.width)];
        [_backView setBackgroundColor:[UIColor room107BlueColor]];

        [_backView addSubview:self.personView];
        [_backView addSubview:self.shieldView];
        [_backView addSubview:self.lockView];
        [_backView addSubview:self.libraView];
        [_backView addSubview:self.moneyView];
    }
    return _backView;
}

- (UIImageView *)personView{
    if ( nil == _personView ) {
        _personView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320*0.5*proportionX, 404*0.5*proportionX)];
        _personView.alpha = 0.0f;
        _personView.center = CGPointMake(160*proportionX, 438*0.5*proportionX);
        _personView.image = [UIImage imageNamed:@"1"];
    }
    return _personView;
}

- (UIImageView *)shieldView{
    if (nil == _shieldView) {
        _shieldView = [[UIImageView alloc]init];
        _shieldView.center = CGPointMake(50*proportionX, 144*proportionX);
        _shieldView.image = [UIImage imageNamed:@"04"];
    }
    return _shieldView;
}

- (UIImageView *)lockView{
    if (nil == _lockView) {
        _lockView = [[UIImageView alloc] init];
        _lockView.center = CGPointMake(110*proportionX, 80*proportionX);
        _lockView.image = [UIImage imageNamed:@"03"];
    }
    return _lockView;
}

- (UIImageView *)libraView{
    if (nil == _libraView) {
        _libraView = [[UIImageView alloc] init];
        _libraView.center = CGPointMake(205*proportionX, 80*proportionX);
        _libraView.image = [UIImage imageNamed:@"02"];
    }
    return _libraView;
}

- (UIImageView *)moneyView{
    if (nil == _moneyView) {
        _moneyView = [[UIImageView alloc] init];
        _moneyView.center = CGPointMake(552*0.5*proportionX, 288*0.5*proportionX);
        _moneyView.image = [UIImage imageNamed:@"01"];
    }
    return _moneyView;
}

/*
- (UIButton *)leftButton{
    if (nil == _leftButton) {
        _leftButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(0, self.frame.size.height - 50 *proportionY , self.frame.size.width/2, 50 *proportionY );
        [_leftButton setBackgroundColor:[UIColor colorWithRed:0.205 green:0.714 blue:1.000 alpha:1.000]];
        [_leftButton setTitle:@"登录/注册" forState:UIControlStateNormal];
        [_leftButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    }
    return _leftButton;
}

- (UIButton *)rightButton{
    if(nil == _rightButton ){
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(self.frame.size.width/2,self.frame.size.height - 50 *proportionY , self.frame.size.width/2, 50 *proportionY );
        [_rightButton setBackgroundColor:[UIColor colorWithRed:0.205 green:0.714 blue:1.000 alpha:1.000]];
        [_rightButton setTitle:@"随便看看" forState:UIControlStateNormal];
        [_rightButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    }
    return _rightButton;
}

- (UILabel *)upLabel{
    if (nil == _upLabel) {
        _upLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.backView.frame) + 11*proportionY ,self.frame.size.width , 24 *proportionY)];
        _upLabel.backgroundColor = [UIColor whiteColor];
        _upLabel.textAlignment = 1;
        _upLabel.font = [UIFont boldSystemFontOfSize:22];
        _upLabel.text = @"找房放心";
    }
    return _upLabel;
}

- (UILabel *)downLabel{
    if (nil == _downLabel) {
        _downLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.upLabel.frame) + 5 , self.frame.size.width, 13*proportionY)];
        _downLabel.textAlignment = 1 ;
        _downLabel.font = [UIFont systemFontOfSize:11];
        //        _downLabel.backgroundColor = [UIColor blueColor];
        _downLabel.text = @"xxxxxxxxxxxx";
    }
    return _downLabel;
}
 */

- (LAGSameView *)sameView{
    if ( nil == _sameView ) {
        _sameView = [[LAGSameView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(self.backView.frame))];
        _sameView.buttonColor = [UIColor room107BlueColor];
        [_sameView setLabelString:lang(@"RentalConfidence") downString:lang(@"MultipleLevelsOfSecurity")];
    }
    return _sameView;
}

- (void)animationOfView{
    [UIView animateWithDuration:0.5 animations:^{
        //第一次动画 0.5s淡入
        _personView.alpha = 1.0f;
    } completion:^(BOOL finished) {
       
         [UIView animateWithDuration:0.5 animations:^{
             //第二次动画 0.5s淡入
             _shieldView.frame = CGRectMake(0, 0, 60*proportionX, 60*proportionX);
             _shieldView.center = CGPointMake(50*proportionX, 144*proportionX);
             
             _lockView.frame = CGRectMake(0, 0, 60*proportionX, 60*proportionX);
             _lockView.center = CGPointMake(110*proportionX, 80*proportionX);
             
             _libraView.frame = CGRectMake(0, 0, 60*proportionX, 60*proportionX);
             _libraView.center = CGPointMake(205*proportionX, 80*proportionX);
             
             _moneyView.frame = CGRectMake(0, 0, 60*proportionX, 60*proportionX);
             _moneyView.center = CGPointMake(552*0.5*proportionX, 288*0.5*proportionX);
             
         } completion:^(BOOL finished) {
             
         }];
    }];
}
- (void)setStepColor:(UIColor *)color{
    [_headView setBackgroundColor:color];
    [_backView setBackgroundColor:color];
}

@end
