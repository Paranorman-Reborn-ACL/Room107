//
//  LAGSameView.m
//  LanuchImageTest
//
//  Created by 刘安国 on 15/10/28.
//  Copyright (c) 2015年 刘安国. All rights reserved.
//
#define proportionX  ([UIScreen mainScreen].bounds.size.width)/320
#define proportionY  ([UIScreen mainScreen].bounds.size.height)/480

#import "LAGSameView.h"

@interface LAGSameView()

@property (nonatomic, strong) UILabel *upLabel;               //4号字label
@property (nonatomic, strong) UILabel *downLabel;             //2号字label
//@property (nonatomic, strong) UIButton *leftButton;           //登陆/注册按钮
//@property (nonatomic, strong) UIButton *rightButton;          //随便看看按钮

@end
@implementation LAGSameView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.upLabel];
        [self addSubview:self.downLabel];
//        [self addSubview:self.leftButton];
//        [self addSubview:self.rightButton];
    }
    return self;
}

//- (UIButton *)leftButton{
//    if (nil == _leftButton) {
//        _leftButton =[UIButton buttonWithType:UIButtonTypeCustom];
//        _leftButton.frame = CGRectMake(0, self.frame.size.height - 50 *proportionY , self.frame.size.width/2, 50 *proportionY );
//        [_leftButton setTitle:@"登录/注册" forState:UIControlStateNormal];
//        [_leftButton.titleLabel setFont:[UIFont room107SystemFontThree]];
//        [_leftButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _leftButton;
//}
//
//- (UIButton *)rightButton{
//    if(nil == _rightButton ){
//        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _rightButton.frame = CGRectMake(self.frame.size.width/2,self.frame.size.height - 50 *proportionY , self.frame.size.width/2, 50 *proportionY );
//        [_rightButton setTitle:@"随便看看" forState:UIControlStateNormal];
////        [_rightButton.titleLabel setText:@"随便看看"];
//        [_rightButton.titleLabel setFont:[UIFont room107SystemFontThree]];
//        [_rightButton addTarget:self action:@selector(look) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _rightButton;
//}

- (UILabel *)upLabel{
    if (nil == _upLabel) {
        _upLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10 * proportionY, self.frame.size.width , 24 * proportionY)];
        _upLabel.textColor = [UIColor room107GrayColorD];
        _upLabel.textAlignment = 1;
        _upLabel.font = [UIFont room107FontFour];
    }
    return _upLabel;
}

- (UILabel *)downLabel{
    if (nil == _downLabel) {
        _downLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.upLabel.frame) + 2 , self.frame.size.width, 15 * proportionY)];
        _downLabel.textAlignment = 1 ;
//        [_downLabel setBackgroundColor:[UIColor blackColor]];
        _downLabel.font = [UIFont room107FontTwo];
        _downLabel.textColor = [UIColor room107GrayColorC];

    }
    return _downLabel;
}

//- (void)setButtonColor:(UIColor *)buttonColor{
//    _buttonColor = buttonColor ;
//    [_leftButton setBackgroundColor:self.buttonColor];
//    [_rightButton setBackgroundColor:self.buttonColor];
//    
//}

- (void)setLabelString:(NSString *)upString downString:(NSString *)downString{
    [_upLabel setText:upString];
    [_downLabel setText:downString];
}

@end
