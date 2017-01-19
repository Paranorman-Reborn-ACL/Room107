//
//  SubsidyInfoView.m
//  room107
//
//  Created by Naitong Yu on 15/8/21.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SubsidyInfoView.h"
#import "WalletItemView.h"

@interface SubsidyInfoView ()

@property (nonatomic) UILabel *accountMoneyTextLabel;
@property (nonatomic) UILabel *accountMoneyLabel;

@property (nonatomic) UILabel *walletTextLabel;
@property (nonatomic) WalletItemView *redBagItemView;
@property (nonatomic) WalletItemView *balanceItemView;

@end

@implementation SubsidyInfoView

- (void)setup {
    
    _accountMoneyTextLabel = [[UILabel alloc] init];
    _accountMoneyTextLabel.font = [UIFont room107FontTwo];
    _accountMoneyTextLabel.textColor = [UIColor room107GrayColorC];
    _accountMoneyTextLabel.text = lang(@"AccountMoney");
    [self addSubview:_accountMoneyTextLabel];
    
    _accountMoneyLabel = [[UILabel alloc] init];
    _accountMoneyLabel.font = [UIFont room107SystemFontFive];
    _accountMoneyLabel.textColor = [UIColor room107GreenColor];
    _accountMoneyLabel.backgroundColor = [UIColor whiteColor];
    _accountMoneyLabel.textAlignment = NSTextAlignmentCenter;
    _accountMoneyLabel.hidden = YES;
    [self addSubview:_accountMoneyLabel];
    
    _walletTextLabel = [[UILabel alloc] init];
    _walletTextLabel.font = [UIFont room107FontTwo];
    _walletTextLabel.textColor = [UIColor room107GrayColorC];
    _walletTextLabel.text = lang(@"Wallet");
    [self addSubview:_walletTextLabel];
    
    _redBagItemView = [[WalletItemView alloc] init];
    _redBagItemView.fontColor = [UIColor redColor];
    _redBagItemView.name = lang(@"RedBag");
    _redBagItemView.iconCode = @"e630";
    [self addSubview:_redBagItemView];
    
    _balanceItemView = [[WalletItemView alloc] init];
    _balanceItemView.fontColor = [UIColor room107YellowColor];
    _balanceItemView.name = lang(@"Balance");
    _balanceItemView.iconCode = @"e631";
    [self addSubview:_balanceItemView];
}

#pragma mark - layout

- (void)layoutSubviews {
    CGFloat originY = 11;
    CGFloat width = self.bounds.size.width;
    
    [_accountMoneyTextLabel sizeToFit];
    CGRect frame = _accountMoneyTextLabel.frame;
    frame.origin = CGPointMake(22, originY);
    _accountMoneyTextLabel.frame = frame;
    originY += CGRectGetHeight(frame) + 5;
    
    [_accountMoneyLabel sizeToFit];
    CGFloat circleDiameter = _accountMoneyLabel.frame.size.width + 30;
    _accountMoneyLabel.frame = CGRectMake(0, 0, circleDiameter, circleDiameter);
    _accountMoneyLabel.center = CGPointMake(width / 2, originY + circleDiameter / 2);
    _accountMoneyLabel.layer.cornerRadius = circleDiameter / 2;
    _accountMoneyLabel.layer.masksToBounds = YES;
    originY += circleDiameter + 10;
    
    [_walletTextLabel sizeToFit];
    frame = _walletTextLabel.frame;
    frame.origin = CGPointMake(22, originY);
    _walletTextLabel.frame = frame;
    originY += CGRectGetHeight(frame) + 5;
    
    _redBagItemView.frame = CGRectMake(11, originY, width - 2 * 11, 66);
    originY += 66 + 5;
    
    _balanceItemView.frame = CGRectMake(11, originY, width - 2 * 11, 66);
}

#pragma mark - getters and/or setters

- (void)setRedBagActionHandler:(void (^)(void))redBagActionHandler {
    [self.redBagItemView setTapWalletItemHandler:redBagActionHandler];
}

- (void)setBalanceActionHandler:(void (^)(void))balanceActionHandler {
    [self.balanceItemView setTapWalletItemHandler:balanceActionHandler];
}

- (void)setRedBagNumber:(double)redBagNumber {
    _redBagNumber = redBagNumber;
    _redBagItemView.amount = redBagNumber;
    
    [self updateAmountMoneyLabel];
}

- (void)setAccountBalanceNumber:(double)accountBalanceNumber {
    _accountBalanceNumber = accountBalanceNumber;
    _balanceItemView.amount = accountBalanceNumber;
    
    [self updateAmountMoneyLabel];
}

- (void)setRedBagNewUpdate:(BOOL)redBagNewUpdate {
    _redBagNewUpdate = redBagNewUpdate;
    _redBagItemView.newUpdate = redBagNewUpdate;
}

- (void)setAccountBalanceNewUpdate:(BOOL)accountBalanceNewUpdate {
    _accountBalanceNewUpdate = accountBalanceNewUpdate;
    _balanceItemView.newUpdate = accountBalanceNewUpdate;
}

- (void)updateAmountMoneyLabel {
    double totalAmount = _redBagNumber + _accountBalanceNumber;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSString *totalAmountString = [formatter stringFromNumber:[NSNumber numberWithDouble:totalAmount]];
    totalAmountString = [totalAmountString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:totalAmountString ? totalAmountString : @""
                                                                                attributes:@{NSForegroundColorAttributeName: [UIColor room107GreenColor]}];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont room107SystemFontTwo] range:NSMakeRange(0, 1)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont room107SystemFontFour] range:NSMakeRange(1, [attrStr length] - 1)];
    _accountMoneyLabel.attributedText = attrStr;
    _accountMoneyLabel.hidden = NO;
    [self setNeedsLayout];
}

#pragma mark - initialization

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

@end
