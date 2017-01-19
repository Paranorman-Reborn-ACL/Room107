//
//  FullAddressTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "FullAddressTableViewCell.h"
#import <CoreText/CoreText.h>
#import "SearchTipLabel.h"
#import "CustomTextField.h"

@interface FullAddressTableViewCell () <UITextFieldDelegate>

@property (nonatomic, strong) SearchTipLabel *countOfSubscriberLabel;
@property (nonatomic, strong) void (^handlerBlock)(NSString *text);
@property (nonatomic, strong) void (^addressShouldBeginEditingHandlerBlock)();

@end

@implementation FullAddressTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        _fullAddressTextField = [[CustomTextField alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], 60}];
        [_fullAddressTextField setPlaceholder:lang(@"InputRegion")];
        _fullAddressTextField.delegate = self;
        [_fullAddressTextField setLeftViewWidth:22];
        [self addSubview:_fullAddressTextField];
        
        originY += CGRectGetHeight(_fullAddressTextField.bounds) + 10;
        _countOfSubscriberLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth([self cellFrame]), CGRectGetHeight([self cellFrame]) - [self originBottomY] - originY}];
        [_countOfSubscriberLabel setNumberOfLines:0];
        [_countOfSubscriberLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_countOfSubscriberLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, fullAddressTableViewCellHeight);
}

- (void)setTextFieldDidEndEditingHandler:(void (^)(NSString *text))handler {
    self.handlerBlock = handler;
    [self setCountOfSubscriber:@"0"];
}

- (void)setCountOfSubscriber:(NSString *)count {
    NSString *countOfSubscriber = [count ? count : @"0" stringByAppendingString:lang(@"CountOfSubscriber")];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:countOfSubscriber];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontFive] range:NSMakeRange(0, countOfSubscriber.length - lang(@"CountOfSubscriber").length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107YellowColor] range:NSMakeRange(0, countOfSubscriber.length - lang(@"CountOfSubscriber").length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontThree] range:NSMakeRange(countOfSubscriber.length - lang(@"CountOfSubscriber").length, lang(@"CountOfSubscriber").length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GrayColorD] range:NSMakeRange(countOfSubscriber.length - lang(@"CountOfSubscriber").length, lang(@"CountOfSubscriber").length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    [_countOfSubscriberLabel setAttributedText:attributedString];
}

- (void)setPosition:(NSString *)position {
    [_fullAddressTextField setText:position];
}

- (NSString *)position {
    return _fullAddressTextField.text;
}

- (void)setAddressPlaceholder:(NSString *)placeholder {
    [_fullAddressTextField setPlaceholder:placeholder];
}

- (void)setAddressShouldBeginEditingHandler:(void(^)())handler {
    _addressShouldBeginEditingHandlerBlock = handler;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.handlerBlock) {
        self.handlerBlock(textField.text);
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.cellBlock) {
        self.cellBlock();
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_addressShouldBeginEditingHandlerBlock) {
        _addressShouldBeginEditingHandlerBlock();
    }
    
    return YES;
}

@end
