//
//  TenTemplateTableViewCell.m
//  room107
//
//  Created by 107间 on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "TenTemplateTableViewCell.h"
#import "CustomImageView.h"
#import "ReddieView.h"


@interface TenTemplateTableViewCell()

@property (nonatomic, strong) CustomImageView *iconImageView; //图标
@property (nonatomic, strong) UILabel *textTitleLabel;        //大字
@property (nonatomic, strong) UILabel *subtextTitleLabel;     //小字
@property (nonatomic, strong) UILabel *headTextTitleLabel;         //右侧小字
@property (nonatomic, strong) ReddieView *reddieView;         //小红点
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation TenTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    if (self) {
        //图标
        self.iconImageView = [[CustomImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
        //大字
        self.textTitleLabel = [[UILabel alloc] init];
        [_textTitleLabel setFont:[UIFont room107SystemFontThree]];
        [_textTitleLabel setTextColor:[UIColor room107GrayColorE]];
        [_textTitleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:_textTitleLabel];
        //小字
        self.subtextTitleLabel = [[UILabel alloc] init];
        [_subtextTitleLabel setFont:[UIFont room107SystemFontOne]];
        [_subtextTitleLabel setTextColor:[UIColor room107GrayColorD]];

        [self.contentView addSubview:_subtextTitleLabel];
        //右侧小字
        self.headTextTitleLabel = [[UILabel alloc] init];
        [_headTextTitleLabel setTextAlignment:NSTextAlignmentRight];
        [_headTextTitleLabel setTextColor:[UIColor room107GrayColorC]];
        [_headTextTitleLabel setFont:[UIFont room107SystemFontOne]];
        [self.contentView addSubview:_headTextTitleLabel];

    }
    return self;
}

- (void)setTenTemplateInfo:(NSDictionary *)info {
    NSString *imageUrl = info[@"imageUrl"];
    NSString *headText = info[@"headText"];
    NSString *text = info[@"text"];
    NSString *subtext = info[@"subtext"];
    NSNumber *reddie = info[@"reddie"];
    NSNumber *imageType = info[@"imageType"];
    _holdTargetURLs = info[@"holdTargetUrl"];
   
    CGFloat originX;
    CGFloat originY;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat titleLabelWidth = 209.0f;
    
    if (nil == imageUrl || [imageUrl isEqualToString:@""]) {
        //图标缺失
        originX = 11;
        originY = (tenTemplateTableViewCellHeight - 18 - 15 - 7.5) / 2;
        
         //大字
        [_textTitleLabel setFrame:CGRectMake(originX, originY, titleLabelWidth, 22)];
        [_textTitleLabel setText:text];
        
        //通过字符串长度 获得小红点的坐标
        CGRect contentRect = [text boundingRectWithSize:(CGSize){MAXFLOAT, _textTitleLabel.frame.size.height} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107SystemFontThree]} context:nil];
        CGFloat originReddieX = contentRect.size.width + originX;
        if (originReddieX > CGRectGetMaxX(_textTitleLabel.frame)) {
            originReddieX = CGRectGetMaxX(_textTitleLabel.frame);
        }
        //小红点
        if (!_reddieView) {
            self.reddieView = [[ReddieView alloc] initWithOrigin:CGPointMake(originReddieX, originY - 4)];
            [self.contentView addSubview:_reddieView];
        }
        [_reddieView setHidden:![reddie boolValue]];
        [_reddieView resetOrigin:CGPointMake(originReddieX, originY - 4)];
        
        //右侧小字
        [_headTextTitleLabel setFrame:CGRectMake(240, originY + 2, width - 240 - originX, 13)];
        [_headTextTitleLabel setText:headText];
        
        //小字
        originY = CGRectGetMaxY(_textTitleLabel.frame) + 7.5;
        [_subtextTitleLabel setFrame:CGRectMake(originX, originY, width - originX * 2, 15)];
        [_subtextTitleLabel setText:subtext];
        
        UILongPressGestureRecognizer *longPressGestureRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewDidLongPress:)];
        longPressGestureRec.minimumPressDuration = 0.5f;
        [self addGestureRecognizer:longPressGestureRec];
    } else {
        //图标未缺失
        originX = 11;
        CGFloat diameter = 44.0f;
        titleLabelWidth = 154.0f;
        originY = (tenTemplateTableViewCellHeight - diameter) / 2;
        
        //图标
        [_iconImageView setFrame:CGRectMake(originX, originY, diameter, diameter)];
        [_iconImageView setImageWithURL:imageUrl];
        
        //大字
        originY = (tenTemplateTableViewCellHeight - 18 - 15 - 7.5) / 2;
        originX = CGRectGetMaxX(_iconImageView.frame) + 11;
        [_textTitleLabel setFrame:CGRectMake(originX, originY, titleLabelWidth, 18)];
        [_textTitleLabel setText:text];
        
        //通过字符串长度 获得小红点的坐标
        CGRect contentRect = [text boundingRectWithSize:(CGSize){MAXFLOAT, _textTitleLabel.frame.size.height} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107SystemFontThree]} context:nil];
        CGFloat originReddieX = contentRect.size.width + originX;
        if (originReddieX > CGRectGetMaxX(_textTitleLabel.frame)) {
            originReddieX = CGRectGetMaxX(_textTitleLabel.frame);
        }
        
        //小红点
        if (!_reddieView) {
            self.reddieView = [[ReddieView alloc] initWithOrigin:CGPointMake(originReddieX, originY - 4)];
            [self.contentView addSubview:_reddieView];
        }
        
        [_reddieView setHidden:![reddie boolValue]];
        [_reddieView resetOrigin:CGPointMake(originReddieX, originY - 4)];
        
        //右侧小字
        [_headTextTitleLabel setFrame:CGRectMake(240, originY + 2, width - 240 - 11, 13)];
        [_headTextTitleLabel setText:headText];
        
        //小字
        originY = CGRectGetMaxY(_textTitleLabel.frame) + 7.5;
        [_subtextTitleLabel setFrame:CGRectMake(originX, originY, width - 11 * 3 - diameter, 15)];
        [_subtextTitleLabel setText:subtext];
        
        UILongPressGestureRecognizer *longPressGestureRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewDidLongPress:)];
        longPressGestureRec.minimumPressDuration = 0.5f;
        [self addGestureRecognizer:longPressGestureRec];
        
        if (imageType && [imageType isEqual:@1]) {
            [_iconImageView setCornerRadius:_iconImageView.frame.size.width / 2];
        } else {
            [_iconImageView setCornerRadius:0];
        }
    }
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
