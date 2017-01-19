//
//  ExpenseOrderLargeItemTableViewCell.m
//  room107
//
//  Created by ningxia on 15/9/14.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ExpenseOrderLargeItemTableViewCell.h"
#import "SearchTipLabel.h"

@interface ExpenseOrderLargeItemTableViewCell ()

@property (nonatomic, strong) SearchTipLabel *nameLabel;
@property (nonatomic, strong) SearchTipLabel *contentLabel;

@end

@implementation ExpenseOrderLargeItemTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = [self originLeftX];
        CGFloat labelWidth = 70;
        _nameLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0, labelWidth, expenseOrderLargeItemTableViewCellHeight}];
        [self addSubview:_nameLabel];
        
        originX += CGRectGetWidth(_nameLabel.bounds) + 10;
        _contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0, CGRectGetWidth([self cellFrame]) - originX, expenseOrderLargeItemTableViewCellHeight}];
        [_contentLabel setFont:[UIFont room107FontFour]];
        [_contentLabel setTextColor:[UIColor room107GrayColorD]];
        [self addSubview:_contentLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, expenseOrderLargeItemTableViewCellHeight);
}

- (void)setNameLabelWidth:(CGFloat)width {
    [_nameLabel setFrame:(CGRect){_nameLabel.frame.origin, width, _nameLabel.frame.size.height}];
    CGFloat originX = _nameLabel.frame.origin.x + width;
    [_contentLabel setFrame:(CGRect){originX, 0, CGRectGetWidth([self cellFrame]) - originX, expenseOrderLargeItemTableViewCellHeight}];
}

- (void)setName:(NSString *)name {
    [_nameLabel setText:name];
}

- (void)setAttributedName:(NSMutableAttributedString *)name {
    [_nameLabel setAttributedText:name];
}

- (void)setContentX:(CGFloat)originX {
    [_contentLabel setFrame:(CGRect){originX, 0, CGRectGetWidth([self cellFrame]) - originX, expenseOrderLargeItemTableViewCellHeight}];
}

- (void)setContent:(NSString *)content {
    [_contentLabel setText:content];
}

- (void)setAttributedContent:(NSMutableAttributedString *)content {
    [_contentLabel setAttributedText:content];
}

@end
