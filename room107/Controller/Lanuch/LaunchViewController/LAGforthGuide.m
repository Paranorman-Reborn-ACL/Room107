//
//  LAGforthGuide.m
//  LanuchImageTest
//
//  Created by 刘安国 on 15/10/27.
//  Copyright (c) 2015年 刘安国. All rights reserved.
//
#define proportionX  ([UIScreen mainScreen].bounds.size.width)/320
#define proportionY  ([UIScreen mainScreen].bounds.size.height)/480

#import "LAGforthGuide.h"

@interface LAGforthGuide()

@property (nonatomic, strong) UIView      *headView;          //状态栏View

@property (nonatomic, strong) UIView *backView; //动画背景图

@property (nonatomic, strong) UIImageView *phoneImage ; //手机
@property (nonatomic, strong) UIImageView *circleImage ; //过程环
@property (nonatomic, strong) UIImageView *firstStep ;  //第一步
@property (nonatomic, strong) UIImageView *secondStep ; //第二步
@property (nonatomic, strong) UIImageView *thirdStep ; //第三步
@property (nonatomic, strong) UIImageView *forthStep ; //第四步
@property (nonatomic, strong) UIImageView *fifthStep ; //第五步

/*
@property (nonatomic, strong) UILabel *upLabel;               //4号字label
@property (nonatomic, strong) UILabel *downLabel;             //2号字label
@property (nonatomic, strong) UIButton *leftButton;           //登陆/注册按钮
@property (nonatomic, strong) UIButton *rightButton;          //随便看看按钮
 */

@end

@implementation LAGforthGuide

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
     [self addSubview:self.backView];
//        
//     [self addSubview:self.upLabel];
//     [self addSubview:self.downLabel];
//     [self addSubview:self.leftButton];
//     [self addSubview:self.rightButton];
        
     [self addSubview:self.headView];
     [self addSubview:self.sameView];
    }
    return self;
}

- (UIView *)headView{
    if ( nil == _headView ) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width , 44 * proportionY)];
        [_headView setBackgroundColor:[UIColor room107GreenColor]];
//        UIImageView * logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 33*proportionY * 271/88, 33*proportionY)];
//        
//        [_headView addSubview:logoImage];
//        logoImage.image = [UIImage imageNamed:@"左上logo"];
    }
    return _headView;
}

- (UIView *)backView{
    if (nil == _backView) {
        //动画视图父视图
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 44 * proportionY , self.frame.size.width, self.frame.size.width)];
        [_backView setBackgroundColor:[UIColor room107GreenColor]];
        [_backView addSubview:self.phoneImage];
        [_backView addSubview:self.circleImage];
        [_backView addSubview:self.firstStep];
        [_backView addSubview:self.secondStep];
        [_backView addSubview:self.thirdStep];
        [_backView addSubview:self.forthStep];
        [_backView addSubview:self.fifthStep];
    }
    return _backView;
}

- (UIImageView *)phoneImage{
    if (nil == _phoneImage) {
        _phoneImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 480*0.5*proportionX, 540*0.5*proportionX)];
        _phoneImage.center =CGPointMake(320*0.5*proportionX, 370*0.5*proportionX);
        _phoneImage.image = [UIImage imageNamed:@"4-手机"];
        _phoneImage.alpha = 0.0f;
    }
    return _phoneImage;
}

- (UIImageView *)circleImage{
    if (nil == _circleImage) {
        _circleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 330*0.5*proportionX, 330*0.5*proportionX)];
        _circleImage.center = CGPointMake(320*0.5*proportionX, 432*0.5*proportionX);
        _circleImage.image = [UIImage imageNamed:@"4-6"];
        _circleImage.alpha = 0.0f;
    }
    return _circleImage;
}

- (UIImageView *)firstStep{
    if (nil == _fifthStep) {
        _firstStep = [[UIImageView alloc]init];
        _firstStep.image = [UIImage imageNamed:@"4-1"];
//        _firstStep.frame = CGRectMake(0, 0, 120*0.5*proportionX , 120*0.5*proportionX);
        _firstStep.center = CGPointMake(412*0.5*proportionX, 360*0.5*proportionX);
//        _firstStep.alpha = 0.0f;
    }
    return _firstStep;
}

- (UIImageView *)secondStep{
    if (nil == _secondStep) {
        _secondStep = [[UIImageView alloc]init];
        _secondStep.image = [UIImage imageNamed:@"4-2"];
//        _secondStep.frame = CGRectMake(0, 0, 120*0.5*proportionX , 120*0.5*proportionX);
        _secondStep.center = CGPointMake(446*0.5*proportionX, 514*0.5*proportionX);
    }
    return _secondStep;
}

- (UIImageView *)thirdStep{
    if (nil == _thirdStep) {
        _thirdStep = [[UIImageView alloc]init];
        _thirdStep.image = [UIImage imageNamed:@"4-3"];
//        _thirdStep.frame = CGRectMake(0, 0, 120*0.5*proportionX , 120*0.5*proportionX);
        _thirdStep.center = CGPointMake(294*0.5*proportionX, 570*0.5*proportionX);
    }
    return _thirdStep;
}

- (UIImageView *)forthStep{
    if (nil == _forthStep) {
        _forthStep = [[UIImageView alloc]init];
        _forthStep.image = [UIImage imageNamed:@"4-4"];
   //     _forthStep.frame = CGRectMake(0, 0, 120*0.5*proportionX , 120*0.5*proportionX);
        _forthStep.center = CGPointMake(176*0.5*proportionX, 448*0.5*proportionX);
    }
    return _forthStep;
}

- (UIImageView *)fifthStep{
    if (nil == _fifthStep) {
        _fifthStep = [[UIImageView alloc]init];
        _fifthStep.image = [UIImage imageNamed:@"4-5"];
//        _fifthStep.frame = CGRectMake(0, 0, 120*0.5*proportionX , 120*0.5*proportionX);
        _fifthStep.center = CGPointMake(248*0.5*proportionX, 330*0.5*proportionX);
    }
    return _fifthStep;
}

/*
- (UIButton *)leftButton{
    if (nil == _leftButton) {
        _leftButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(0, self.frame.size.height - 50 *proportionY , self.frame.size.width/2, 50 *proportionY );
        [_leftButton setBackgroundColor:[UIColor colorWithRed:1/255.0 green:159/255. blue:133/255. alpha:1.000]];
        [_leftButton setTitle:@"登录/注册" forState:UIControlStateNormal];
        [_leftButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    }
    return _leftButton;
}

- (UIButton *)rightButton{
    if(nil == _rightButton ){
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(self.frame.size.width/2,self.frame.size.height - 50 *proportionY , self.frame.size.width/2, 50 *proportionY );
        [_rightButton setBackgroundColor:[UIColor colorWithRed:1/255.0 green:159/255. blue:133/255. alpha:1.000]];
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
    if (nil == _sameView) {
        _sameView = [[LAGSameView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(self.backView.frame))];
        _sameView.buttonColor = [UIColor room107GreenColor];
        [_sameView setLabelString:lang(@"InternetEenters") downString:lang(@"TradingRemindRepairBillSigned")];
    }
    return _sameView;
}

- (void)animationOfView{
    [UIView animateWithDuration:0.5 animations:^{
        //0.5s手机淡入
        _phoneImage.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.25 animations:^{
            //0.5S circle和第一个图片淡入
            _circleImage.alpha = 1.0f;
            _firstStep.frame = CGRectMake(0, 0, 120*0.5*proportionX , 120*0.5*proportionX);
            _firstStep.center = CGPointMake(412*0.5*proportionX, 360*0.5*proportionX);
            
            //0.1s 后第二个图片淡入 动画持续0.25s GCD以此类推
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
            [UIView animateWithDuration:0.25 animations:^{
                _secondStep.frame = CGRectMake(0, 0, 120*0.5*proportionX , 120*0.5*proportionX);
                _secondStep.center = CGPointMake(446*0.5*proportionX, 514*0.5*proportionX);
                
                //第三张图
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
                    
                   [UIView animateWithDuration:0.25 animations:^{
                       _thirdStep.frame = CGRectMake(0, 0, 120*0.5*proportionX , 120*0.5*proportionX);
                       _thirdStep.center = CGPointMake(294*0.5*proportionX, 570*0.5*proportionX);
                       
                       //第四张图
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                           
                        [UIView animateWithDuration:0.25 animations:^{
                          _forthStep.frame = CGRectMake(0, 0, 120*0.5*proportionX , 120*0.5*proportionX);
                          _forthStep.center = CGPointMake(176*0.5*proportionX, 448*0.5*proportionX);
                          
                         //第五张图
                          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                              [UIView animateWithDuration:0.25 animations:^{
                                  _fifthStep.frame = CGRectMake(0, 0, 120*0.5*proportionX , 120*0.5*proportionX);
                                  _fifthStep.center = CGPointMake(248*0.5*proportionX, 330*0.5*proportionX);
                              } completion:^(BOOL finished) {
                              }];
                              
                               });
                           }];
                       });
                   }];
                });
            }];
        });
        } completion:^(BOOL finished) {
        }];
    }];
}
- (void)setStepColor:(UIColor *)color{
    [_headView setBackgroundColor:color];
    [_backView setBackgroundColor:color];
}
@end
