//
//  PriceOneTableViewCell.m
//  room107
//
//  Created by ningxia on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "PriceOneTableViewCell.h"
#import "SearchTipLabel.h"
#import "NSString+AttributedString.h"

@interface PriceOneTableViewCell ()

@property (nonatomic, strong) SearchTipLabel *priceTitleLabel;
@property (nonatomic, strong) SearchTipLabel *priceLabel;
@property (nonatomic, strong) SearchTipLabel *reasonTitleLabel;
@property (nonatomic, strong) SearchTipLabel *reasonLabel;
@property (nonatomic, strong) SearchTipLabel *timeLabel;

@end

@implementation PriceOneTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 22.0f;
        CGFloat originY = 0;
        
        CGFloat containerViewWidth = CGRectGetWidth([self cellFrame]) - 2 * originX;
        CGFloat containerViewHeight = CGRectGetHeight([self cellFrame]) - 10;
        UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, containerViewWidth, containerViewHeight}];
        containerView.layer.cornerRadius = [CommonFuncs cornerRadius];
        containerView.layer.masksToBounds = YES;
        [containerView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:containerView];
        
        originX = 15;
        originY = 10;
        CGFloat labelWidth = (containerViewWidth - 2 * originX) / 2;
        CGFloat labelHeight = 30;
        _priceTitleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_priceTitleLabel setFont:[UIFont room107SystemFontTwo]];
        [containerView addSubview:_priceTitleLabel];
        
        _reasonTitleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX + labelWidth, originY, labelWidth, labelHeight}];
        [_reasonTitleLabel setTextAlignment:NSTextAlignmentRight];
        [_reasonTitleLabel setFont:[UIFont room107SystemFontTwo]];
        [containerView addSubview:_reasonTitleLabel];
        
        originY += CGRectGetHeight(_priceTitleLabel.bounds) + 5;
        _priceLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY - 15, containerViewWidth - 2 * originX, 2.5 * labelHeight}];
        [_priceLabel setTextColor:[UIColor room107GrayColorD]];
        [containerView addSubview:_priceLabel];
        
        originX += CGRectGetWidth(_priceTitleLabel.bounds);
        _reasonLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){containerViewWidth - 15 -  labelWidth, originY, labelWidth, 2 * labelHeight}];
        [_reasonLabel setTextAlignment:NSTextAlignmentRight];
        [_reasonLabel setTextColor:[UIColor room107GrayColorD]];
        [_reasonLabel setFont:[UIFont room107SystemFontFour]];
        [containerView addSubview:_reasonLabel];

        originY += CGRectGetHeight(_reasonLabel.bounds);
        _timeLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_timeLabel setFont:[UIFont room107SystemFontTwo]];
        [_timeLabel setTextAlignment:NSTextAlignmentRight];
        [containerView addSubview:_timeLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, priceOneTableViewCellHeight);
}

- (void)setCard:(NSDictionary *)card {
    [_priceTitleLabel setText:card[@"values"][0]];
    NSMutableAttributedString *attrValue = [NSString attributedStringFromPriceStr:[@"￥" stringByAppendingString:card[@"values"][1] ? card[@"values"][1] : @""] andPriceFont:[UIFont room107SystemFontSeven] andPriceColor:_priceLabel.textColor andUnitFont:[UIFont room107FontThree] andUnitColor:_priceLabel.textColor];
    [_priceLabel setAttributedText:attrValue];
    [_reasonTitleLabel setText:card[@"values"][2]];
    [_reasonLabel setText:card[@"values"][3]];
    [_timeLabel setText:card[@"values"][4]];
    
    if (card[@"values"][1] && [card[@"values"][1] length] < 3) {
        CGRect frame = _reasonLabel.frame;
        frame.size.width = 1.5 * _priceTitleLabel.frame.size.width;
        CGFloat originX = 22.0f;
        frame.origin.x = CGRectGetWidth([self cellFrame]) - 2 * originX - 15 - frame.size.width;
        [_reasonLabel setFrame:frame];
    }
}

@end
