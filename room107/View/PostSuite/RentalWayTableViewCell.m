//
//  RentalWayTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/19.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RentalWayTableViewCell.h"
#import "CustomSwitch.h"
#import "SearchTipLabel.h"
#import "NXIconTextField.h"
#import "NSNumber+Additions.h"

@interface RentalWayTableViewCell () <DVSwitchDelegate>

@property (nonatomic, strong) CustomSwitch *rentTypeSwitch;
@property (nonatomic, strong) SearchTipLabel *tipsLabel;
@property (nonatomic, strong) CustomSwitch *requiredGenderSwitch;
@property (nonatomic, strong) void (^selectRentTypeHandlerBlock)(NSInteger type);

@end

@implementation RentalWayTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        CGFloat switchHeight = 40;
        _rentTypeSwitch = [[CustomSwitch alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], switchHeight} stringsArray:@[lang(@"RentHouse"), lang(@"Subletting")]];
        _rentTypeSwitch.delegate = self;
        [self addSubview:_rentTypeSwitch];
        
        originY += CGRectGetHeight(_rentTypeSwitch.bounds) + [self originBottomY];
        _tipsLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){[self originLeftX], originY, 240, [self titleHeight]}];
        [_tipsLabel setFont:[UIFont room107FontTwo]];
        [self addSubview:_tipsLabel];
        
        originY += CGRectGetHeight(_tipsLabel.bounds) + 5;
        CGFloat textFieldHeight = 50.0f;
        _priceTextField = [[NXIconTextField alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], textFieldHeight}];
        [_priceTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [_priceTextField setIconString:@"￥"];
        [_priceTextField setPlaceholder:lang(@"MonthlyRentTips")];
        [self addSubview:_priceTextField];
        [_priceTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        _requiredGenderSwitch = [[CustomSwitch alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], switchHeight} stringsArray:@[lang(@"NoLimitGender"), lang(@"FemaleLimit"), lang(@"MaleLimit")]];
        [self addSubview:_requiredGenderSwitch];
        
        [self selectedIndexChanged:_rentTypeSwitch];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, rentalWayTableViewCellHeight);
}

- (void)setSelectRentTypeHandler:(void (^)(NSInteger))handler {
    _selectRentTypeHandlerBlock = handler;
}

- (void)setRentType:(NSInteger)rentType {
    [_rentTypeSwitch selectIndex:rentType == 1 ? 1 : 0 animated:NO];
    
    [_tipsLabel setText:rentType == 1 ? lang(@"RequiredGender") : lang(@"MonthlyRent")];
    _priceTextField.hidden = rentType == 1;
    _requiredGenderSwitch.hidden = !(rentType == 1);
}

- (void)setPrice:(NSNumber *)price {
    if (![price isEqual:[NSNull null]]){
        //老用户可能保存的草稿 并没有offlinePrice字段 导致crash 。
        [_priceTextField setText:[price stringValue]];
    }
}

- (NSInteger)rentType {
    return _rentTypeSwitch.selectedIndex + 1;
}

- (NSNumber *)price {
    return [NSNumber numberFromUSNumberString:_priceTextField.text];
}

- (void)setRequiredGender:(NSInteger)requiredGender {
    switch (requiredGender) {
        case 1:
            [_requiredGenderSwitch setSelectedIndex:2];
            break;
        case 2:
            [_requiredGenderSwitch setSelectedIndex:1];
            break;
        default:
            [_requiredGenderSwitch setSelectedIndex:0];
            break;
    }
}

- (NSInteger)requiredGender {
    switch (_requiredGenderSwitch.selectedIndex) {
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
        default:
            return 3;
            break;
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == _priceTextField) {
        if (textField.text.length > maxPriceDigit) {
            textField.text = [textField.text substringToIndex:maxPriceDigit];
        }
    }
}

#pragma mark - DVSwitchDelegate
- (void)selectedIndexChanged:(DVSwitch *)DVSwitch {
    if ([DVSwitch isEqual:_rentTypeSwitch]) {
        [_tipsLabel setText:DVSwitch.selectedIndex == 0 ? lang(@"MonthlyRent") : lang(@"RequiredGender")];
        _priceTextField.hidden = !(DVSwitch.selectedIndex == 0);
        _requiredGenderSwitch.hidden = DVSwitch.selectedIndex == 0;
        
        if (self.selectRentTypeHandlerBlock) {
            self.selectRentTypeHandlerBlock(DVSwitch.selectedIndex);
        }
        BOOL isShow = DVSwitch.selectedIndex == 0 ? YES : NO;
        if (self.showOrNotDiscount) {
            self.showOrNotDiscount(isShow);
        }
    }
}

@end
