//
//  PaymentTypeTableViewCell.m
//  room107
//
//  Created by ningxia on 16/3/24.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "PaymentTypeTableViewCell.h"
#import "CustomImageView.h"
#import "SearchTipLabel.h"

@interface PaymentTypeTableViewCell ()

@property (nonatomic, strong) CustomImageView *paymentTypeImageView;
@property (nonatomic, strong) SearchTipLabel *paymentTypeTitleLabel;
@property (nonatomic, strong) CustomImageView *selectedImageView;

@end

@implementation PaymentTypeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
        CGFloat originX = 15;
        CGFloat originY = 11;
        CGFloat imageViewWidth = 36;
        CGFloat imageViewHeight = 22;
        _paymentTypeImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, originY, imageViewWidth, imageViewHeight}];
        [_paymentTypeImageView setContentMode:UIViewContentModeCenter];
        [self.contentView addSubview:_paymentTypeImageView];
        
        _paymentTypeTitleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){2 * originX + imageViewWidth, 0, 100, paymentTypeTableViewCellHeight}];
        [_paymentTypeTitleLabel setFont:[UIFont room107SystemFontTwo]];
        [_paymentTypeTitleLabel setTextColor:[UIColor room107GrayColorD]];
        [self.contentView addSubview:_paymentTypeTitleLabel];
        
        _selectedImageView = [[CustomImageView alloc] initWithFrame:(CGRect){CGRectGetWidth([self cellFrame]) - imageViewHeight - 22, originY, imageViewHeight, imageViewHeight}];
        [self.contentView addSubview:_selectedImageView];
        
        UIView *seperateView = [[UIView alloc] initWithFrame:(CGRect){0, CGRectGetHeight([self cellFrame]) - 0.5, CGRectGetWidth([self cellFrame]), 0.5}];
        [seperateView setBackgroundColor:[UIColor room107GrayColorA]];
        [self.contentView addSubview:seperateView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, paymentTypeTableViewCellHeight);
}

- (void)setPaymentTypeImageName:(NSString *)imageName {
    [_paymentTypeImageView setImageWithName:imageName];
}

- (void)setPaymentTypeTitle:(NSString *)title {
    [_paymentTypeTitleLabel setText:title];
}

- (void)setPaymentTypeSeleted:(BOOL)selected {
    [_selectedImageView setImageWithName:selected ? @"selected.png": @"unselected.png"];
}

@end
