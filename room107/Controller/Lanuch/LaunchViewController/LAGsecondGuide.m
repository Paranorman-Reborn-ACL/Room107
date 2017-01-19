//
//  LAGsecondGuide.m
//  LanuchImageTest
//
//  Created by 刘安国 on 15/10/27.
//  Copyright (c) 2015年 刘安国. All rights reserved.
//
#define proportionX  ([UIScreen mainScreen].bounds.size.width)/320
#define proportionY  ([UIScreen mainScreen].bounds.size.height)/480

#import "LAGsecondGuide.h"

@interface LAGsecondGuide()

@property (nonatomic, strong) UIView      *headView;          //状态栏View

@property (nonatomic, strong) UIView *backView; //动画背景图

@property (nonatomic, strong) UIImageView *circleView; //圆形图
@property (nonatomic, strong) UIImageView *firstPhone;
@property (nonatomic, strong) UIImageView *secondPhone;
@property (nonatomic, strong) UIImageView *thirdPhone;
@property (nonatomic, strong) UIImageView *forthPhone;
@property (nonatomic, strong) UIImageView *fifthPhone;

/*
@property (nonatomic, strong) UILabel *upLabel;               //4号字label
@property (nonatomic, strong) UILabel *downLabel;             //2号字label
@property (nonatomic, strong) UIButton *leftButton;           //登陆/注册按钮
@property (nonatomic, strong) UIButton *rightButton;          //随便看看按钮
 */

@end
@implementation LAGsecondGuide

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
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
        [_headView setBackgroundColor:[UIColor room107YellowColor]];
    }
    return _headView;
}


- (UIView *)backView{
    if (nil == _backView ) {
        //动画视图父视图
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 44 * proportionY , self.frame.size.width, self.frame.size.width)];
        [_backView setBackgroundColor:[UIColor room107YellowColor]];
        
        [_backView addSubview:self.circleView];
        [_backView addSubview:self.firstPhone];
        [_backView addSubview:self.secondPhone];
        [_backView addSubview:self.thirdPhone];
        [_backView addSubview:self.forthPhone];
        [_backView addSubview:self.fifthPhone];
        
    }
    return _backView;
}

- (UIImageView *)circleView{
    if (nil == _circleView) {
        _circleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 450*0.5*proportionX , 450*0.5*proportionX)];
        _circleView.image = [UIImage imageNamed:@"0"];
        _circleView.center = CGPointMake(160*proportionX, 160*proportionX);
        _circleView.alpha = 0.0f;
    }
    return _circleView;
}

- (UIImageView *)firstPhone{
    if (nil == _fifthPhone) {
        _firstPhone = [[UIImageView alloc]init];
        _firstPhone.image = [UIImage imageNamed:@"2"];
        _firstPhone.center =CGPointMake(192*proportionX*0.5, 192*proportionX*0.5);
    }
    return _firstPhone;
}

- (UIImageView *)secondPhone{
    if (nil == _secondPhone) {
        _secondPhone = [[UIImageView alloc]init];
        _secondPhone.image = [UIImage imageNamed:@"2"];
        _secondPhone.center = CGPointMake(154*proportionX*0.5, 412*proportionX*0.5);
    }
    return _secondPhone;
}

- (UIImageView *)thirdPhone{
    if (nil == _thirdPhone) {
        _thirdPhone = [[UIImageView alloc]init];
        _thirdPhone.image = [UIImage imageNamed:@"2"];
        _thirdPhone.center = CGPointMake(396*proportionX*0.5, 480*proportionX*0.5);
    }
    return _thirdPhone;
}

- (UIImageView *)forthPhone{
    if (nil == _forthPhone) {
        _forthPhone = [[UIImageView alloc]init];
        _forthPhone.image = [UIImage imageNamed:@"2"];
        _forthPhone.center = CGPointMake(512*proportionX*0.5, 372*proportionX*0.5);
    }
    return _forthPhone;
}

- (UIImageView *)fifthPhone{
    if (nil == _fifthPhone) {
        _fifthPhone = [[UIImageView alloc]init];
        _fifthPhone.image = [UIImage imageNamed:@"2"];
        _fifthPhone.center = CGPointMake(432*proportionX*0.5, 142*proportionX*0.5);
    }
    return _fifthPhone;
}

/*

- (UIButton *)leftButton{
    if (nil == _leftButton) {
        _leftButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(0, self.frame.size.height - 50 *proportionY , self.frame.size.width/2, 50 *proportionY );
        [_leftButton setBackgroundColor:[UIColor colorWithRed:1.000 green:0.703 blue:0.101 alpha:1.000]];
        [_leftButton setTitle:@"登录/注册" forState:UIControlStateNormal];
        [_leftButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    }
    return _leftButton;
}

- (UIButton *)rightButton{
    if(nil == _rightButton ){
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(self.frame.size.width/2,self.frame.size.height - 50 *proportionY , self.frame.size.width/2, 50 *proportionY );
        [_rightButton setBackgroundColor:[UIColor colorWithRed:1.000 green:0.703 blue:0.101 alpha:1.000]];
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
    if (nil == _sameView ) {
        _sameView = [[LAGSameView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(self.backView.frame))];
        _sameView.buttonColor = [UIColor room107YellowColor];
        [_sameView  setLabelString:lang(@"RentOutFromWorry") downString:lang(@"PushedToTheTenantInterest")];
    }
    return _sameView;
}

- (void)animationOfView{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.circleView.alpha = 1.0f;
    } completion:^(BOOL finished) {
         
        [UIView animateWithDuration:0.5 animations:^{
            _firstPhone.frame = CGRectMake(0, 0, 150*proportionX*0.5, 150*proportionX*0.5);
            _firstPhone.center =CGPointMake(192*proportionX*0.5, 192*proportionX*0.5);
            
            _secondPhone.frame = CGRectMake(0, 0, 150*proportionX*0.5, 150*proportionX*0.5);
            _secondPhone.center = CGPointMake(154*proportionX*0.5, 412*proportionX*0.5);
            
            _thirdPhone.frame = CGRectMake(0, 0, 150*proportionX*0.5, 150*proportionX*0.5);
            _thirdPhone.center = CGPointMake(396*proportionX*0.5, 480*proportionX*0.5);
            
            _forthPhone.frame = CGRectMake(0, 0, 150*proportionX*0.5, 150*proportionX*0.5);
            _forthPhone.center = CGPointMake(512*proportionX*0.5, 372*proportionX*0.5);
            
            _fifthPhone.frame = CGRectMake(0, 0, 150*proportionX*0.5, 150*proportionX*0.5);
            _fifthPhone.center = CGPointMake(432*proportionX*0.5, 142*proportionX*0.5);
        } completion:^(BOOL finished) {
            
        }];
        
    }];
}

- (void)setStepColor:(UIColor *)color{
    [_headView setBackgroundColor:color];
    [_backView setBackgroundColor:color];
}
@end
