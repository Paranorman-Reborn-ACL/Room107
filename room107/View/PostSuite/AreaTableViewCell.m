//
//  AreaTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "AreaTableViewCell.h"
#import "SearchTipLabel.h"
#import "NXSingleValueSlider.h"

@interface AreaTableViewCell () <NXSingleValueSliderDelegate>

@property (nonatomic, strong) NXSingleValueSlider *areaSlider;
@property (nonatomic, strong) SearchTipLabel *areaLabel;
@property (nonatomic, assign) CGFloat areaSize;

@end

@implementation AreaTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        _areaLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){[self originLeftX], originY, 50, 30}];
        [_areaLabel setTextColor:[UIColor room107GreenColor]];
        _areaLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_areaLabel];
        
        originY += CGRectGetHeight(_areaLabel.bounds);
        _areaSlider = [[NXSingleValueSlider alloc] initWithFrame:CGRectMake([self originLeftX], originY + 5, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], 33)];
        _areaSlider.delegate = self;
        _areaSlider.backgroundColor = [UIColor room107GrayColorB];
        _areaSlider.minValue = 0;
        _areaSlider.maxValue = 200;
        _areaSlider.value = 0;
        _areaSlider.shadowRadius = 3.0f;
        [self addSubview:_areaSlider];
    }
    
    return self;
}

- (void)setminValue:(CGFloat)minValue andMaxValue:(CGFloat)maxValue {
    _areaSlider.minValue = minValue;
    _areaSlider.maxValue = maxValue;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, areaTableViewCellHeight);
}

- (void)setArea:(NSNumber *)area {
    CGFloat value = [area floatValue];
    if (value > _areaSlider.maxValue) {
        value = _areaSlider.maxValue;
    }
    if (value < _areaSlider.minValue) {
        value = _areaSlider.minValue;
    }
    [_areaSlider setValue:value];
    self.areaSize = [area floatValue];
    //面积大于max 显示实际面积 面积小于min（0）显示area ＝ 0；
    if (self.areaSize > _areaSlider.maxValue ) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.f", self.areaSize]];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontFive] range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GreenColor] range:NSMakeRange(0, attributedString.length)];
        [_areaLabel setAttributedText:attributedString];
    }
    //始终显示实际面积（负数值情况）
//    if (self.areaSize > _areaSlider.maxValue || self.areaSize < _areaSlider.minValue) {
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.f", self.areaSize]];
//        [attributedString addAttribute:NSFontAttributeName value:[UIFont room107FontFive] range:NSMakeRange(0, attributedString.length)];
//        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GreenColor] range:NSMakeRange(0, attributedString.length)];
//        [_areaLabel setAttributedText:attributedString];
//    }
}

- (NSNumber *)area {
    //保证显示真实数值
    return [NSNumber numberWithInt:[_areaLabel.text intValue]];
}

//1.设置滑块数值  2.slider layoutSubviews方法回调此代理  3.滑动滑块时候调用
#pragma mark - NXSingleValueSliderDelegate
- (void)valueDidChange:(NXSingleValueSlider *)slider {
    if (self.areaSize > _areaSlider.maxValue || self.areaSize < _areaSlider.minValue) {
        self.areaSize = _areaSlider.maxValue;
        return;
    }    
    if ([slider isEqual:_areaSlider]) {
        int value = _areaSlider.value;
        if (_areaSlider.value > _areaSlider.maxValue) {
            value = _areaSlider.maxValue;
        }
        if (_areaSlider.value < _areaSlider.minValue) {
            value = _areaSlider.minValue;
        }
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.f", (CGFloat)value]];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontFive] range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GreenColor] range:NSMakeRange(0, attributedString.length)];
        [_areaLabel setAttributedText:attributedString];
        
        CGFloat sliderCenter = [_areaSlider sliderCenter];
        if (sliderCenter > _areaSlider.frame.size.width - _areaLabel.frame.size.width/2) {
            sliderCenter = _areaSlider.frame.size.width - _areaLabel.frame.size.width/2;
        }
        if (sliderCenter < [_areaSlider sliderWidth]/2) {
            sliderCenter = [_areaSlider sliderWidth]/2;
        }
        [_areaLabel setFrame:(CGRect){_areaSlider.bounds.origin.x + sliderCenter, _areaSlider.frame.origin.y - attributedString.size.height - 5, attributedString.size.width + 20,attributedString.size.height}];
        [_areaLabel setCenter:CGPointMake(sliderCenter + CGRectGetHeight(_areaSlider.bounds) / 2 + 3, _areaLabel.center.y)];
    
    }
}

@end
