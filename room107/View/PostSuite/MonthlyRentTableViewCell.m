//
//  MonthlyRentTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/19.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "MonthlyRentTableViewCell.h"
#import "NXIconTextField.h"
#import "NSNumber+Additions.h"

@interface MonthlyRentTableViewCell ()<UITextFieldDelegate>

@end

@implementation MonthlyRentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        CGFloat textFieldHeight = 60.0f;
        _priceTextField = [[NXIconTextField alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], textFieldHeight}];
        [_priceTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [_priceTextField setIconString:@"\ue62e"];
        [_priceTextField setPlaceholder:lang(@"MonthlyRentTips")];
        [self addSubview:_priceTextField];
        [_priceTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, monthlyRentTableViewCellHeight);
}

- (void)setPrice:(NSNumber *)price {
    [_priceTextField setText:[price stringValue]];
}

- (NSNumber *)price {
    return [NSNumber numberFromUSNumberString:_priceTextField.text];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == _priceTextField) {
        if (textField.text.length > maxPriceDigit) {
            textField.text = [textField.text substringToIndex:maxPriceDigit];
        }
    }
}

@end
