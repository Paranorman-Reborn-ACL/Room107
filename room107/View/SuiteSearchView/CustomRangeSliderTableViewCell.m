//
//  CustomRangeSliderTableViewCell.m
//  room107
//
//  Created by ningxia on 15/12/22.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "CustomRangeSliderTableViewCell.h"
#import "NXRangeSlider.h"
#import "CustomLabel.h"
#import "NSString+AttributedString.h"

static CGFloat unitFontSize = 10.0f;
static CGFloat priceFontSize = 20.0f;

@interface CustomRangeSliderTableViewCell () <NXRangeSliderDelegate>

@property (nonatomic, strong) NXRangeSlider *rangeSlider;
@property (nonatomic, strong) CustomLabel *leftValueLabel;
@property (nonatomic, strong) CustomLabel *rightValueLabel;

@end

@implementation CustomRangeSliderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, customRangeSliderTableViewCellHeight);
}

- (void)setMinValue:(CGFloat)minValue andMaxValue:(CGFloat)maxValue withOffsetY:(CGFloat)offsetY {
    if (!_rangeSlider) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5 + offsetY;
        CGFloat labelWidth = 100;
        CGFloat labelHeight = 30;
        _leftValueLabel = [[CustomLabel alloc] initWithFrame:(CGRect){[self originLeftX], originY, labelWidth, labelHeight}];
        [_leftValueLabel setTextAlignment:NSTextAlignmentLeft];
        [_leftValueLabel setTextColor:[UIColor room107GreenColor]];
        [self.contentView addSubview:_leftValueLabel];
        
        _rightValueLabel = [[CustomLabel alloc] initWithFrame:(CGRect){CGRectGetWidth([self cellFrame]) - [self originLeftX] - labelWidth, originY, labelWidth, labelHeight}];
        [_rightValueLabel setTextColor:[UIColor room107GreenColor]];
        [self.contentView addSubview:_rightValueLabel];
        
        originY += CGRectGetHeight(_leftValueLabel.bounds);
        CGFloat sliderHeight = 40;
        _rangeSlider = [[NXRangeSlider alloc] initWithFrame:CGRectMake([self originLeftX], originY + 5, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], sliderHeight)];
        _rangeSlider.rangeSliderDelegate = self;
        _rangeSlider.backgroundColor = [UIColor room107GrayColorB];
        _rangeSlider.minValue = minValue;
        _rangeSlider.maxValue = maxValue;
        _rangeSlider.minValueRange = 100;
        _rangeSlider.shadowRadius = 3.0f;
        [self.contentView addSubview:_rangeSlider];
    }
}

- (void)setLeftValue:(CGFloat)leftValue andRightValue:(CGFloat)rightValue {
    _rangeSlider.leftValue = leftValue;
    _rangeSlider.rightValue = rightValue;
    [_rangeSlider layoutSubviews];
}

- (int)leftValue {
    int value = _rangeSlider.leftValue / _rangeSlider.minValueRange;
    return value *= _rangeSlider.minValueRange;
}

- (int)rightValue {
    int value = _rangeSlider.rightValue / _rangeSlider.minValueRange;
    return value *= _rangeSlider.minValueRange;
}

#pragma mark - NXRangeSliderDelegate
- (void)leftValueDidChange:(NXRangeSlider *)slider {
    if ([slider isEqual:_rangeSlider]) {
        int value = _rangeSlider.leftValue / _rangeSlider.minValueRange;
        value *= _rangeSlider.minValueRange;
        NSMutableAttributedString *attributedString = [NSString attributedStringFromPriceStr:[NSString stringWithFormat:@"%@%.f", @"￥", (CGFloat)value] andPriceFont:[UIFont systemFontOfSize:priceFontSize] andPriceColor:_leftValueLabel.textColor andUnitFont:[UIFont systemFontOfSize:unitFontSize] andUnitColor:_leftValueLabel.textColor];
        [_leftValueLabel setAttributedText:attributedString];
    }
}

- (void)rightValueDidChange:(NXRangeSlider *)slider {
    if ([slider isEqual:_rangeSlider]) {
        int value = _rangeSlider.rightValue / _rangeSlider.minValueRange;
        value *= _rangeSlider.minValueRange;
        NSString *priceStr = [NSString stringWithFormat:@"%@%.f", @"￥", (CGFloat)value];
        if (value >= _rangeSlider.maxValue) {
            priceStr = [NSString stringWithFormat:@"%@%.f+", @"￥", _rangeSlider.maxValue];
        }
        NSMutableAttributedString *attributedString = [NSString attributedStringFromPriceStr:priceStr andPriceFont:[UIFont systemFontOfSize:priceFontSize] andPriceColor:_rightValueLabel.textColor andUnitFont:[UIFont systemFontOfSize:unitFontSize] andUnitColor:_rightValueLabel.textColor];
        [_rightValueLabel setAttributedText:attributedString];
    }
}

@end
