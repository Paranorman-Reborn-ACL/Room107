//
//  OnlineDiscountTableViewCell.m
//  room107
//
//  Created by 107间 on 15/12/2.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "OnlineDiscountTableViewCell.h"
#import "SearchTipLabel.h"
#import "NXSingleValueSlider.h"
#import "CustomLabel.h"
#import "SearchTipLabel.h"
#import "NSString+AttributedString.h"
#import "CustomButton.h"
#import "NSString+IsPureNumer.h"
#import "NSNumber+Additions.h"

@interface OnlineDiscountTableViewCell()<NXSingleValueSliderDelegate>

@property (nonatomic, strong) SearchTipLabel *discountText;
@property (nonatomic, strong) SearchTipLabel *discountLabel; //折扣
@property (nonatomic, strong) NXSingleValueSlider *discountSlider;
@property (nonatomic, strong) SearchTipLabel *onlineDiscountMoney;
@property (nonatomic, strong) CustomLabel *discountPriceLabel; //线上签约价格
@property (nonatomic, strong) CustomButton *whatsOnlineContractBtn;
//@property (nonatomic, strong) NSString *priceStr;
@property (nonatomic, assign) NSInteger discount;
@property (nonatomic, copy) NSString *onlineprice;
@property (nonatomic, assign) BOOL slider;
@end

@implementation OnlineDiscountTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat buttonWidth = 100.f;
        self.whatsOnlineContractBtn = [[CustomButton alloc] initWithFrame:CGRectMake(CGRectGetWidth([self cellFrame]) - [self originLeftX] - buttonWidth, [self originTopY], buttonWidth, [self titleHeight])];
        [_whatsOnlineContractBtn setTitle:lang(@"What's OnlineContract") forState:UIControlStateNormal];
        [_whatsOnlineContractBtn.titleLabel setFont:[UIFont room107SystemFontTwo]];
        [_whatsOnlineContractBtn setTintColor:[UIColor room107GreenColor]];
        [_whatsOnlineContractBtn addTarget:self action:@selector(whatsOnlineContract) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_whatsOnlineContractBtn];
        
        
        CGFloat originY = [self originTopY] + [self titleHeight] + 2 ;
        self.discountText = [[SearchTipLabel alloc] initWithFrame:CGRectMake([self originLeftX], originY, CGRectGetWidth([self cellFrame]) - [self originLeftX] * 2 , [self titleHeight] * 1.5) ];
        [_discountText setFont:[UIFont room107SystemFontTwo]];
        [_discountText setNumberOfLines:0];
        [_discountText setText:lang(@"OnlineDiscountText")];
        [self.contentView addSubview:_discountText];
        
        self.discountLabel = [[SearchTipLabel alloc] initWithFrame:CGRectMake([self originLeftX], CGRectGetMaxY(_discountText.frame) + 15, 120, 30)];
        _discountLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_discountLabel];
        
        self.discountSlider = [[NXSingleValueSlider alloc] initWithFrame:CGRectMake([self originLeftX], CGRectGetMaxY(_discountLabel.frame) + 5, CGRectGetWidth([self cellFrame]) - [self originLeftX] * 2, 33)];
        _discountSlider.delegate = self;
        _discountSlider.backgroundColor = [UIColor room107GrayColorB];
        _discountSlider.minValue = 1;
        _discountSlider.maxValue = 95;
        _discountSlider.value = 95;
        _discountSlider.shadowRadius = 3.0f;
        [self.contentView addSubview:_discountSlider];
        
        self.onlineDiscountMoney = [[SearchTipLabel alloc]initWithFrame:CGRectMake([self originLeftX], CGRectGetMaxY(_discountSlider.frame) + 50, CGRectGetWidth([self cellFrame]) - [self originLeftX] * 2, [self titleHeight])];
        [_onlineDiscountMoney setFont:[UIFont room107SystemFontTwo]];
        [_onlineDiscountMoney setText:lang(@"OnlineDiscountMoney")];
        [self.contentView addSubview:_onlineDiscountMoney];
        
        self.discountPriceLabel = [[CustomLabel alloc] initWithFrame:CGRectMake([self originLeftX], CGRectGetMaxY(_onlineDiscountMoney.frame) + 20, CGRectGetWidth([self cellFrame]) - [self originLeftX] * 2, 50)];
        [self.contentView  addSubview:_discountPriceLabel];
        [self setOnlinePriceLabel:@""];
    }
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, onlineDiscountTableViewCellHeight);
}

#pragma mark - NXSingleValueSliderDelegate
- (void)valueDidChange:(NXSingleValueSlider *)slider {
    //初始化self 依次调用该delegate方法 1.赋初始值  2.赋实际值  3.NXSingleValueSlider的layoutSubviews方法调用 (此时判断滑块越界特殊情况)
    if ([_onlineprice floatValue] > [_offlinePrice floatValue]) {
        //3.NXSingleValueSlider的layoutSubviews方法调用 此时_onlineprice和_offlinePrice有值
        if (!_slider) {
            _slider = YES;
            return;
        }
    }
    int value = _discountSlider.value ;
    if ([slider isEqual:_discountSlider]) {
        if (value > _discountSlider.maxValue ) {
            value = _discountSlider.maxValue;
        }
        if (value < _discountSlider.minValue ) {
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
        [_discountLabel setFrame:(CGRect){_discountSlider.bounds.origin.x + sliderCenter, _discountSlider.frame.origin.y - attributedString.size.height - 5, attributedString.size.width +20,attributedString.size.height}];
        [_discountLabel setCenter:CGPointMake(sliderCenter + CGRectGetHeight(_discountSlider.bounds)/2 + 3, _discountLabel.center.y)];
        
        if (self.offlinePrice && ![self.offlinePrice isEqualToString:@""]) {
            //每月租金存在 即有签约价格
            float offlineprice = [_offlinePrice floatValue];
            int result = value * offlineprice /100;
            [self setOnlinePriceLabel:[NSString stringWithFormat:@"%d",result]];
        }
    }
}

//- (void)setOnlineDiscountPrice:(NSMutableString *)onlinePrice andFromText:(BOOL)isFromText {
//    if (![onlinePrice isEqualToString:@"----"]) {
//        if (isFromText) {
//            self.priceStr = onlinePrice;
//        }
//        int price = [_priceStr floatValue] * _discountSlider.value/100;
//        onlinePrice = [NSMutableString stringWithFormat:@"%d",price];
//    }
//    NSString *onlineString = [NSString stringWithFormat:@"￥%@",onlinePrice];
//    NSMutableAttributedString *attOnlineString = [NSString attributedStringFromPriceStr:onlineString andPriceFont:[UIFont room107SystemFontFive] andPriceColor:[UIColor room107GreenColor] andUnitFont:[UIFont room107SystemFontTwo] andUnitColor:[UIColor room107GreenColor]];
//    [_discountPriceLabel setAttributedText:attOnlineString];
//    [_discountPriceLabel setTextAlignment:NSTextAlignmentCenter];
//}

//设置签约价格Label
- (void)setOnlinePriceLabel:(NSString *)priceFromString {
    NSString *onlineString = [NSString stringWithFormat:@"￥%@",priceFromString];
    NSMutableAttributedString *attOnlineString = [NSString attributedStringFromPriceStr:onlineString andPriceFont:[UIFont room107SystemFontFive] andPriceColor:[UIColor room107GreenColor] andUnitFont:[UIFont room107SystemFontTwo] andUnitColor:[UIColor room107GreenColor]];
    [_discountPriceLabel setAttributedText:attOnlineString];
    [_discountPriceLabel setTextAlignment:NSTextAlignmentCenter];
}

//设置每月租金
- (void)setOfflinePrice:(NSString *)offlinePrice {
    //1.设置每月租金
    if (![offlinePrice isEqual:[NSString stringWithFormat:@"%@",[NSNull null]]]) {
        _offlinePrice = offlinePrice;
        //2.通过每月租金以及折扣计算签约价格
        if ([NSString isPureInt:offlinePrice] || [NSString isPureFloat:offlinePrice] ) {
            //输入金额为数字 , 计算签约价格result (offlinePrice/rate)取整    floor();
            int value = _discountSlider.value;
            float offlineprice = [offlinePrice floatValue];
            int result = value * offlineprice /100;
            [self setOnlinePriceLabel:[NSString stringWithFormat:@"%d",result]];
        } else {
            [self setOnlinePriceLabel:@""];
        }
    } else {
        [self setOnlinePriceLabel:@""];
    }
}

- (NSNumber *)onlinePrice {
    NSString *priceText = [_discountPriceLabel.text substringFromIndex:1];
    return  [NSNumber numberFromUSNumberString:priceText];
}

- (NSNumber *)rate {
    return [NSNumber numberWithInteger:(NSInteger)_discountSlider.value];
}

- (void)setRate:(NSNumber *)sender {
    if (![sender isEqual:[NSNull null]]) {
//        [_discountSlider setValueFrom:[sender floatValue]];
        if (_discountSlider.maxValue < [sender floatValue]) {
            //若折扣大于95 则滑块保持在最右 数值显示错误数值
            _discountSlider.value = _discountSlider.maxValue;
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.f%%", (CGFloat)[sender floatValue]]];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontFive] range:NSMakeRange(0, attributedString.length)];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GreenColor] range:NSMakeRange(0, attributedString.length)];
            [_discountLabel setAttributedText:attributedString];
        } else if (_discountSlider.minValue > [sender floatValue]) {
            //若折扣为负数 滑块保持最左端 数值显示1%
            _discountSlider.value = _discountSlider.minValue;
        } else {
            _discountSlider.value = [sender floatValue];
        }
    }
    if (nil ==  sender) {
        _discountSlider.value = _discountSlider.maxValue;
    }
}

- (void)whatsOnlineContract {
    if (_whatsOnlineContractClickComplete) {
        _whatsOnlineContractClickComplete();
    }
}

- (void)setOfflinePrice:(NSString *)offlinePrice onlinePrice:(NSString *)onlinePrice {
    //1.设置每月租金
    if (![offlinePrice isEqual:[NSString stringWithFormat:@"%@",[NSNull null]]]) {
        self.offlinePrice = offlinePrice;
        self.onlineprice = onlinePrice;
        if ( [offlinePrice floatValue] < [onlinePrice floatValue]) {
            [self setOnlinePriceLabel:onlinePrice]; return;
        }
        //2.通过每月租金以及折扣计算签约价格
        if ([NSString isPureInt:offlinePrice] || [NSString isPureFloat:offlinePrice] ) {
//            //输入金额为数字 , 计算签约价格result (offlinePrice/rate)取整    floor();
//            int value = _discountSlider.value;
//            float offlineprice = [offlinePrice floatValue];
//            int result = value * offlineprice /100;
//            [self setOnlinePriceLabel:[NSString stringWithFormat:@"%d",result]];
            [self setOnlinePriceLabel:[NSString stringWithFormat:@"%@",onlinePrice]];
        } else {
            [self setOnlinePriceLabel:@""];
        }
    } else {
        [self setOnlinePriceLabel:@""];
    }

}

//-(void)setOnlineDiscountPrice:(NSMutableString *)onlinePrice andOfflinePrice:( NSString *)offlinePrice {
//    self.priceStr = onlinePrice;
//    NSString *onlineString = [NSString stringWithFormat:@"￥%@",onlinePrice];
//    NSMutableAttributedString *attOnlineString = [NSString attributedStringFromPriceStr:onlineString andPriceFont:[UIFont room107SystemFontFive] andPriceColor:[UIColor room107GreenColor] andUnitFont:[UIFont room107SystemFontTwo] andUnitColor:[UIColor room107GreenColor]];
//    [_discountPriceLabel setAttributedText:attOnlineString];
//    [_discountPriceLabel setTextAlignment:NSTextAlignmentCenter];
//
//}

@end
