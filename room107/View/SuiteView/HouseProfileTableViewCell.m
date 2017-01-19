//
//  HouseProfileTableViewCell.m
//  room107
//
//  Created by ningxia on 15/12/28.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "HouseProfileTableViewCell.h"
#import "CustomImageView.h"
#import "CustomLabel.h"
#import "NSString+AttributedString.h"
#import "SystemAgent.h"

static CGFloat originX = 11;
static CGFloat cityLabelMinY = 22;
static CGFloat cityFontMinSize = 22.0f; //4号字
static CGFloat positionLabelMinY = 50;
static CGFloat positionFontMinSize = 14.0f; //2号字
static CGFloat offlinePriceTipsLabelMinY = 100;
static CGFloat offlinePriceTipsFontMinSize = 14.0f;
static CGFloat offlinePriceLabelMinY = 100;
static CGFloat offlinePriceUnitFontMinSize = 12.0f; //1号字
static CGFloat offlinePriceFontMinSize = 16.0f; //3号字
static CGFloat priceTipsLabelMinY = 100;
static CGFloat priceTipsFontMinSize = 14.0f;
static CGFloat priceUnitFontMinSize = 14.0f; //2号字
static CGFloat priceLabelMinY = 90;
static CGFloat priceFontMinSize = 26.0f; //5号字
static CGFloat houseNumberLabelY = 146;
static CGFloat houseNumberFontSize = 12.0f;
static CGFloat submitTimeFontSize = 12.0f;

@interface HouseProfileTableViewCell ()

@property (nonatomic, strong) CustomImageView *avatarImageView;
@property (nonatomic, strong) CustomLabel *cityLabel;
@property (nonatomic, strong) CustomLabel *positionLabel;
@property (nonatomic, strong) CustomLabel *offlinePriceTipsLabel;
@property (nonatomic, strong) CustomLabel *offlinePriceLabel;
@property (nonatomic, strong) CustomLabel *priceTipsLabel;
@property (nonatomic, strong) CustomLabel *priceLabel;
@property (nonatomic, strong) CustomLabel *houseNumberLabel;
@property (nonatomic, strong) CustomLabel *submitTimeLabel;

@end

@implementation HouseProfileTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
        CGFloat avatarImageViewWidth = 66;
        _avatarImageView = [[CustomImageView alloc] initWithFrame:(CGRect){CGRectGetWidth([self cellFrame]) - originX - avatarImageViewWidth, -avatarImageViewWidth / 2, avatarImageViewWidth, avatarImageViewWidth}];
        [_avatarImageView setBackgroundColor:[UIColor whiteColor]];
        [_avatarImageView setCornerRadius:avatarImageViewWidth / 2];
        _avatarImageView.layer.borderWidth = 2.0f;
        _avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:_avatarImageView];
        
        if (!_cityLabel) {
            _cityLabel = [[CustomLabel alloc] init];
            [_cityLabel setTextColor:[UIColor room107GrayColorD]];
            [self.contentView addSubview:_cityLabel];
        }
        
        if (!_positionLabel) {
            _positionLabel = [[CustomLabel alloc] initWithFrame:(CGRect){originX, positionLabelMinY, CGRectGetWidth([self cellFrame]) - 2 * originX, positionFontMinSize * 2.5}];
            [_positionLabel setTextColor:[UIColor room107GrayColorC]];
            [_positionLabel setNumberOfLines:0];
            [self.contentView addSubview:_positionLabel];
        }
        
        if (!_offlinePriceTipsLabel) {
            _offlinePriceTipsLabel = [[CustomLabel alloc] init];
            [_offlinePriceTipsLabel setTextColor:[UIColor room107GrayColorC]];
            [_offlinePriceTipsLabel setText:lang(@"OriginalPrice")];
            [self.contentView addSubview:_offlinePriceTipsLabel];
            CGRect contentRect = [self boundingRectWithFontSize:priceTipsFontMinSize forContent:_offlinePriceTipsLabel.text];
            [_offlinePriceTipsLabel setFontSize:offlinePriceTipsFontMinSize];
            [_offlinePriceTipsLabel setFrame:(CGRect){0, offlinePriceTipsLabelMinY, contentRect.size}];
            _offlinePriceTipsLabel.hidden = YES;
        }
        
        if (!_offlinePriceLabel) {
            _offlinePriceLabel = [[CustomLabel alloc] init];
            [_offlinePriceLabel setTextColor:[UIColor room107GrayColorC]];
            [self.contentView addSubview:_offlinePriceLabel];
            _offlinePriceLabel.hidden = YES;
        }
        
        if (!_priceTipsLabel) {
            _priceTipsLabel = [[CustomLabel alloc] init];
            [_priceTipsLabel setTextColor:[UIColor room107GrayColorD]];
            [_priceTipsLabel setText:lang(@"BeSignedOnline")];
            [self.contentView addSubview:_priceTipsLabel];
            CGRect contentRect = [self boundingRectWithFontSize:priceTipsFontMinSize forContent:_priceTipsLabel.text];
            [_priceTipsLabel setFontSize:priceTipsFontMinSize];
            [_priceTipsLabel setFrame:(CGRect){0, priceTipsLabelMinY, contentRect.size}];
            _priceTipsLabel.hidden = YES;
        }
        
        if (!_priceLabel) {
            _priceLabel = [[CustomLabel alloc] init];
            [_priceLabel setTextColor:[UIColor room107GrayColorD]];
            [self.contentView addSubview:_priceLabel];
        }
        
        CustomLabel *housePriceTipsLabel = [[CustomLabel alloc] initWithFrame:(CGRect){originX, 127, CGRectGetWidth([self cellFrame]) - originX, submitTimeFontSize + 2}];
        [housePriceTipsLabel setTextColor:[UIColor room107GrayColorC]];
        [housePriceTipsLabel setFontSize:submitTimeFontSize];
        AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@21];
        if (!appText) {
            [housePriceTipsLabel setText:lang(@"HousePriceTips")];
            [[SystemAgent sharedInstance] getTextPropertiesFromServer];
        } else {
            [housePriceTipsLabel setText:appText.text];
        }
        [housePriceTipsLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:housePriceTipsLabel];
        
        if (!_houseNumberLabel) {
            _houseNumberLabel = [[CustomLabel alloc] init];
            [_houseNumberLabel setTextColor:[UIColor room107GrayColorC]];
            [_houseNumberLabel setFontSize:submitTimeFontSize];
            [self.contentView addSubview:_houseNumberLabel];
        }
        
        if (!_submitTimeLabel) {
            _submitTimeLabel = [[CustomLabel alloc] init];
            [_submitTimeLabel setTextColor:[UIColor room107GrayColorC]];
            [_submitTimeLabel setFontSize:submitTimeFontSize];
            [self.contentView addSubview:_submitTimeLabel];
        }
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 100);
}

- (void)setAvatarImageViewWithURL:(NSString *)url {
    if (!url || [url isEqualToString:@""]) {
        [_avatarImageView setImageWithName:@"loginlogo.png"];
    } else {
        [_avatarImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"loginlogo.png"]];
    }
}

- (void)setCity:(NSString *)city andName:(NSString *)name andRequiredGender:(NSString *)gender {
    if (city && name) {
        NSString *houseInfo = [NSString stringWithFormat:@"%@  %@", city, name];
        if (gender && ![gender isEqualToString:@""]) {
            //分租
            houseInfo = [houseInfo stringByAppendingFormat:@"  %@", gender];
        }
        CGRect contentRect = [self boundingRectWithFontSize:cityFontMinSize forContent:houseInfo];
        [_cityLabel setFontSize:cityFontMinSize];
        [_cityLabel setFrame:(CGRect){originX, cityLabelMinY, contentRect.size}];
        [_cityLabel setText:houseInfo];
    }
}

- (void)setPosition:(NSString *)position {
//    CGRect contentRect = [CommonFuncs rectWithText:position andMaxDisplayWidth:CGRectGetWidth([self cellFrame]) - 2 * originX andAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:positionFontMinSize]}];
//    contentRect.size.height = MIN(contentRect.size.height, positionFontMinSize * 2.5);
//    [_positionLabel setFrame:(CGRect){originX, positionLabelMinY, contentRect.size}];
    [_positionLabel setFontSize:positionFontMinSize];
    [_positionLabel setTextAlignment:NSTextAlignmentLeft];
    [_positionLabel setText:position];
}

- (void)setOfflinePrice:(NSNumber *)offlinePrice onlinePrice:(NSNumber *)onlinePrice {
    _offlinePriceTipsLabel.hidden = YES;
    _offlinePriceLabel.hidden = YES;
    _priceTipsLabel.hidden = YES;
    _priceLabel.hidden = NO;
    
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
    if (!price) {
        _priceLabel.hidden = YES;
        return;
    }
    
    NSMutableAttributedString *attributedString = [NSString attributedStringFromPriceStr:[NSString stringWithFormat:@"￥%@", price] andPriceFont:[UIFont systemFontOfSize:priceFontMinSize] andPriceColor:_priceLabel.textColor andUnitFont:[UIFont systemFontOfSize:priceUnitFontMinSize] andUnitColor:_priceLabel.textColor];
    [_priceLabel setFrame:(CGRect){originX, priceLabelMinY, attributedString.size}];
    [_priceLabel setAttributedText:attributedString];
    
//    CGRect priceTipsLabelFrame = _priceTipsLabel.frame;
//    priceTipsLabelFrame.origin.x = _priceLabel.frame.origin.x + attributedString.size.width;
//    [_priceTipsLabel setFrame:priceTipsLabelFrame];
}

- (void)setHouseNumber:(NSString *)number {
    _houseNumberLabel.hidden = NO;
    if (number && ![number isEqual:@0]) {
        [_houseNumberLabel setText:[NSString stringWithFormat:@"%@：%@", lang(@"HouseNumber"), number]];
        CGRect contentRect = [self boundingRectWithFontSize:houseNumberFontSize forContent:_houseNumberLabel.text];
        [_houseNumberLabel setFrame:(CGRect){originX, houseNumberLabelY, contentRect.size}];
    } else {
        _houseNumberLabel.hidden = YES;
    }
}

- (void)setSubmitTime:(NSString *)time {
    _submitTimeLabel.hidden = NO;
    if (time && ![time isEqualToString:@""]) {
        [_submitTimeLabel setText:[NSString stringWithFormat:@"%@：%@", [lang(@"SubmitTime") substringToIndex:2], time]];
        CGRect contentRect = [self boundingRectWithFontSize:submitTimeFontSize forContent:_submitTimeLabel.text];
        [_submitTimeLabel setFrame:(CGRect){_houseNumberLabel.frame.origin.x + _houseNumberLabel.frame.size.width + 22, houseNumberLabelY, contentRect.size}];
    } else {
        _submitTimeLabel.hidden = YES;
    }
}

- (CGRect)boundingRectWithFontSize:(CGFloat)fontSize forContent:(NSString *)content {
    CGRect contentRect = [content boundingRectWithSize:(CGSize){[[UIScreen mainScreen] bounds].size.width - 2 * originX, 2 * (fontSize + 5)} options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    
    return contentRect;
}

- (CGFloat)getCellHeightWithPosition:(NSString *)position {
    return 0;
}

@end
