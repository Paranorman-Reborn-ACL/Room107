//
//  WalletItemView.m
//  room107
//
//  Created by Naitong Yu on 15/8/21.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "WalletItemView.h"
#import "IconLabel.h"
#import "ReddieView.h"

@interface WalletItemView ()

@property (nonatomic, strong) void(^tapWalletItemHandler)(void);

@property (nonatomic) IconLabel *iconLabel;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *amountLabel;
@property (nonatomic) ReddieView *redDotView;

@end

@implementation WalletItemView

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 11;
    self.layer.masksToBounds = YES;
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:recognizer];
    
    _fontColor = [UIColor room107GrayColorD];
    
    _iconLabel = [[IconLabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self addSubview:_iconLabel];
    
    _nameLabel = [[UILabel alloc] init];
    [self addSubview:_nameLabel];
    
    _amountLabel = [[UILabel alloc] init];
    [self addSubview:_amountLabel];
}

- (void)layoutSubviews {
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    
    CGRect frame = self.iconLabel.frame;
    frame.origin = CGPointMake(22, height / 2 - CGRectGetHeight(frame) / 2);
    self.iconLabel.frame = frame;
    
    [self.nameLabel sizeToFit];
    frame = self.nameLabel.frame;
    frame.origin = CGPointMake(52, height / 2 - CGRectGetHeight(frame) / 2);
    self.nameLabel.frame = frame;
    
    [self.amountLabel sizeToFit];
    frame = self.amountLabel.frame;
    frame.origin = CGPointMake(width - 22 - CGRectGetWidth(frame), height / 2 - CGRectGetHeight(frame) / 2);
    self.amountLabel.frame = frame;
    
    _redDotView = [[ReddieView alloc] initWithOrigin:CGPointMake(width - 40, height / 2 - CGRectGetHeight(frame) / 2 - 4)];
    _redDotView.hidden = YES;
    [self addSubview:_redDotView];
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
    if (self.tapWalletItemHandler) {
        self.tapWalletItemHandler();
    }
}

#pragma mark - getters and/or setters

- (void)setName:(NSString *)name {
    _name = name;
    self.nameLabel.font = [UIFont room107FontThree];
    self.nameLabel.textColor = [self fontColor];
    self.nameLabel.text = name;
    [self setNeedsLayout];
}

- (void)setIconCode:(NSString *)iconCode {
    _iconCode = iconCode;
    [self.iconLabel setText:[CommonFuncs iconCodeByHexStr:iconCode]];
    [self.iconLabel setTextColor:self.fontColor];
    [self setNeedsLayout];
}

- (void)setAmount:(double)amount {
    _amount = amount;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSString *amountString = [formatter stringFromNumber:[NSNumber numberWithDouble:amount]];
    amountString = [amountString stringByReplacingOccurrencesOfString:@" " withString:@""];
    amountString = [amountString stringByAppendingString:@" >"];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:amountString
                                                                                attributes:@{NSForegroundColorAttributeName: [self fontColor]}];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont room107FontOne] range:NSMakeRange(0, 1)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont room107FontThree] range:NSMakeRange(1, [attrStr length] - 1)];
    
    self.amountLabel.attributedText = attrStr;
    [self setNeedsLayout];
}

- (void)setFontColor:(UIColor *)fontColor {
    _fontColor = fontColor;
    self.nameLabel.textColor = fontColor;
    self.iconLabel.textColor = fontColor;
    NSMutableAttributedString *attrStr = [self.amountLabel.attributedText mutableCopy];
    [attrStr addAttribute:NSForegroundColorAttributeName value:fontColor range:NSMakeRange(0, [attrStr length])];
    self.amountLabel.attributedText = attrStr;
}

- (void)setNewUpdate:(BOOL)newUpdate {
    _newUpdate = newUpdate;
    self.redDotView.hidden = !newUpdate;
}

#pragma mark - initialization

- (instancetype)init {
    if (self = [super init]) {
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

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

@end
