//
//  TotalPriceView.m
//  room107
//
//  Created by ningxia on 15/9/14.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "TotalPriceView.h"
#import "SearchTipLabel.h"

@interface TotalPriceView ()

@property (nonatomic, strong) SearchTipLabel *titleLabel;
@property (nonatomic, strong) SearchTipLabel *contentLabel;

@end

@implementation TotalPriceView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){0, 0, CGRectGetWidth(frame), 0.5}];
        [lineView setBackgroundColor:[UIColor room107GrayColorA]];
        [self addSubview:lineView];
        
        CGFloat height = frame.size.height;
        CGFloat titleWidth = 100;
        _titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, 0, titleWidth, height}];
        [_titleLabel setTextColor:[UIColor room107GreenColor]];
        [self addSubview:_titleLabel];
        
        CGFloat contentWidth = 220;
        _contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){frame.size.width - contentWidth - 22, 0, contentWidth, height}];
        [_contentLabel setTextAlignment:NSTextAlignmentRight];
        [_contentLabel setTextColor:[UIColor room107GreenColor]];
        [self addSubview:_contentLabel];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    [_titleLabel setText:title];
    
    if ([title isEqualToString:@""]) {
        _contentLabel.center = CGPointMake(self.frame.size.width / 2, _contentLabel.center.y);
    }
}

- (void)setContent:(NSString *)content {
    [_contentLabel setText:content];
}

- (void)setAttributedTitle:(NSMutableAttributedString *)title {
    [_titleLabel setAttributedText:title];
}

- (void)setAttributedContent:(NSMutableAttributedString *)content {
    [_contentLabel setAttributedText:content];
}

- (void)setContentAlignment:(NSTextAlignment)alignment {
    [_contentLabel setTextAlignment:alignment];
}

@end
