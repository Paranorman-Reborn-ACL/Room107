//
//  ThirteenTemplateView.m
//  room107
//
//  Created by ningxia on 16/4/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "ThirteenTemplateView.h"
#import "CustomImageView.h"
#import "SearchTipLabel.h"
#import "DividingLineView.h"

@interface ThirteenTemplateView ()

@property (nonatomic, strong) CustomImageView *customImageView;
@property (nonatomic, strong) SearchTipLabel *textLabel;
@property (nonatomic, strong) SearchTipLabel *subtextLabel;

@end

@implementation ThirteenTemplateView

- (id)initWithFrame:(CGRect)frame andTemplateDataDictionary:(NSDictionary *)dataDic {
    frame.size.height = 36;
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        CGFloat originX = 11;
        CGFloat imageViewWidth = 15;
        CGFloat imageViewHeight = 15;
        CGFloat originY = (CGRectGetHeight(frame) - imageViewHeight) / 2;
        
        _customImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, originY, imageViewWidth, imageViewHeight}];
        [_customImageView setCornerRadius:imageViewHeight / 2];
        [self addSubview:_customImageView];
        
        originY = 0;
        CGFloat labelHeight = CGRectGetHeight(frame);
        _textLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        [_textLabel setTextColor:[UIColor room107GrayColorD]];
        [_textLabel setNumberOfLines:1];
        [self addSubview:_textLabel];
        
        _subtextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        [_subtextLabel setFont:[UIFont room107SystemFontOne]];
        [_subtextLabel setNumberOfLines:1];
        [self addSubview:_subtextLabel];
        
        DividingLineView *lineView = [[DividingLineView alloc] initWithFrame:(CGRect){originX, CGRectGetHeight(frame) - 0.5, CGRectGetWidth(frame) - originX, 0.5}];
        [self addSubview:lineView];
        
        if (dataDic) {
            [self setTemplateDataDictionary:dataDic];
        }
    }
    
    return self;
}

- (void)setTemplateDataDictionary:(NSDictionary *)dataDic {
    _customImageView.hidden = YES;
    [_customImageView setCornerRadius:0];
    if ([dataDic[@"imageType"] isEqual:@1]) {
        [_customImageView setCornerRadius:CGRectGetHeight(_customImageView.bounds) / 2];
    }
    CGFloat originX = _customImageView.frame.origin.x;
    if (dataDic[@"imageUrl"] && ![dataDic[@"imageUrl"] isEqualToString:@""]) {
        _customImageView.hidden = NO;
        [_customImageView setImageWithURL:dataDic[@"imageUrl"]];
        originX += CGRectGetWidth(_customImageView.bounds) + 5;
    } else {
        if (dataDic[@"image"] && ![dataDic[@"image"] isEqualToString:@""]) {
            _customImageView.hidden = NO;
            [_customImageView setImageWithName:dataDic[@"image"]];
            _customImageView.contentMode = UIViewContentModeCenter;
            originX += CGRectGetWidth(_customImageView.bounds) + 5;
        }
    }
    
    _textLabel.hidden = YES;
    if (dataDic[@"text"] && ![dataDic[@"text"] isEqualToString:@""]) {
        _textLabel.hidden = NO;
        //计算文字的宽度
        CGRect contentRect = [dataDic[@"text"] ? dataDic[@"text"] : @"" boundingRectWithSize:(CGSize){CGRectGetWidth(self.frame), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_textLabel.font} context:nil];
        CGRect textLabelFrame = _textLabel.frame;
        textLabelFrame.origin.x = originX;
        textLabelFrame.size.width = contentRect.size.width;
        [_textLabel setFrame:textLabelFrame];
        [_textLabel setText:dataDic[@"text"]];
        
        originX += CGRectGetWidth(_textLabel.bounds) + 11;
    }
    
    CGRect subtextLabelFrame = _subtextLabel.frame;
    subtextLabelFrame.origin.x = originX;
    subtextLabelFrame.size.width = CGRectGetWidth(self.frame) - subtextLabelFrame.origin.x - 11;
    [_subtextLabel setFrame:subtextLabelFrame];
    [_subtextLabel setText:dataDic[@"subtext"]];
}

@end
