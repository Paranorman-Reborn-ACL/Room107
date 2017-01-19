//
//  ThirteenTemplateTableViewCell.m
//  room107
//
//  Created by ningxia on 16/4/12.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "ThirteenTemplateTableViewCell.h"
#import "CustomImageView.h"
#import "SearchTipLabel.h"

@interface ThirteenTemplateTableViewCell ()

@property (nonatomic, strong) CustomImageView *customImageView;
@property (nonatomic, strong) SearchTipLabel *titleTextLabel;
@property (nonatomic, strong) SearchTipLabel *subtextLabel;
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation ThirteenTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        CGFloat originX = 11;
        CGFloat imageViewWidth = 15;
        CGFloat imageViewHeight = 15;
        CGFloat originY = (CGRectGetHeight([self cellFrame]) - imageViewHeight) / 2;
        
        _customImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, originY, imageViewWidth, imageViewHeight}];
        [_customImageView setCornerRadius:imageViewHeight / 2];
        [self.contentView addSubview:_customImageView];

        originY = 0;
        CGFloat labelHeight = CGRectGetHeight([self cellFrame]);
        _titleTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        [_titleTextLabel setTextColor:[UIColor room107GrayColorD]];
        [_titleTextLabel setNumberOfLines:1];
        [self.contentView addSubview:_titleTextLabel];
        
        _subtextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        [_subtextLabel setFont:[UIFont room107SystemFontOne]];
        [_subtextLabel setNumberOfLines:1];
        [self.contentView addSubview:_subtextLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, thirteenTemplateTableViewCellHeight);
}

- (void)setTemplateDataDictionary:(NSDictionary *)dataDic {
    _customImageView.hidden = YES;
    [_customImageView setCornerRadius:0];
    if ([dataDic[@"imageType"] isEqual:@1]) {
        [_customImageView setCornerRadius:CGRectGetHeight(_customImageView.bounds) / 2];
    }
    CGFloat originX = _customImageView.frame.origin.x;
    if (dataDic[@"imageUrl"] && ![dataDic[@"imageUrl"] isEqualToString:@""]) {
        originX += CGRectGetWidth(_customImageView.bounds) + 5;
        _customImageView.hidden = NO;
    }
    [_customImageView setImageWithURL:dataDic[@"imageUrl"]];
    
    _titleTextLabel.hidden = YES;
    if (dataDic[@"text"] && ![dataDic[@"text"] isEqualToString:@""]) {
        _titleTextLabel.hidden = NO;
        //计算文字的宽度
        CGRect contentRect = [dataDic[@"text"] ? dataDic[@"text"] : @"" boundingRectWithSize:(CGSize){CGRectGetWidth([self cellFrame]), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleTextLabel.font} context:nil];
        CGRect frame = _titleTextLabel.frame;
        frame.origin.x = originX;
        frame.size.width = contentRect.size.width;
        [_titleTextLabel setFrame:frame];
        [_titleTextLabel setText:dataDic[@"text"]];
        
        originX += CGRectGetWidth(_titleTextLabel.bounds) + 11;
    }
    
    CGRect frame = _subtextLabel.frame;
    frame.origin.x = originX;
    frame.size.width = CGRectGetWidth([self cellFrame]) - frame.origin.x - 11;
    [_subtextLabel setFrame:frame];
    [_subtextLabel setText:dataDic[@"subtext"]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat originX = 11;
    [self.lineView setFrame:CGRectMake(originX, CGRectGetHeight(self.contentView.frame) - 0.5, CGRectGetWidth(self.contentView.frame) - originX, 0.5)];
    [self.contentView bringSubviewToFront:self.lineView];
}

- (void)setHoldTargetURL:(NSArray *)holdTargetURLs {
    _holdTargetURLs = holdTargetURLs;
    UILongPressGestureRecognizer *longPressGestureRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewDidLongPress:)];
    longPressGestureRec.minimumPressDuration = 0.5f;
    [self addGestureRecognizer:longPressGestureRec];
}

- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler {
    _viewDidLongPressHandlerBlock = handler;
}

- (void)containerViewDidLongPress:(UILongPressGestureRecognizer *)rec {
    if (rec.state == UIGestureRecognizerStateBegan) {
        //避免长按事件执行两次
        if (_viewDidLongPressHandlerBlock) {
            _viewDidLongPressHandlerBlock(_holdTargetURLs);
        }
    }
}

@end
