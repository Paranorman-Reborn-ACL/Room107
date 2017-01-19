//
//  WalletView.m
//  room107
//
//  Created by 107间 on 16/3/29.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "WalletView.h"
#import "ReddieView.h"

@interface WalletView()

@property (nonatomic, strong) UIImageView *walletImageView; //钱包图标
@property (nonatomic, strong) UILabel *walletAmountLabel;   //钱包总额
@property (nonatomic, strong) UILabel *redBagAmountLabel;   //红包数
@property (nonatomic, strong) UIImageView *redBagImageView; //红包图标
@property (nonatomic, strong) UILabel *redBagLabel;         //“红包”
@property (nonatomic, strong) UILabel *balanceAmountLabel;  //余额数
@property (nonatomic, strong) UIImageView *balanceImageView;//余额图标
@property (nonatomic, strong) UILabel *balaneceLabel;       //"余额"
@property (nonatomic) ReddieView *couponRedDotView;
@property (nonatomic) ReddieView *balanceRedDotView;

@property (nonatomic, strong) UIView *leftTapView;
@property (nonatomic, strong) UIView *rightTapView;
@property (nonatomic, strong) UIView *verticaLine;
@property (nonatomic, strong) UIView *horizontalLine;

@property (nonatomic, strong) void(^tapCouponHandler)(void);
@property (nonatomic, strong) void(^tapBalanceHandler)(void);

@end

@implementation WalletView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor whiteColor]];
    if (self) {
        self.walletImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"walletImage"]];
        [self addSubview:_walletImageView];
        
        self.walletAmountLabel = [[UILabel alloc] init];
        [_walletAmountLabel setFont:[UIFont room107SystemFontFive]];
        [_walletAmountLabel setTextColor:[UIColor room107GrayColorE]];
        [self addSubview:_walletAmountLabel];
        
        _horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 132, frame.size.width, 1)];
        [_horizontalLine setBackgroundColor:[UIColor room107GrayColorA]];
        [self addSubview:_horizontalLine];
        
        CGFloat originY = CGRectGetMaxY(_horizontalLine.frame) + 11;
        CGFloat width = frame.size.width/2 - 0.5;
        
        _verticaLine = [[UIView alloc] initWithFrame:CGRectMake(width + 0.5, originY, 1, 42)];
        [_verticaLine setBackgroundColor:[UIColor room107GrayColorB]];
        [self addSubview:_verticaLine];
        
        self.redBagAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, width, 15)];
        [_redBagAmountLabel setFont:[UIFont room107SystemFontThree]];
        [_redBagAmountLabel setTextColor:[UIColor room107GrayColorD]];
        [_redBagAmountLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_redBagAmountLabel];
        
        self.balanceAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_verticaLine.frame), originY, width, 18)];
        [_balanceAmountLabel setFont:[UIFont room107SystemFontThree]];
        [_balanceAmountLabel setTextColor:[UIColor room107GrayColorD]];
        [_balanceAmountLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_balanceAmountLabel];
        
        CGFloat originX = (self.frame.size.width / 2 - 22 - 11 - 30) / 2;
        self.redBagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, CGRectGetMaxY(_balanceAmountLabel.frame)+5, 22, 22)];
        [_redBagImageView setImage:[UIImage imageNamed:@"redBagImage"]];
        [self addSubview:_redBagImageView];
        
        self.redBagLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_redBagImageView.frame) + 11, CGRectGetMinY(_redBagImageView.frame) + 3.5, 30, 15)];
        [_redBagLabel setTextAlignment:NSTextAlignmentCenter];
        [_redBagLabel setFont:[UIFont room107SystemFontTwo]];
        [_redBagLabel setTextColor:[UIColor room107GrayColorC]];
        [_redBagLabel setText:lang(@"RedBag")];
        [self addSubview:_redBagLabel];
        
        self.couponRedDotView = [[ReddieView alloc] initWithOrigin:CGPointMake(_redBagLabel.frame.size.width+2, -2)];
        [_couponRedDotView setHidden:YES];
        [self.redBagLabel addSubview:_couponRedDotView];
        
        self.balanceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_verticaLine.frame) + originX , CGRectGetMaxY(_balanceAmountLabel.frame) + 5, 22, 22)];
        [_balanceImageView setImage:[UIImage imageNamed:@"balanceImage"]];
        [self addSubview:_balanceImageView];
        
        self.balaneceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_balanceImageView.frame) + 11,  CGRectGetMinY(_balanceImageView.frame) + 3.5, 30, 18)];
        [_balaneceLabel setTextAlignment:NSTextAlignmentCenter];
        [_balaneceLabel setFont:[UIFont room107SystemFontTwo]];
        [_balaneceLabel setTextColor:[UIColor room107GrayColorC]];
        [_balaneceLabel setText:lang(@"Balance")];
        [self addSubview:_balaneceLabel];
        
        self.balanceRedDotView = [[ReddieView alloc] initWithOrigin:CGPointMake(_balaneceLabel.frame.size.width + 2, -2)];
        [_balanceRedDotView setHidden:YES];
        [self.balaneceLabel addSubview:_balanceRedDotView];
        
        _leftTapView = [[UIView alloc] initWithFrame:CGRectMake(0, 132, self.frame.size.width/2, 64)];
        UITapGestureRecognizer *leftTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftCouponDidSelected:)];
        [_leftTapView addGestureRecognizer:leftTap];
        [self addSubview:_leftTapView];
        
        _rightTapView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 132, self.frame.size.width/2, 64)];
        UITapGestureRecognizer *rightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightBalanceDidSelected:)];
        [_rightTapView addGestureRecognizer:rightTap];
        [self addSubview:_rightTapView];
    }
    return self;
}

- (void)setAmount:(NSNumber *)amount {
    if (_walletViewType == WalletType) {
        //钱包页
        NSString *valueString = [CommonFuncs moneyStrByDouble:[amount doubleValue] / 100];
        [_walletAmountLabel setText:valueString];
        [_walletAmountLabel sizeToFit];
        CGRect frame = _walletAmountLabel.frame;
        CGFloat originX = (self.frame.size.width - frame.size.width - 44 - 22)/2;
        CGFloat originY = 44.0f;
        CGFloat imageDiameter = 44.0f;
        [_walletImageView setFrame:CGRectMake(originX, originY, imageDiameter, imageDiameter)];
        originX = CGRectGetMaxX(_walletImageView.frame) + 22;
        [_walletAmountLabel setFrame:CGRectMake(originX, originY + 6, frame.size.width, frame.size.height)];
    } else  {
        //红包页 或者余额页
        UILabel *redTitleLabel = [[UILabel alloc] init];
        if (_walletViewType == CouponType) {
            [redTitleLabel setText:lang(@"RedBagHint")]; //可用于支付房租
        } else {
            [redTitleLabel setText:lang(@"BalanceHint")]; //可用于支付房租
        }
        [redTitleLabel setFont:[UIFont room107SystemFontTwo]];
        [redTitleLabel setTextColor:[UIColor room107GrayColorC]];
        [redTitleLabel sizeToFit];
        [self addSubview:redTitleLabel];
        
        NSString *valueString = [CommonFuncs moneyStrByDouble:[amount doubleValue] / 100];
        [_walletAmountLabel setText:valueString];
        [_walletAmountLabel sizeToFit];
        
        CGFloat maxWidth = _walletAmountLabel.frame.size.width > redTitleLabel.frame.size.width ? _walletAmountLabel.frame.size.width : redTitleLabel.frame.size.width;
        CGFloat originX = (self.frame.size.width - maxWidth - 44 - 22)/2;
        CGFloat originY = 44.0f;
        CGFloat imageDiameter = 44.0f;
        [_walletImageView setFrame:CGRectMake(originX, originY, imageDiameter, imageDiameter)];
        [_walletAmountLabel setFrame:CGRectMake(CGRectGetMaxX(_walletImageView.frame) + 22, originY, _walletAmountLabel.frame.size.width, _walletAmountLabel.frame.size.height)];
        [redTitleLabel setFrame:CGRectMake(CGRectGetMaxX(_walletImageView.frame) + 28, CGRectGetMaxY(_walletAmountLabel.frame),  redTitleLabel.frame.size.width,  redTitleLabel.frame.size.height)];
    }
}

- (void)setCouponBag:(NSNumber *)coupon {
    NSString *couponString = [CommonFuncs moneyStrByDouble:[coupon doubleValue] / 100];
    [_redBagAmountLabel setText:couponString];
}

- (void)setcouponNewUpdate:(NSNumber *)couponNewUpdate {
    [_couponRedDotView setHidden:![couponNewUpdate boolValue]];
}

- (void)setBalance:(NSNumber *)balance {
    NSString *balanceString = [CommonFuncs moneyStrByDouble:[balance doubleValue] / 100];
    [_balanceAmountLabel setText:balanceString];
}

- (void)setbalanceNewUpdate:(NSNumber *)balanceNewUpdate {
    [_balanceRedDotView setHidden:![balanceNewUpdate boolValue]];
}

- (void)setTotalBalance:(NSNumber *)totalBalance {
    CGFloat width = self.frame.size.width/3;
    CGFloat originY = CGRectGetMaxY(_horizontalLine.frame) + 11;
    
    UILabel *totalAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, width, 15)];
    [totalAmountLabel setFont:[UIFont room107FontThree]];
    [totalAmountLabel setTextColor:[UIColor room107GrayColorD]];
    [totalAmountLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:totalAmountLabel];
    NSString *totalBalanceString = [CommonFuncs moneyStrByDouble:[totalBalance doubleValue] / 100];
    [totalAmountLabel setText:totalBalanceString];

    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(totalAmountLabel.frame) + 9, width, 15)];
    [totalLabel setFont:[UIFont room107SystemFontTwo]];
    [totalLabel setTextColor:[UIColor room107GrayColorC]];
    [totalLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:totalLabel];
    [totalLabel setText:lang(@"HistoryTotal")];
}

- (void)setexpenses:(NSNumber *)expenses {
    CGFloat width = self.frame.size.width/3;
    CGFloat originY = CGRectGetMaxY(_horizontalLine.frame) + 11;
    
    UILabel *expensesAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, originY, width, 15)];
    [expensesAmountLabel setFont:[UIFont room107SystemFontThree]];
    [expensesAmountLabel setTextColor:[UIColor room107GrayColorD]];
    [expensesAmountLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:expensesAmountLabel];
    NSString *expensesString = [CommonFuncs moneyStrByDouble:[expenses doubleValue] / 100];
    [expensesAmountLabel setText:expensesString];
    
    UILabel *expensesLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, CGRectGetMaxY(expensesAmountLabel.frame) + 9, width, 15)];
    [expensesLabel setFont:[UIFont room107SystemFontTwo]];
    [expensesLabel setTextColor:[UIColor room107GrayColorC]];
    [expensesLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:expensesLabel];
    [expensesLabel setText:lang(@"UsedAmount")];
}

- (void)setwithdrawal:(NSNumber *)withdrawal {
    CGFloat width = self.frame.size.width/3;
    CGFloat originY = CGRectGetMaxY(_horizontalLine.frame) + 11;
    
    UILabel *withdrawalAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(width * 2, originY, width, 15)];
    [withdrawalAmountLabel setFont:[UIFont room107SystemFontThree]];
    [withdrawalAmountLabel setTextColor:[UIColor room107GrayColorD]];
    [withdrawalAmountLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:withdrawalAmountLabel];
    NSString *withdrawalString = [CommonFuncs moneyStrByDouble:[withdrawal doubleValue] / 100];
    [withdrawalAmountLabel setText:withdrawalString];
    
    UILabel *withdrawalLabel = [[UILabel alloc] initWithFrame:CGRectMake(width * 2, CGRectGetMaxY(withdrawalAmountLabel.frame) + 9, width, 15)];
    [withdrawalLabel setFont:[UIFont room107SystemFontTwo]];
    [withdrawalLabel setTextColor:[UIColor room107GrayColorC]];
    [withdrawalLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:withdrawalLabel];
    [withdrawalLabel setText:lang(@"CashAmount")];

}
//红包点击
- (IBAction)leftCouponDidSelected:(id)sender {
    if (_tapCouponHandler) {
        _tapCouponHandler();
    }
}

//余额点击
- (IBAction)rightBalanceDidSelected:(id)sender {
    if (_tapBalanceHandler) {
        _tapBalanceHandler();
    }
}

- (void)settapCouponHandler:(void (^)(void))tapCouponHandler {
    _tapCouponHandler = tapCouponHandler;
}

- (void)settapBalanceHandler:(void (^)(void))tapBalanceHandler {
    _tapBalanceHandler = tapBalanceHandler;
}

- (void)setWalletViewType:(WalletViewType)walletViewType {
    _walletViewType = walletViewType;
    switch (walletViewType) {
        case WalletType:
        {
            //钱包页
        }
            break;
        case CouponType:
        {
            [_walletImageView setImage:[UIImage imageNamed:@"redBagImage"]];
            //红包页
            [_leftTapView removeFromSuperview];
            [_rightTapView removeFromSuperview];
            [_redBagImageView removeFromSuperview];
            [_balanceImageView removeFromSuperview];
            CGFloat width = self.frame.size.width / 2  - 0.5;
            [_redBagLabel setText:lang(@"HistoryTotal")];
            [_redBagLabel setTextAlignment:NSTextAlignmentCenter];
            [_redBagLabel setFrame:CGRectMake(0, CGRectGetMaxY(_balanceAmountLabel.frame) + 9, width, 15)];
            [_balaneceLabel setText:lang(@"UsedAmount")];
            [_balaneceLabel setTextAlignment:NSTextAlignmentCenter];
            [_balaneceLabel setFrame:CGRectMake(CGRectGetMaxX(_verticaLine.frame), _redBagLabel.frame.origin.y, width, 15)];
            
        }
            break;
        case BalanceType:
        {
            [_walletImageView setImage:[UIImage imageNamed:@"balanceImage"]];
            //余额页
            [self.leftTapView removeFromSuperview];
            [self.rightTapView removeFromSuperview];
            [self.verticaLine removeFromSuperview];
            [self.redBagImageView removeFromSuperview];
            [self.redBagLabel removeFromSuperview];
            [self.redBagAmountLabel removeFromSuperview];
            [self.balanceAmountLabel removeFromSuperview];
            [self.balanceImageView removeFromSuperview];
            [self.balaneceLabel removeFromSuperview];
            
            CGFloat width = self.frame.size.width;
            CGFloat originY = CGRectGetMaxY(_horizontalLine.frame) + 11;
            UIView *leftVerticalLine = [[UIView alloc] initWithFrame:CGRectMake(width / 3, originY, 1, 42)];
            [leftVerticalLine setBackgroundColor:[UIColor room107GrayColorB]];
            [self addSubview:leftVerticalLine];
            
            UIView *rightVerticalLine = [[UIView alloc] initWithFrame:CGRectMake(width * 2 / 3, originY, 1, 42)];
            [rightVerticalLine setBackgroundColor:[UIColor room107GrayColorB]];
            [self addSubview:rightVerticalLine];
        }
            break;
        default:
            break;
    }
}
@end
