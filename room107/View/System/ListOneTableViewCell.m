//
//  ListOneTableViewCell.m
//  room107
//
//  Created by ningxia on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ListOneTableViewCell.h"
#import "SearchTipLabel.h"

static CGFloat titlelabelHeight = 21.7;

@interface ListOneTableViewCell ()

@property (nonatomic, strong) UIView *containerView;

@end

@implementation ListOneTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 22.0f;
        CGFloat originY = 0;
        
        CGFloat containerViewWidth = CGRectGetWidth([self cellFrame]) - 2 * originX;
        CGFloat containerViewHeight = CGRectGetHeight([self cellFrame]) - 10;
        _containerView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, containerViewWidth, containerViewHeight}];
        _containerView.layer.cornerRadius = [CommonFuncs cornerRadius];
        _containerView.layer.masksToBounds = YES;
        [_containerView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_containerView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 100);
}

- (CGFloat)heightByCard:(NSDictionary *)card {
    CGFloat originX = 22;
    CGFloat titleLabelWidth = 100;
    CGFloat contentLabelWidth = _containerView.frame.size.width - 2 * originX - titleLabelWidth;
    CGFloat contentHeight = 0;
    if (card && card[@"values"]) {
        for (int i = 0 ; i < [(NSArray *)card[@"values"] count] / 2; i++) {
            contentHeight += [CommonFuncs rectWithText:[card[@"values"] count] > (i * 2 + 1) ? card[@"values"][i * 2 + 1] : @"" andMaxDisplayWidth:contentLabelWidth andAttributes:[self getAttributes]].size.height + 8;
        }
    }
    
    return contentHeight + 16;
}

- (void)setCard:(NSDictionary *)card {
    for (UIView *subView in [_containerView subviews]) {
        [subView removeFromSuperview];
    }
    CGFloat height = [self heightByCard:card];
    [_containerView setFrame:(CGRect){_containerView.frame.origin, _containerView.frame.size.width, height - 10}];
    
    CGFloat originX = 22;
    CGFloat originY = 8;
    CGFloat titleLabelWidth = 100;
    CGFloat contentLabelWidth = _containerView.frame.size.width - 2 * originX - titleLabelWidth;
    
    if (card && card[@"values"]) {
        for (NSUInteger i = 0; i < [(NSArray *)card[@"values"] count] / 2; i++) {
            CGRect contentRect = [CommonFuncs rectWithText:[card[@"values"] count] > (i * 2 + 1) ? card[@"values"][i * 2 + 1] : @"" andMaxDisplayWidth:contentLabelWidth andAttributes:[self getAttributes]];
            SearchTipLabel *titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, titleLabelWidth, titlelabelHeight}];
            [titleLabel setFont:[UIFont room107SystemFontTwo]];
            [titleLabel setAttributedText:[self attributesStringWithText:card[@"values"][i * 2]]];
            [_containerView addSubview:titleLabel];
            
            SearchTipLabel *contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX + titleLabelWidth, originY, contentLabelWidth, contentRect.size.height}];
            [contentLabel setFont:[UIFont room107SystemFontTwo]];
            [contentLabel setTextColor:[UIColor room107GrayColorD]];
            [contentLabel setAttributedText:[self attributesStringWithText:[card[@"values"] count] > (i * 2 + 1) ? card[@"values"][i * 2 + 1] : @""]];
            [_containerView addSubview:contentLabel];
            
            originY = CGRectGetMaxY(contentLabel.frame) + 8;
        }
    }
}

- (NSDictionary *)getAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont room107SystemFontTwo],NSParagraphStyleAttributeName:paragraphStyle};
    return attributes;
}

- (NSAttributedString *)attributesStringWithText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text ? text : @"" attributes:[self getAttributes]];
}

@end
