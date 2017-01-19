//
//  EightTemplateTableViewCell.m
//  room107
//
//  Created by ningxia on 16/4/13.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "EightTemplateTableViewCell.h"
#import "CustomImageView.h"
#import "SearchTipLabel.h"
#import "ReddieView.h"

@interface EightTemplateTableViewCell ()

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) CustomImageView *customImageView;
@property (nonatomic, strong) SearchTipLabel *titleTextLabel;
@property (nonatomic, strong) ReddieView *reddieView;
@property (nonatomic, strong) SearchTipLabel *subtextLabel;
@property (nonatomic, strong) SearchTipLabel *headTextLabel;
@property (nonatomic, strong) SearchTipLabel *tailTextLabel;
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation EightTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        CGFloat originX = 11;
        CGFloat originY = 11;
        CGFloat imageViewWidth = 44;
        CGFloat imageViewHeight = 44;
        _customImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, originY, imageViewWidth, imageViewHeight}];
        [self.contentView addSubview:_customImageView];
        
        CGFloat labelHeight = 24;
        _headTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        _headTextLabel.layer.cornerRadius = 2.0f;
        _headTextLabel.layer.masksToBounds = YES;
        [_headTextLabel setTextAlignment:NSTextAlignmentCenter];
        [_headTextLabel setTextColor:[UIColor whiteColor]];
        [_headTextLabel setFont:[UIFont room107SystemFontTwo]];
        [_headTextLabel setNumberOfLines:1];
        [self.contentView addSubview:_headTextLabel];

        originX += CGRectGetWidth(_customImageView.bounds) + 11;
        originY += 2;
        CGFloat labelWidth = CGRectGetWidth([self cellFrame]) - originX - 11;
        labelHeight = 16;
        _titleTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_titleTextLabel setTextColor:[UIColor room107GrayColorE]];
        [_titleTextLabel setNumberOfLines:1];
        [self.contentView addSubview:_titleTextLabel];
        
        //未读标示
        _reddieView = [[ReddieView alloc] initWithOrigin:CGPointMake(originX, originY - 2)];
        [self.contentView addSubview:_reddieView];
        
        originY += CGRectGetHeight(_titleTextLabel.bounds) + 8;
        _subtextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_subtextLabel setTextColor:[UIColor room107GrayColorD]];
        [_subtextLabel setNumberOfLines:1];
        [self.contentView addSubview:_subtextLabel];
        
        originX = 11;
        originY = CGRectGetHeight(_customImageView.bounds) + 22;
        labelWidth = CGRectGetWidth([self cellFrame]) - 2 * originX;
        labelHeight = 14;
        _tailTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_tailTextLabel setTextColor:[UIColor room107GrayColorD]];
        [_tailTextLabel setFont:[UIFont room107SystemFontTwo]];
        [_tailTextLabel setNumberOfLines:1];
        [self.contentView addSubview:_tailTextLabel];
        
        _coverView = [[UIView alloc] initWithFrame:[self cellFrame]];
        [_coverView setBackgroundColor:[UIColor colorFromHexString:@"#c9c9c9" alpha:0.4]];
        [self.contentView addSubview:_coverView];
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidLongPress:)];
        _longPressGesture.minimumPressDuration = 0.5f;
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, eightTemplateTableViewCellHeight);
}

- (void)setTemplateDataDictionary:(NSDictionary *)dataDic {
    _coverView.hidden = [dataDic[@"isEnable"] boolValue];
    if (_longPressGesture) {
        if ([dataDic[@"isEnable"] boolValue]) {
            [self.contentView addGestureRecognizer:_longPressGesture];
        } else {
            [self.contentView removeGestureRecognizer:_longPressGesture];
        }
    }
    
    _customImageView.hidden = YES;
    [_customImageView setCornerRadius:0];
    if ([dataDic[@"imageType"] isEqual:@1]) {
        [_customImageView setCornerRadius:CGRectGetHeight(_customImageView.bounds) / 2];
    }
    CGFloat originX = _customImageView.frame.origin.x;
    if (dataDic[@"imageUrl"] && ![dataDic[@"imageUrl"] isEqualToString:@""]) {
        originX += CGRectGetWidth(_customImageView.bounds) + 11;
        _customImageView.hidden = NO;
    }
    CGFloat labelWidth = CGRectGetWidth([self cellFrame]) - 2 * originX;
    CGRect labelFrame = _titleTextLabel.frame;
    labelFrame.origin.x = originX;
    labelFrame.size.width = labelWidth;
    [_titleTextLabel setFrame:labelFrame];
    labelFrame = _subtextLabel.frame;
    labelFrame.origin.x = originX;
    labelFrame.size.width = labelWidth;
    [_subtextLabel setFrame:labelFrame];
    [_customImageView setImageWithURL:dataDic[@"imageUrl"]];
    [_titleTextLabel setText:dataDic[@"text"]];
    [_subtextLabel setText:dataDic[@"subtext"]];
    
    _headTextLabel.hidden = dataDic[@"headText"] ? [dataDic[@"headText"] isEqualToString:@""] ? YES : NO : YES;
    //计算文字的宽度
    CGRect contentRect = [dataDic[@"headText"] ? dataDic[@"headText"] : @"" boundingRectWithSize:(CGSize){CGRectGetWidth([self cellFrame]), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_headTextLabel.font} context:nil];
    CGRect frame = _headTextLabel.frame;
    frame.size.width = contentRect.size.width + 22;
    frame.origin.x = CGRectGetWidth([self cellFrame]) - frame.size.width - 11;
    [_headTextLabel setFrame:frame];
    [_headTextLabel setText:dataDic[@"headText"]];
    [_headTextLabel setBackgroundColor:[UIColor colorFromHexString:[@"#" stringByAppendingString:dataDic[@"headBackgroundColor"] ? dataDic[@"headBackgroundColor"] : @""]]];
    
    [_tailTextLabel setText:dataDic[@"tailText"]];
    _holdTargetURLs = dataDic[@"holdTargetUrl"];
    
    _reddieView.hidden = ![dataDic[@"reddie"] boolValue];
    if (dataDic[@"text"] && [dataDic[@"reddie"] boolValue]) {
        CGRect frame = _reddieView.frame;
        //计算文字的宽度
        CGRect contentRect = [dataDic[@"text"] boundingRectWithSize:(CGSize){CGRectGetWidth(_titleTextLabel.bounds), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleTextLabel.font} context:nil];
        frame.origin.x = _titleTextLabel.frame.origin.x + contentRect.size.width;
        [_reddieView setFrame:frame];
    }
}

- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler {
    _viewDidLongPressHandlerBlock = handler;
}

- (void)viewDidLongPress:(UILongPressGestureRecognizer *)rec {
    if (rec.state == UIGestureRecognizerStateBegan) {
        //避免长按事件执行两次
        if (_viewDidLongPressHandlerBlock) {
            _viewDidLongPressHandlerBlock(_holdTargetURLs);
        }
    }
}

@end
