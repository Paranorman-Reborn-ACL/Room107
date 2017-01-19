//
//  LAGfirstGuide.m
//  LanuchImageTest
//
//  Created by 刘安国 on 15/10/27.
//  Copyright (c) 2015年 刘安国. All rights reserved.

#define proportionX  ([UIScreen mainScreen].bounds.size.width)/320
#define proportionY  ([UIScreen mainScreen].bounds.size.height)/480

#import "LAGfirstGuide.h"

@interface LAGfirstGuide()

@property (nonatomic, strong) UIView      *headView;          //状态栏View

@property (nonatomic, strong) UIImageView *electrombileImage; //电动车图片
@property (nonatomic, strong) UIImageView *personImage;       //人物图片
@property (nonatomic, strong) UIImageView *protectImage;      //遮罩图片
@property (nonatomic, strong) UIImageView *houseOneImage;     //房屋图片
@property (nonatomic, strong) UIImageView *houseTwoImage;
@property (nonatomic, strong) UIImageView *houseThreeImage;
@property (nonatomic, strong) UIImageView *houseFourImage;
@property (nonatomic, strong) UIImageView *tenant;            //租客图片

@property (nonatomic, strong) UIView *backView;               //正方形背景容器视图

/*
@property (nonatomic, strong) UILabel *upLabel;               //4号字label
@property (nonatomic, strong) UILabel *downLabel;             //2号字label
@property (nonatomic, strong) UIButton *leftButton;           //登陆/注册按钮
@property (nonatomic, strong) UIButton *rightButton;          //随便看看按钮
*/


@end
@implementation LAGfirstGuide

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
        [_headView setBackgroundColor:[UIColor room107PinkColor]];
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
        [_backView setBackgroundColor:[UIColor room107PinkColor]];
        
        [_backView addSubview:self.electrombileImage];
        [_backView addSubview:self.personImage];
        [_backView addSubview:self.protectImage];
        [_backView addSubview:self.houseOneImage];
        [_backView addSubview:self.houseTwoImage];
        [_backView addSubview:self.houseThreeImage];
        [_backView addSubview:self.houseFourImage];
        [_backView addSubview:self.tenant];
    }
    return _backView;
}

- (UIImageView *)electrombileImage{
    if (nil == _electrombileImage ) {
        _electrombileImage = [[UIImageView alloc]init];
        _electrombileImage.transform = CGAffineTransformMakeRotation(M_PI *.5);
       _electrombileImage.center = CGPointMake(64 * proportionX , 64 * proportionX );
       _electrombileImage.image = [UIImage imageNamed:@"新电动车"];
    }
    return _electrombileImage;
}

- (UIImageView *)personImage{
    if (nil == _personImage) {
        _personImage = [[UIImageView alloc]init];
        _personImage.transform = CGAffineTransformMakeRotation(M_PI *.5);
        _personImage.center = CGPointMake(135 * proportionX, 57 * proportionX);
        _personImage.image = [UIImage imageNamed:@"新中介"];
    }
    return _personImage ;
}

- (UIImageView *)protectImage{
    if (nil == _protectImage) {
        _protectImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 598*.5* proportionX, 434*.5* proportionX)];
        _protectImage.center = CGPointMake(341*.5 * proportionX , 421*.5* proportionX);
        _protectImage.image = [UIImage imageNamed:@"保护"];
        _protectImage.alpha = 0.0f ;
    }
    return _protectImage;
}

- (UIImageView *)houseOneImage{
    if (nil == _houseOneImage) {
        _houseOneImage = [[UIImageView alloc]init];
        _houseOneImage.center = CGPointMake(290*.5* proportionX, 566*.5* proportionX);
        _houseOneImage.image = [UIImage imageNamed:@"房子"];
    }
    return _houseOneImage;
}

- (UIImageView *)houseTwoImage{
    if (nil == _houseTwoImage) {
        _houseTwoImage = [[UIImageView alloc]init];
        _houseTwoImage.center = CGPointMake(230*0.5* proportionX, 416*0.5* proportionX);
        _houseTwoImage.image = [UIImage imageNamed:@"房子"];
    }
    return _houseTwoImage;
}

- (UIImageView *)houseThreeImage{
    if (nil == _houseThreeImage) {
        _houseThreeImage = [[UIImageView alloc]init];
        _houseThreeImage.center = CGPointMake(382*0.5* proportionX, 416*0.5* proportionX);
        _houseThreeImage.image = [UIImage imageNamed:@"房子"];
    }
    return _houseThreeImage;
}

- (UIImageView *)houseFourImage{
    if (nil == _houseFourImage) {
        _houseFourImage = [[UIImageView alloc]init];
        _houseFourImage.center =CGPointMake(526*0.5* proportionX, 350*0.5* proportionX);
        _houseFourImage.image = [UIImage imageNamed:@"房子"];
    }
    return _houseFourImage;
}

- (UIImageView *)tenant{
    if (nil == _tenant) {
        _tenant = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100* proportionX , 100* proportionX)];
        _tenant.center = CGPointMake(495*.5*proportionX, 540*.5*proportionX);
        _tenant.alpha = 0.0f;
        _tenant.image = [UIImage imageNamed:@"新租客"];
    }
    return _tenant;
}



//- (UIButton *)leftButton{
//    if (nil == _leftButton) {
//        _leftButton =[UIButton buttonWithType:UIButtonTypeCustom];
//        _leftButton.frame = CGRectMake(0, self.frame.size.height - 50 *proportionY , self.frame.size.width/2, 50 *proportionY );
//        [_leftButton setBackgroundColor:[UIColor colorWithRed:1.000 green:0.608 blue:0.709 alpha:1.000]];
//        [_leftButton setTitle:@"登录/注册" forState:UIControlStateNormal];
//        [_leftButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
//    }
//    return _leftButton;
//}
//
//- (UIButton *)rightButton{
//    if(nil == _rightButton ){
//        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _rightButton.frame = CGRectMake(self.frame.size.width/2,self.frame.size.height - 50 *proportionY , self.frame.size.width/2, 50 *proportionY );
//        [_rightButton setBackgroundColor:[UIColor colorWithRed:1.000 green:0.608 blue:0.709 alpha:1.000]];
//        [_rightButton setTitle:@"随便看看" forState:UIControlStateNormal];
//        [_rightButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
//    }
//    return _rightButton;
//}
//
//- (UILabel *)upLabel{
//    if (nil == _upLabel) {
//        _upLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.backView.frame) + 11*proportionY ,self.frame.size.width , 24 *proportionY)];
//        _upLabel.backgroundColor = [UIColor whiteColor];
//        _upLabel.textAlignment = 1;
//        _upLabel.font = [UIFont boldSystemFontOfSize:22];
//        
//        _upLabel.text = @"找房放心";
//    }
//    return _upLabel;
//}
//
//- (UILabel *)downLabel{
//    if (nil == _downLabel) {
//        _downLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.upLabel.frame) + 5 , self.frame.size.width, 13*proportionY)];
//        _downLabel.textAlignment = 1 ;
//        _downLabel.font = [UIFont systemFontOfSize:11];
//        //        _downLabel.backgroundColor = [UIColor blueColor];
//        _downLabel.text = @"xxxxxxxxxxxx";
//    }
//    return _downLabel;
//}
- (LAGSameView *)sameView{
    if (nil == _sameView ) {
        _sameView = [[LAGSameView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(self.backView.frame))];
        _sameView.buttonColor = [UIColor room107PinkColor];
        [_sameView setLabelString:lang(@"FindRoom") downString:lang(@"SmartFilterAndManualreview")];
    
    }
    return _sameView;
}

/**
 *  动画效果
 */
- (void)animationOfView{
    
    //第一次动画
    [UIView animateWithDuration:0.5 animations:^{
        [_tenant setAlpha:1.0f];
    } completion:^(BOOL finished) {
        
        //第二次动画
        [UIView animateWithDuration:0.5 animations:^{
            _houseOneImage.frame = CGRectMake(0, 0, 60*proportionX, 60* proportionX);
            _houseOneImage.center = CGPointMake(290*.5*proportionX, 566*.5* proportionX);
            
            _houseTwoImage.frame = CGRectMake(0, 0, 60*proportionX, 60*proportionX);
            _houseTwoImage.center = CGPointMake(230*0.5*proportionX, 416*0.5*proportionX);
            
            _houseThreeImage.frame= CGRectMake(0, 0, 60* proportionX, 60* proportionX);
            _houseThreeImage.center = CGPointMake(382*0.5* proportionX, 416*0.5* proportionX);
            
            _houseFourImage.frame = CGRectMake(0, 0, 60* proportionX, 60* proportionX);
            _houseFourImage.center =CGPointMake(526*0.5* proportionX, 350*0.5* proportionX);
            
        } completion:^(BOOL finished) {
            
            
            //第三次动画
            [UIView animateWithDuration:0.5 animations:^{
                  _electrombileImage.transform = CGAffineTransformMakeRotation(0);
                  _electrombileImage.frame = CGRectMake(0,0, 90* proportionX, 60* proportionX);
                  _electrombileImage.center = CGPointMake(64* proportionX, 64* proportionX);
                
                  _personImage.transform = CGAffineTransformMakeRotation(0);
                  _personImage.frame = CGRectMake(0, 0, 60* proportionX, 75* proportionX);
                  _personImage.center = CGPointMake(135* proportionX, 57* proportionX);
                
            } completion:^(BOOL finished) {
                
                //第四次动画
                [UIView animateWithDuration:0.5 animations:^{
                    _protectImage.alpha = 1.0f ;
                } completion:^(BOOL finished) {
                    
                }];
                
            }];
            
        }];
        
        
    }];
}
- (void)setStepColor:(UIColor *)color{
    [_headView setBackgroundColor:color];
    [_backView setBackgroundColor:color];
}

@end
