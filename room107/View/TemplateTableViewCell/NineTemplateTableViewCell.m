//
//  NineTemplateTableViewCell.m
//  room107
//
//  Created by ningxia on 16/4/15.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "NineTemplateTableViewCell.h"
#import "CustomImageView.h"
#import "SearchTipLabel.h"
#import "ReddieView.h"

@interface NineTemplateTableViewCell ()

@property (nonatomic, strong) CustomImageView *customImageView;
@property (nonatomic, strong) SearchTipLabel *titleTextLabel;
@property (nonatomic, strong) ReddieView *reddieView;
@property (nonatomic, strong) SearchTipLabel *subtextLabel;
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation NineTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];

        CGFloat imageViewWidth = 44;
        CGFloat imageViewHeight = 44;
        CGFloat originY = (CGRectGetHeight([self cellFrame]) - imageViewHeight) / 2;
        _customImageView = [[CustomImageView alloc] initWithFrame:(CGRect){0, originY, imageViewWidth, imageViewHeight}];
        [self.contentView addSubview:_customImageView];
        
        originY += 4;
        CGFloat labelHeight = 16;
        _titleTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        [_titleTextLabel setTextColor:[UIColor room107GrayColorD]];
        [_titleTextLabel setNumberOfLines:1];
        [self.contentView addSubview:_titleTextLabel];
        
        //未读标示
        _reddieView = [[ReddieView alloc] initWithOrigin:CGPointMake(0, originY - 2)];
        [self.contentView addSubview:_reddieView];
        
        originY += CGRectGetHeight(_titleTextLabel.bounds) + 8;
        labelHeight = 12;
        _subtextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        [_subtextLabel setFont:[UIFont room107SystemFontOne]];
        [_subtextLabel setTextColor:[UIColor room107GrayColorD]];
        [_subtextLabel setNumberOfLines:1];
        [self.contentView addSubview:_subtextLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, nineTemplateTableViewCellHeight);
}

- (void)setTemplateDataDictionary:(NSDictionary *)dataDic {
    _customImageView.hidden = NO;
    [_customImageView setCornerRadius:0];
    if ([dataDic[@"imageType"] isEqual:@1]) {
        [_customImageView setCornerRadius:CGRectGetHeight(_customImageView.bounds) / 2];
    }
    
    CGFloat originX = 11;
    CGFloat imageViewWidth = CGRectGetWidth(_customImageView.bounds) + 11;
    CGFloat labelMaxWidth = CGRectGetWidth([self cellFrame]) - 2 * originX - imageViewWidth;
    if (!dataDic[@"imageUrl"] || [dataDic[@"imageUrl"] isEqualToString:@""]) {
        _customImageView.hidden = YES;
        labelMaxWidth = CGRectGetWidth([self cellFrame]) - 2 * originX;
        imageViewWidth = 0;
    }
    
    //计算文字的宽度
    CGRect textLabelRect = [dataDic[@"text"] ? dataDic[@"text"] : @"" boundingRectWithSize:(CGSize){labelMaxWidth, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleTextLabel.font} context:nil];
    CGRect subtextLabelRect = [dataDic[@"subtext"] ? dataDic[@"subtext"] : @"" boundingRectWithSize:(CGSize){labelMaxWidth, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_subtextLabel.font} context:nil];
    CGFloat labelWidth = MAX(textLabelRect.size.width, subtextLabelRect.size.width);
    originX = (CGRectGetWidth([self cellFrame]) - imageViewWidth - labelWidth) / 2;
    
    CGRect imageViewFrame = _customImageView.frame;
    imageViewFrame.origin.x = originX;
    [_customImageView setFrame:imageViewFrame];
    
    CGRect labelFrame = _titleTextLabel.frame;
    labelFrame.origin.x = originX + imageViewWidth;
    labelFrame.size.width = labelWidth;
    [_titleTextLabel setFrame:labelFrame];
    
    labelFrame = _subtextLabel.frame;
    labelFrame.origin.x = _titleTextLabel.frame.origin.x;
    labelFrame.size.width = labelWidth;
    [_subtextLabel setFrame:labelFrame];
    
    [_customImageView setImageWithURL:dataDic[@"imageUrl"]];
    [_titleTextLabel setText:dataDic[@"text"]];
    [_subtextLabel setText:dataDic[@"subtext"]];
    
    _reddieView.hidden = ![dataDic[@"reddie"] boolValue];
    if (dataDic[@"text"] && [dataDic[@"reddie"] boolValue]) {
        CGRect frame = _reddieView.frame;
        frame.origin.x = _titleTextLabel.frame.origin.x + textLabelRect.size.width;
        [_reddieView setFrame:frame];
    }
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
