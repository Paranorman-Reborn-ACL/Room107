//
//  LeadUserView.m
//  room107
//
//  Created by 107间 on 15/11/16.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "LeadUserView.h"

@interface LeadUserView()

@property (nonatomic, strong) UIImageView *searchRoomView; //搜索房子
@property (nonatomic, strong) UIImageView *roomResourseView; //房源在这里
@property (nonatomic, strong) UIButton    *ikonwButton;   //我知道了按钮
@property (nonatomic, strong) UIImageView *publishRoomView; //发布房子
@property (nonatomic, strong) UIImageView *myWalletView;  //我的钱包
@property (nonatomic, strong) UIButton    *beginUse;     //开始使用
@property (nonatomic, strong) UIImageView *moreInfoView; //更多使用说明
@property (nonatomic, strong) UIImageView *backImageView; //左视图
@property (nonatomic, strong) UIImageView *listImageView; //表视图
@property (nonatomic, assign) NSInteger count;
@end
@implementation LeadUserView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        [self addSubview:self.searchRoomView];
        [self addSubview:self.roomResourseView];
        [self addSubview:self.ikonwButton];
        [self addSubview:self.publishRoomView];
        [self addSubview:self.myWalletView];
        [self addSubview:self.beginUse];
        [self addSubview:self.moreInfoView];
        [self addSubview:self.backImageView];
        [self addSubview:self.listImageView];
    }
    return self;
}

- (UIImageView *)searchRoomView {
    if (nil == _searchRoomView) {
        _searchRoomView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 150, 291/2, 99/2)];
        _searchRoomView.image = [UIImage imageNamed:@"searchRoom_291_99.png"];
    }
    return _searchRoomView;
}

- (UIImageView *)roomResourseView {
    if ( nil == _roomResourseView ) {
        _roomResourseView = [[UIImageView alloc]initWithFrame:CGRectMake(22, 316, 471/2, 154/2)];
        _roomResourseView.image = [UIImage imageNamed:@"roomResourse_471_154.png"];
    }
    return _roomResourseView;
}

- (UIButton *)ikonwButton {
    if (nil == _ikonwButton) {
        CGFloat buttonWidth = 236/2;
        CGFloat buttonHeight = 97/2;
        _ikonwButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ikonwButton setFrame:CGRectMake(self.frame.size.width/2-buttonWidth/2, self.frame.size.height-35-buttonHeight, buttonWidth, buttonHeight)];
        [_ikonwButton setImage:[UIImage imageNamed:@"iknow_236_97.png"] forState:UIControlStateNormal];
        [_ikonwButton addTarget:self action:@selector(clickIkonow) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ikonwButton;
}

- (UIImageView *)publishRoomView {
    if (nil == _publishRoomView) {
        _publishRoomView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 215, 153, 68)];
        _publishRoomView.image = [UIImage imageNamed:@"publishRoom_306_136.png"];
        _publishRoomView.hidden = YES ;
    }
    return _publishRoomView;
}

- (UIImageView *)myWalletView {
    if (nil == _myWalletView) {
        CGFloat viewWidth = 210/2;
        CGFloat viewHeight = 154/2;
        _myWalletView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 75/2 - viewWidth , 75, viewWidth, viewHeight)];
        _myWalletView.image = [UIImage imageNamed:@"myWallet_210_154.png"];
        _myWalletView.hidden = YES ;
    }
    return _myWalletView;
}

- (UIButton *)beginUse {
     if (nil == _beginUse) {
         _beginUse = [UIButton buttonWithType:UIButtonTypeCustom];
         _beginUse.frame = CGRectMake(0, 0, 234/2, 50);
         _beginUse.center = self.center;
         [_beginUse setImage:[UIImage imageNamed:@"beginUse_234_100.png"] forState:UIControlStateNormal];
         [_beginUse addTarget:self action:@selector(clickBegin) forControlEvents:UIControlEventTouchUpInside];
         _beginUse.hidden = YES ;
    }
    return _beginUse;
}

- (UIImageView *)moreInfoView {
    if (nil == _moreInfoView) {
        _moreInfoView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - 418/4, self.frame.size.height - 50 - 188/2, 418/2, 188/2)];
        _moreInfoView.image = [UIImage imageNamed:@"moreInfo_418_188.png"];
        _moreInfoView.hidden = YES;
    }
    return _moreInfoView;
}

- (UIImageView *)backImageView {
    if (nil == _backImageView ) {
        _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width*0.78,self.frame.size.height*0.14 - 20,95/2 ,50)];
        _backImageView.image = [UIImage imageNamed:@"back_95_100.png"];
        _backImageView.hidden = YES;
    }
    return _backImageView;
}

- (UIImageView *)listImageView {
    if (nil == _listImageView ) {
        _listImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, self.frame.size.height/2 - 600/4, 275/2, 300)];
        _listImageView.image = [UIImage imageNamed:@"listImage_275_600.png"];
        _listImageView.hidden = YES;
    }
    return _listImageView;
}
- (void)clickIkonow {
    if (self.count == 0 ) {
        self.searchRoomView.hidden = YES;
        self.roomResourseView.hidden = YES;
        self.myWalletView.hidden = NO;
        self.publishRoomView.hidden = NO;
        _count++;
    }else if (self.count == 1) {
        self.myWalletView.hidden = YES ;
        self.publishRoomView.hidden = YES;
        self.backImageView.hidden = NO;
        self.listImageView.hidden = NO;
        self.sliderBlock();
        _count++;
    }else if (self.count == 2) {
        self.backImageView.hidden = YES;
        self.listImageView.hidden = YES;
        self.ikonwButton.hidden = YES;
        self.beginUse.hidden = NO ;
//        self.moreInfoView.hidden = NO;
        self.sliderBackBlock();
    }
}

-(void)clickBegin {
    self.hidden = YES;
}
@end
