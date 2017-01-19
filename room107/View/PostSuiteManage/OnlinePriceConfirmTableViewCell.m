//
//  OnlinePriceConfirmTableViewCell.m
//  room107
//
//  Created by ningxia on 15/12/4.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "OnlinePriceConfirmTableViewCell.h"
#import "SearchTipLabel.h"
#import "NXIconTextField.h"
#import "NXSingleValueSlider.h"
#import "NSString+AttributedString.h"
#import "NSNumber+Additions.h"
#import "RegularExpressionUtil.h"

@interface OnlinePriceConfirmTableViewCell () <NXSingleValueSliderDelegate, UITextFieldDelegate>

@property (nonatomic, strong) SearchTipLabel *houseInfoLabel;
@property (nonatomic, strong) SearchTipLabel *positionLabel;
@property (nonatomic, strong) NXIconTextField *offlinePriceTextField;
@property (nonatomic, strong) SearchTipLabel *discountLabel; //折扣
@property (nonatomic, strong) NXSingleValueSlider *discountSlider;
@property (nonatomic, strong) SearchTipLabel *onlinePriceLabel; //线上签约价格
@property (nonatomic, strong) NSMutableDictionary *priceIncompleteUnit;

@end

@implementation OnlinePriceConfirmTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 11.0f;
        CGFloat originY = 11.0f;
        CGFloat cornerRadius = [CommonFuncs cornerRadius];
        CGFloat containerViewWidth = CGRectGetWidth([self cellFrame]) - 2 * originX;
        CGFloat containerViewHeight = CGRectGetHeight([self cellFrame]) - originY;
        UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, containerViewWidth, containerViewHeight}];
        containerView.layer.cornerRadius = cornerRadius;
        containerView.layer.masksToBounds = YES;
        [containerView setBackgroundColor:[UIColor room107GrayColorB]];
        [self addSubview:containerView];
        
        CGFloat viewWidth = containerViewWidth - 2 * originX;
        originY = 15;
        _houseInfoLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, viewWidth, 20}];
        [_houseInfoLabel setTextColor:[UIColor room107GrayColorD]];
        [_houseInfoLabel setTextAlignment:NSTextAlignmentCenter];
        [containerView addSubview:_houseInfoLabel];
        
        originY += CGRectGetHeight(_houseInfoLabel.bounds) + 5;
        _positionLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, viewWidth, 30}];
        [_positionLabel setFont:[UIFont room107SystemFontTwo]];
        [_positionLabel setTextColor:[UIColor room107GrayColorD]];
        [_positionLabel setTextAlignment:NSTextAlignmentCenter];
        [containerView addSubview:_positionLabel];
        
        originY += CGRectGetHeight(_houseInfoLabel.bounds) + 15;
        CGFloat titleHeight = 25;
        SearchTipLabel *offlinePriceTitleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, viewWidth, titleHeight}];
        [offlinePriceTitleLabel setFont:[UIFont room107FontTwo]];
        [offlinePriceTitleLabel setText:lang(@"MonthlyRent")];
        [containerView addSubview:offlinePriceTitleLabel];
        
        originY += CGRectGetHeight(offlinePriceTitleLabel.bounds) + 5;
        CGFloat textFieldHeight = 60.0f;
        _offlinePriceTextField = [[NXIconTextField alloc] initWithFrame:(CGRect){originX, originY, viewWidth, textFieldHeight}];
        _offlinePriceTextField.delegate = self;
        [_offlinePriceTextField setBackgroundColor:[UIColor room107GrayColorA]];
        [_offlinePriceTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [_offlinePriceTextField setIconString:@"\ue62e"];
        [_offlinePriceTextField setPlaceholder:lang(@"MonthlyRentTips")];
        [containerView addSubview:_offlinePriceTextField];
        [_offlinePriceTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        originY += CGRectGetHeight(_offlinePriceTextField.bounds) + 30;
        SearchTipLabel *onlineDiscountTitleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, viewWidth, titleHeight}];
        [onlineDiscountTitleLabel setFont:[UIFont room107FontTwo]];
        [onlineDiscountTitleLabel setText:lang(@"OnlineDiscount")];
        [containerView addSubview:onlineDiscountTitleLabel];
        
        originY += CGRectGetHeight(onlineDiscountTitleLabel.bounds) + 5;
        _discountLabel = [[SearchTipLabel alloc] initWithFrame:CGRectMake(originX, originY, 52, 30)];
        [containerView addSubview:_discountLabel];
        
        originY += CGRectGetHeight(_discountLabel.bounds);
        _discountSlider = [[NXSingleValueSlider alloc] initWithFrame:CGRectMake(originX, originY, viewWidth, 33)];
        _discountSlider.delegate = self;
        _discountSlider.backgroundColor = [UIColor room107GrayColorA];
        _discountSlider.minValue = 1;
        _discountSlider.maxValue = 95;
        _discountSlider.value = 95;
        _discountSlider.shadowRadius = 3.0f;
        [containerView addSubview:_discountSlider];
        
        originY += CGRectGetHeight(_discountSlider.bounds) + 30;
        SearchTipLabel *discountPriceTitleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, viewWidth, titleHeight}];
        [discountPriceTitleLabel setFont:[UIFont room107SystemFontTwo]];
        [discountPriceTitleLabel setText:lang(@"OnlineDiscountMoney")];
        [containerView addSubview:discountPriceTitleLabel];
        
        originY += CGRectGetHeight(discountPriceTitleLabel.bounds);
        _onlinePriceLabel = [[SearchTipLabel alloc] initWithFrame:CGRectMake(originX, originY, viewWidth, 40)];
        [containerView addSubview:_onlinePriceLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, onlinePriceConfirmTableViewCellHeight);
}

- (void)setPriceIncompleteUnit:(NSMutableDictionary *)priceIncompleteUnit {
    _priceIncompleteUnit = priceIncompleteUnit;
    [self setHouseInfo:[priceIncompleteUnit[@"city"] stringByAppendingFormat:@" %@", priceIncompleteUnit[@"name"]]];
    [self setPosition:priceIncompleteUnit[@"position"]];
    [self setOfflinePrice:priceIncompleteUnit[@"offlinePrice"] onlinePrice:priceIncompleteUnit[@"onlinePrice"]];
}

- (void)setHouseInfo:(NSString *)houseInfo {
    [_houseInfoLabel setText:houseInfo];
}

- (void)setPosition:(NSString *)position {
    [_positionLabel setText:position];
}

- (void)setOfflinePrice:(NSNumber *)offlinePrice onlinePrice:(NSNumber *)onlinePrice {
    if (offlinePrice) {
        _discountSlider.value = [onlinePrice floatValue] * 100 / [offlinePrice floatValue];
        [_offlinePriceTextField setText:[offlinePrice stringValue]];
        int result = _discountSlider.value * [offlinePrice floatValue] / 100;
        [self setOnlinePriceString:[NSString stringWithFormat:@"%d", result]];
    } else {
        _discountSlider.value = 95;
        [_offlinePriceTextField setText:@""];
    }
    [self setOnlinePriceString:[onlinePrice stringValue]];
}

//设置签约价格Label
- (void)setOnlinePriceString:(NSString *)priceFromString {
    if (priceFromString) {
        [_priceIncompleteUnit setObject:[NSNumber numberFromUSNumberString:priceFromString] forKey:@"onlinePrice"];
        
        NSString *onlineString = [NSString stringWithFormat:@"￥%@", priceFromString];
        NSMutableAttributedString *attOnlineString = [NSString attributedStringFromPriceStr:onlineString andPriceFont:[UIFont room107SystemFontFive] andPriceColor:[UIColor room107GreenColor] andUnitFont:[UIFont room107SystemFontTwo] andUnitColor:[UIColor room107GreenColor]];
        [_onlinePriceLabel setAttributedText:attOnlineString];
        [_onlinePriceLabel setTextAlignment:NSTextAlignmentCenter];
    } else {
        _discountSlider.value = 95;
    }
}

- (NSNumber *)offlinePrice {
    return [NSNumber numberFromUSNumberString:_offlinePriceTextField.text];
}

- (NSNumber *)onlinePrice {
    NSString *priceText = [_onlinePriceLabel.text substringFromIndex:1];
    return [NSNumber numberFromUSNumberString:priceText];
}

#pragma mark - NXSingleValueSliderDelegate
- (void)valueDidChange:(NXSingleValueSlider *)slider {
    if ([slider isEqual:_discountSlider]) {
        int value = _discountSlider.value;
        
        if (_discountSlider.value > _discountSlider.maxValue) {
            value = _discountSlider.maxValue;
        }
        if (_discountSlider.value < _discountSlider.minValue) {
            value = _discountSlider.minValue;
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.f%%", (CGFloat)value]];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontFive] range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GreenColor] range:NSMakeRange(0, attributedString.length)];
        [_discountLabel setAttributedText:attributedString];
        
        CGFloat sliderCenter = [_discountSlider sliderCenter];
        if (sliderCenter > _discountSlider.frame.size.width - _discountLabel.frame.size.width/2) {
            sliderCenter = _discountSlider.frame.size.width - _discountLabel.frame.size.width/2;
        }
        if (sliderCenter < [_discountSlider sliderWidth]/2) {
            sliderCenter = [_discountSlider sliderWidth]/2;
        }
        [_discountLabel setFrame:(CGRect){_discountSlider.bounds.origin.x + sliderCenter, _discountSlider.frame.origin.y - attributedString.size.height - 5, attributedString.size}];
        [_discountLabel setCenter:CGPointMake(sliderCenter + 10, _discountLabel.center.y)];
        
        if (_offlinePriceTextField.text.length > 0) {
            int result = value * [[self offlinePrice] floatValue] / 100;
            [self setOnlinePriceString:[NSString stringWithFormat:@"%d", result]];
        }
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == _offlinePriceTextField) {
        if (textField.text.length > maxPriceDigit) {
            textField.text = [textField.text substringToIndex:maxPriceDigit];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _offlinePriceTextField) {
        if (string.length > 0 && ![RegularExpressionUtil validNumber:string]) {
            //校验纯数字，兼容退格键
            return NO;
        }
        
        NSString *offlinePriceString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [_priceIncompleteUnit setObject:[NSNumber numberFromUSNumberString:offlinePriceString] forKey:@"offlinePrice"];
        
        if ([offlinePriceString isEqualToString:@""]) {
            [self setOnlinePriceString:@""];
        } else {
            int result = _discountSlider.value * [offlinePriceString floatValue] / 100;
            [self setOnlinePriceString:[NSString stringWithFormat:@"%d", result]];
        }
    }
    
    return YES;
}

@end
