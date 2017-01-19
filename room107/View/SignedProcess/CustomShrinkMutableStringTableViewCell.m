//
//  CustomShrinkMutableStringTableViewCell.m
//  room107
//
//  Created by ningxia on 15/10/15.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "CustomShrinkMutableStringTableViewCell.h"
#import "SearchTipLabel.h"
#import "NSString+AttributedString.h"

@interface CustomShrinkMutableStringTableViewCell ()

@property (nonatomic, strong) SearchTipLabel *subtitleLabel;
@property (nonatomic, strong) SearchTipLabel *contentLabel;
@property (nonatomic, strong) void (^shrinkHandlerBlock)(BOOL hidden);
@property (nonatomic) BOOL shrinkHidden;

@end

@implementation CustomShrinkMutableStringTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = 0.0f;
        _subtitleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, 0, 100, 20}];
        [self addSubview:_subtitleLabel];
        UITapGestureRecognizer *tapGestureRecgnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subtitleLabelDidClick)];
        _subtitleLabel.userInteractionEnabled = YES;
        [_subtitleLabel addGestureRecognizer:tapGestureRecgnizer];
        
        originY += CGRectGetHeight(_subtitleLabel.bounds) + 10;
        _contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], CGRectGetHeight([self cellFrame]) - originY}];
        [_contentLabel setTextColor:[UIColor room107YellowColor]];
        [_contentLabel setFont:[UIFont room107SystemFontTwo]];
        [_contentLabel setTextAlignment:NSTextAlignmentCenter];
        [_contentLabel setTextColor:[UIColor room107YellowColor]];
        [self addSubview:_contentLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, customShrinkMutableStringTableViewCellMinHeight);
}

- (void)subtitleLabelDidClick {
    if (!_shrinkHidden) {
        _contentLabel.hidden = !_contentLabel.hidden;
        if (_shrinkHandlerBlock) {
            _shrinkHandlerBlock(_contentLabel.hidden);
        }
    }
}

- (void)setSubtitle:(NSString *)subtitle {
    if (!_shrinkHidden) {
        subtitle = [subtitle stringByAppendingString:_contentLabel.hidden ? @"\ue62a" : @"\ue629"];
    }
    NSMutableAttributedString *attributedString = [NSString attributedStringFromString:subtitle andFont:[UIFont room107FontThree] andColor:[UIColor room107YellowColor]];
    [_subtitleLabel setFrame:(CGRect){(CGRectGetWidth([self cellFrame]) - attributedString.size.width) / 2, 0, attributedString.size.width, attributedString.size.height + 2}];
    [_subtitleLabel setAttributedText:attributedString];
}

- (void)setContent:(NSString *)content {
    CGRect contentRect = [self getContentRectWithContent:content];
    [_contentLabel setFrame:(CGRect){_contentLabel.frame.origin, contentRect.size}];
}

- (void)setContentHidden:(BOOL)hidden {
    _contentLabel.hidden = hidden;
}

- (void)setShrinkHidden:(BOOL)hidden {
    _shrinkHidden = hidden;
}

- (void)setContentColor:(UIColor *)color {
    [_contentLabel setTextColor:color];
}

- (CGFloat)getCellHeightWithContent:(NSString *)content {
    CGRect contentRect = [self getContentRectWithContent:content];
    
    return customShrinkMutableStringTableViewCellMinHeight + contentRect.size.height;
}

- (CGRect)getContentRectWithContent:(NSString *)content {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    NSDictionary *attributes = @{NSFontAttributeName:_contentLabel.font,
                                 NSParagraphStyleAttributeName:paragraphStyle};
    
    CGRect contentRect = [content boundingRectWithSize:(CGSize){_contentLabel.frame.size.width, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    _contentLabel.attributedText = [[NSAttributedString alloc] initWithString:content ? content : @"" attributes:attributes];
    return contentRect;
}

- (void)setShrinkHandler:(void(^)(BOOL hidden))handler {
    _shrinkHandlerBlock = handler;
}

@end
