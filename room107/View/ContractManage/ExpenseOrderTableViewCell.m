//
//  ExpenseOrderTableViewCell.m
//  room107
//
//  Created by ningxia on 15/9/14.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ExpenseOrderTableViewCell.h"
#import "SearchTipLabel.h"

static CGFloat labelHeight = 12;

@interface ExpenseOrderTableViewCell ()

@property (nonatomic, strong) SearchTipLabel *nameLabel;
@property (nonatomic, strong) SearchTipLabel *contentLabel;

@end

@implementation ExpenseOrderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        CGFloat originX = [self originLeftX] + 11;
        CGFloat contentWidth = 100;
        CGFloat labelWidth = CGRectGetWidth([self cellFrame]) - 2 * originX - contentWidth;
        _nameLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0, labelWidth, labelHeight}];
        [_nameLabel setFont:[UIFont room107SystemFontOne]];
        [self addSubview:_nameLabel];
        
        CGFloat originY = 5.5;
        _contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){CGRectGetWidth([self cellFrame]) - [self originLeftX] - contentWidth, originY, contentWidth, labelHeight}];
        [_contentLabel setFont:[UIFont room107SystemFontOne]];
        [_contentLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_contentLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, labelHeight);
}

- (void)setNameLabelWidth:(CGFloat)width {
    [_nameLabel setFrame:(CGRect){_nameLabel.frame.origin, width, _nameLabel.frame.size.height}];
    CGFloat originX = _nameLabel.frame.origin.x + width;
    [_contentLabel setFrame:(CGRect){originX, 0, CGRectGetWidth([self cellFrame]) - originX, labelHeight}];
}

- (void)setName:(NSString *)name {
    _nameLabel.attributedText = [[NSAttributedString alloc] initWithString:name ? name : @"" attributes:[self attributes]];
    CGFloat contentHeight = [self getCellHeightWithName:name];
    [_nameLabel setFrame:(CGRect){_nameLabel.frame.origin, _nameLabel.frame.size.width, contentHeight}];
}

- (void)setAttributedName:(NSMutableAttributedString *)name {
    [_nameLabel setAttributedText:name];
}

- (void)setContentX:(CGFloat)originX {
    [_contentLabel setFrame:(CGRect){originX, 0, CGRectGetWidth([self cellFrame]) - originX, labelHeight}];
}

- (void)setContent:(NSString *)content {
    [_contentLabel setText:content];
}

- (void)setAttributedContent:(NSMutableAttributedString *)content {
    [_contentLabel setAttributedText:content];
}

- (NSDictionary *)attributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    NSDictionary *attributes = @{NSFontAttributeName:_nameLabel.font,
                                 NSParagraphStyleAttributeName:paragraphStyle};
//    NSDictionary *attributes = @{NSFontAttributeName:_nameLabel.font};
    
    return attributes;
}

- (CGFloat)getCellHeightWithName:(NSString *)name {
    float maxMessageDisplayWidth = _nameLabel.frame.size.width;
    CGRect contentRect = [name boundingRectWithSize:(CGSize){maxMessageDisplayWidth, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:[self attributes] context:nil];
    
    return contentRect.size.height + 11;
}

@end
