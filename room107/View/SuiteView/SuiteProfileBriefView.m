//
//  SuiteProfileBriefView.m
//  room107
//
//  Created by ningxia on 15/12/1.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "SuiteProfileBriefView.h"
#import "CustomLabel.h"
#import "NSString+AttributedString.h"
#import "Room107VisualEffectView.h"
#import "Room107GradientLayer.h"

static CGFloat minSuiteInfoViewHeight = 130;
static CGFloat originX = 11;
static CGFloat cityLabelMinY = 15;
static CGFloat cityFontMinSize = 22.0f; //4号字
static CGFloat positionLabelMinY = 46;
static CGFloat positionFontMinSize = 14.0f; //2号字
static CGFloat offlinePriceTipsLabelMinY = 100;
static CGFloat offlinePriceTipsFontMinSize = 14.0f;
static CGFloat offlinePriceLabelMinY = 100;
static CGFloat offlinePriceUnitFontMinSize = 12.0f; //1号字
static CGFloat offlinePriceFontMinSize = 16.0f; //3号字
static CGFloat priceTipsLabelMinY = 100;
static CGFloat priceTipsFontMinSize = 14.0f;
static CGFloat priceUnitFontMinSize = 14.0f; //2号字
static CGFloat priceLabelMinY = 89;
static CGFloat priceFontMinSize = 26.0f; //5号字

@interface SuiteProfileBriefView ()

@property (nonatomic, strong) CustomLabel *cityLabel;
@property (nonatomic, strong) CustomLabel *positionLabel;
@property (nonatomic, strong) CustomLabel *offlinePriceTipsLabel;
@property (nonatomic, strong) CustomLabel *offlinePriceLabel;
@property (nonatomic, strong) CustomLabel *priceTipsLabel;
@property (nonatomic, strong) CustomLabel *priceLabel;

@end

@implementation SuiteProfileBriefView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];
    if (self) {
        UIView *suiteInfoView = [[UIView alloc] initWithFrame:(CGRect){originX, CGRectGetHeight(self.bounds) - minSuiteInfoViewHeight, self.bounds.size.width - 2 * originX, minSuiteInfoViewHeight}];
        [suiteInfoView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:suiteInfoView];
        
        frame.size.width = CGRectGetWidth(suiteInfoView.bounds);
        frame.size.height = minSuiteInfoViewHeight;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            Room107VisualEffectView *containerView = [[Room107VisualEffectView alloc] initWithFrame:frame];
            
            [suiteInfoView addSubview:containerView];
        } else {
            UIView *containerView = [[UIView alloc] initWithFrame:frame];
            Room107GradientLayer *gradientLayer = [[Room107GradientLayer alloc] initWithFrame:frame andStartAlpha:0.3f andEndAlpha:0.3f];
            [containerView.layer insertSublayer:gradientLayer atIndex:0];
            
            [suiteInfoView addSubview:containerView];
        }
        
        
        if (!_cityLabel) {
            _cityLabel = [[CustomLabel alloc] init];
            [suiteInfoView addSubview:_cityLabel];
        }
        
        if (!_positionLabel) {
            _positionLabel = [[CustomLabel alloc] init];
            [_positionLabel setNumberOfLines:0];
            [suiteInfoView addSubview:_positionLabel];
        }
        
        if (!_offlinePriceTipsLabel) {
            _offlinePriceTipsLabel = [[CustomLabel alloc] init];
            [_offlinePriceTipsLabel setText:lang(@"OriginalPrice")];
            [suiteInfoView addSubview:_offlinePriceTipsLabel];
            CGRect contentRect = [self boundingRectWithFontSize:priceTipsFontMinSize forContent:_offlinePriceTipsLabel.text];
            [_offlinePriceTipsLabel setFontSize:offlinePriceTipsFontMinSize];
            [_offlinePriceTipsLabel setFrame:(CGRect){0, offlinePriceTipsLabelMinY, contentRect.size}];
        }
        
        if (!_offlinePriceLabel) {
            _offlinePriceLabel = [[CustomLabel alloc] init];
            [suiteInfoView addSubview:_offlinePriceLabel];
        }
        
        if (!_priceTipsLabel) {
            _priceTipsLabel = [[CustomLabel alloc] init];
            [_priceTipsLabel setText:lang(@"BeSignedOnline")];
            [suiteInfoView addSubview:_priceTipsLabel];
            CGRect contentRect = [self boundingRectWithFontSize:priceTipsFontMinSize forContent:_priceTipsLabel.text];
            [_priceTipsLabel setFontSize:priceTipsFontMinSize];
            [_priceTipsLabel setFrame:(CGRect){0, priceTipsLabelMinY, contentRect.size}];
            _priceTipsLabel.hidden = YES;
        }
        
        if (!_priceLabel) {
            _priceLabel = [[CustomLabel alloc] init];
            [suiteInfoView addSubview:_priceLabel];
        }
    }
    
    return self;
}

- (void)setHouseInfo:(NSString *)houseInfo {
    CGRect contentRect = [self boundingRectWithFontSize:cityFontMinSize forContent:houseInfo];
    [_cityLabel setFontSize:cityFontMinSize];
    [_cityLabel setFrame:(CGRect){originX, cityLabelMinY, contentRect.size}];
    [_cityLabel setText:houseInfo];
}

- (void)setPosition:(NSString *)position {
    CGRect contentRect = [self boundingRectWithFontSize:positionFontMinSize forContent:position];
    contentRect.size.width = MIN(contentRect.size.width, CGRectGetWidth(self.bounds) - 4 * originX);
    contentRect.size.height *= 2;
    [_positionLabel setFrame:(CGRect){originX, positionLabelMinY, contentRect.size}];
    [_positionLabel setFontSize:positionFontMinSize];
    [_positionLabel setTextAlignment:NSTextAlignmentLeft];
    [_positionLabel setText:position];
}

- (void)setOfflinePrice:(NSNumber *)offlinePrice onlinePrice:(NSNumber *)onlinePrice {
    _offlinePriceTipsLabel.hidden = NO;
    _offlinePriceLabel.hidden = NO;
    _priceTipsLabel.hidden = NO;
    
    if (!onlinePrice || [onlinePrice isEqual:@0]) {
        _offlinePriceTipsLabel.hidden = YES;
        _offlinePriceLabel.hidden = YES;
        _priceTipsLabel.hidden = YES;
        
        [self setPrice:offlinePrice];
    } else {
        [self setPrice:onlinePrice];
        
        if (!offlinePrice || [offlinePrice isEqual:@0]) {
            _offlinePriceTipsLabel.hidden = YES;
            _offlinePriceLabel.hidden = YES;
        } else {
            NSMutableAttributedString *attributedString = [NSString attributedStringFromPriceStr:[NSString stringWithFormat:@"￥%@", offlinePrice] andPriceFont:[UIFont systemFontOfSize:offlinePriceFontMinSize] andPriceColor:_offlinePriceLabel.textColor andUnitFont:[UIFont systemFontOfSize:offlinePriceUnitFontMinSize] andUnitColor:_offlinePriceLabel.textColor];
            [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, attributedString.length)];
            [_offlinePriceLabel setFrame:(CGRect){_priceTipsLabel.frame.origin.x + _priceTipsLabel.frame.size.width + 11, offlinePriceLabelMinY, attributedString.size}];
            [_offlinePriceLabel setAttributedText:attributedString];
            
            CGRect offlinePriceTipsLabelFrame = _offlinePriceTipsLabel.frame;
            offlinePriceTipsLabelFrame.origin.x = _offlinePriceLabel.frame.origin.x + attributedString.size.width;
            [_offlinePriceTipsLabel setFrame:offlinePriceTipsLabelFrame];
        }
    }
}

- (void)setPrice:(NSNumber *)price {
    if (!price || [price isEqual:@0]) {
        _priceLabel.hidden = YES;
        return;
    }
    
    NSMutableAttributedString *attributedString = [NSString attributedStringFromPriceStr:[NSString stringWithFormat:@"￥%@", price] andPriceFont:[UIFont systemFontOfSize:priceFontMinSize] andPriceColor:_priceLabel.textColor andUnitFont:[UIFont systemFontOfSize:priceUnitFontMinSize] andUnitColor:_priceLabel.textColor];
    [_priceLabel setFrame:(CGRect){originX, priceLabelMinY, attributedString.size}];
    [_priceLabel setAttributedText:attributedString];
    
    CGRect priceTipsLabelFrame = _priceTipsLabel.frame;
    priceTipsLabelFrame.origin.x = _priceLabel.frame.origin.x + attributedString.size.width;
    [_priceTipsLabel setFrame:priceTipsLabelFrame];
}

- (CGRect)boundingRectWithFontSize:(CGFloat)fontSize forContent:(NSString *)content {
    CGRect contentRect = [content boundingRectWithSize:(CGSize){CGRectGetWidth(self.bounds) - 4 * originX, 2 * (fontSize + 5)} options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    
    return contentRect;
}

@end
