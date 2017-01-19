//
//  ExpenseOrderLargeItemView.m
//  room107
//
//  Created by ningxia on 15/9/14.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ExpenseOrderLargeItemView.h"
#import "SearchTipLabel.h"

@interface ExpenseOrderLargeItemView ()

@property (nonatomic, strong) void (^shrinkHandlerBlock)();
@property (nonatomic) BOOL hasButton;

@end

@implementation ExpenseOrderLargeItemView

- (id)initWithFrame:(CGRect)frame withButton:(BOOL)hasButton {
    self = [super initWithFrame:frame];
    
    if (self) {
        CGFloat originX = 22;
        CGFloat height = frame.size.height;
        CGFloat titleWidth = 150;
        _titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0, titleWidth, height}];
        [_titleLabel setFont:[UIFont room107SystemFontTwo]];
        [_titleLabel setTextColor:[UIColor room107GrayColorD]];
        [self addSubview:_titleLabel];
        if (hasButton) {
            UITapGestureRecognizer *tapGestureRecgnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelDidClick)];
            _titleLabel.userInteractionEnabled = YES;
            [_titleLabel addGestureRecognizer:tapGestureRecgnizer];
        }
        
        _hasButton = hasButton;
        
        CGFloat contentWidth = 150;
        _contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){frame.size.width - originX - contentWidth, 0, contentWidth, height}];
        [_contentLabel setTextAlignment:NSTextAlignmentRight];
        [_contentLabel setFont:[UIFont room107SystemFontTwo]];
        [_contentLabel setTextColor:[UIColor room107GrayColorE]];
        [self addSubview:_contentLabel];
    }
    
    return self;
}

- (void)titleLabelDidClick {
    if (self.shrinkHandlerBlock) {
        self.shrinkHandlerBlock();
    }
}

- (void)setTitle:(NSString *)title {
    [_titleLabel setText:title];
}

- (void)setContent:(NSString *)content {
    [_contentLabel setText:content];
}

- (void)setShrinkHandler:(void(^)())handler {
    self.shrinkHandlerBlock = handler;
}

- (void)setShrink:(BOOL)shrink {
    if (_hasButton) {
        NSString *title = _titleLabel.text;
        [_titleLabel setText:[title stringByAppendingString:shrink ? @"\ue62a" : @"\ue629"]];
    }
}

- (void)setTextColor:(UIColor *)color {
    [_titleLabel setTextColor:color];
    [_contentLabel setTextColor:color];
}

- (void)setAttributedTitle:(NSMutableAttributedString *)title {
    [_titleLabel setAttributedText:title];
}
@end
