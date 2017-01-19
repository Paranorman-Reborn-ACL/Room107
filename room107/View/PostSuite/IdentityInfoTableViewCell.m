//
//  IdentityInfoTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "IdentityInfoTableViewCell.h"
#import "CustomTextField.h"

@interface IdentityInfoTableViewCell ()


@end

@implementation IdentityInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        CGFloat textFieldHeight = (CGRectGetHeight([self cellFrame]) - originY) / 2;
        _fullNameTextField = [[CustomTextField alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], textFieldHeight}];
        [_fullNameTextField setLeftViewWidth:[self originLeftX]];
        [_fullNameTextField setPlaceholder:lang(@"FullName")];
        [self addSubview:_fullNameTextField];
        
        originY += CGRectGetHeight(_fullNameTextField.bounds);
        _IDNumberTextField = [[CustomTextField alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], textFieldHeight}];
        [_IDNumberTextField setLeftViewWidth:[self originLeftX]];
        [_IDNumberTextField setPlaceholder:lang(@"IDNumber")];
        [self addSubview:_IDNumberTextField];
        
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){[self originLeftX], 0, CGRectGetWidth(_fullNameTextField.bounds) - 2 * [self originLeftX], 0.5}];
        [lineView setBackgroundColor:[UIColor room107GrayColorC]];
        [_IDNumberTextField addSubview:lineView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, identityInfoTableViewCellHeight);
}

- (void)setName:(NSString *)name {
    [_fullNameTextField setText:name];
    if (name && name.length > 0) {
        _fullNameTextField.userInteractionEnabled = NO;
    }
}

- (void)setIDCard:(NSString *)idCard {
    [_IDNumberTextField setText:idCard];
    if (idCard && idCard.length > 0) {
        _IDNumberTextField.userInteractionEnabled = NO;
    }
}

- (NSString *)name {
    return _fullNameTextField.text;
}

- (NSString *)idCard {
    return _IDNumberTextField.text;
}

@end
