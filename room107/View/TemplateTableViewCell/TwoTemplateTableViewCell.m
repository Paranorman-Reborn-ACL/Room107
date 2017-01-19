//
//  TwoTemplateTableViewCell.m
//  room107
//
//  Created by 107间 on 16/4/8.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "TwoTemplateTableViewCell.h"
#import "SearchTipLabel.h"
#import "NSString+AttributedString.h"
#import "ReddieView.h"
#import "CustomImageView.h"

static CGFloat textTitleLabelHeight = 18.0f;
static CGFloat subtextTitleLabelheight = 15.0f;
static CGFloat tailTextLabelHeight = 15.0f;

@interface TwoTemplateTableViewCell()


@property (nonatomic, strong) CustomImageView *iconImageView; //左侧图标
@property (nonatomic, strong) UILabel *textTitleLabel; //左侧大字
@property (nonatomic, strong) UILabel *subtextTitleLabel; //左侧小字
@property (nonatomic, strong) CustomImageView *icontailImageView; //右侧图标
@property (nonatomic, strong) UILabel *tailTextLabel; //右侧小字
@property (nonatomic, strong) ReddieView *reddieView; //红点
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation TwoTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    if (self) {
        //左侧图标
        self.iconImageView = [[CustomImageView alloc] init];
        [_iconImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:_iconImageView];
        
        //左侧大字
        _textTitleLabel = [[UILabel alloc] init];
        [_textTitleLabel setFont:[UIFont room107SystemFontThree]];
        [_textTitleLabel setTextColor:[UIColor room107GrayColorD]];
        [self.contentView addSubview:_textTitleLabel];
        
        //左侧小字
        _subtextTitleLabel = [[UILabel alloc] init];
        [_subtextTitleLabel setFont:[UIFont room107SystemFontOne]];
        [_subtextTitleLabel setTextColor:[UIColor room107GrayColorC]];
        [self.contentView addSubview:_subtextTitleLabel];
        
        //右侧图标
        self.icontailImageView = [[CustomImageView alloc] init];
        [self.contentView addSubview:_icontailImageView];
        
        //右侧小字
        _tailTextLabel = [[UILabel alloc] init];
        [_tailTextLabel setTextColor:[UIColor room107GrayColorD]];
        [_tailTextLabel setFont:[UIFont room107SystemFontTwo]];
        [_tailTextLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_tailTextLabel];
        
        //小红点
        self.reddieView = [[ReddieView alloc] initWithOrigin:CGPointMake(0, 0)];
        [_reddieView setHidden:YES];
        [self.contentView addSubview:_reddieView];
    }
    return self;
}


- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, twoTemplateTableViewCellHeight);
}

- (void)setTwoTemplateInfo:(NSDictionary *)info {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    NSString *imageUrl = info[@"imageUrl"];
    NSNumber *imageType = info[@"imageType"];
    NSString *text = info[@"text"];
    NSString *subtext = info[@"subtext"];
    NSNumber *reddie = info[@"reddie"];
    NSString *tailText = info[@"tailText"];
    NSString *tailImageUrl = info[@"tailImageUrl"];
    NSNumber *tailImageType = info[@"tailImageType"];
    NSString *imageCode = info[@"imageCode"];
    _holdTargetURLs = info[@"holdTargetUrl"];


    CGFloat originX = 11.0f;
    CGFloat originY;
    CGFloat imageWidth = 22.0f;
    CGFloat tailImageWidth = 30.0f;
    
    if (imageUrl && ![imageUrl isEqualToString:@""]) {
        originY = (twoTemplateTableViewCellHeight - imageWidth) / 2;
        //有左侧图标
        [_iconImageView setFrame:CGRectMake(originX, originY, imageWidth, imageWidth)];
        [_iconImageView setImageWithURL:imageUrl];
        if (imageType && [imageType isEqual:@1]) {
            [_iconImageView setCornerRadius:_iconImageView.frame.size.width / 2];
        } else {
            [_iconImageView setCornerRadius:0];
        }
    } else {
        [_iconImageView setFrame:CGRectMake(0, 0, 0, 0)];
    }
    if (imageCode && ![imageCode isEqualToString:@""]) {
        originY = (twoTemplateTableViewCellHeight - imageWidth) / 2;
        //有左侧图标
        [_iconImageView setFrame:CGRectMake(originX, originY, imageWidth, imageWidth)];
        [_iconImageView setImage:[UIImage makeImageFromText:imageCode font:[UIFont room107FontFour] color:[UIColor room107GrayColorC]]];
    }
    
    originX = CGRectGetMaxX(_iconImageView.frame) + 11;

    
    if (text && ![text isEqualToString:@""]) {
        //有大字
        originY = (twoTemplateTableViewCellHeight - textTitleLabelHeight) / 2;
        CGRect contentRect = [text boundingRectWithSize:(CGSize){MAXFLOAT, textTitleLabelHeight} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_textTitleLabel.font} context:nil];
        [_textTitleLabel setFrame:CGRectMake(originX, originY, contentRect.size.width, textTitleLabelHeight)];
        if (CGRectGetMaxX(_textTitleLabel.frame) > screenWidth - 11) {
            [_textTitleLabel setFrame:CGRectMake(originX, originY, screenWidth - originX - 11, textTitleLabelHeight)];
        }
        if ([reddie isEqual:@1]) {
            [_reddieView resetOrigin:CGPointMake(CGRectGetMaxX(_textTitleLabel.frame) + 2, CGRectGetMinY(_textTitleLabel.frame) - 4)];
            [_reddieView setHidden:NO];
        } else {
            [_reddieView setHidden:YES];
        }
        [_textTitleLabel setText:text];
    } else {
        [_textTitleLabel setFrame:CGRectMake(0, 0, 0, 0)];
        [_textTitleLabel setText:@""];
    }
    originX = CGRectGetMaxX(_textTitleLabel.frame) + 11;
    
    if (subtext && ![subtext isEqualToString:@""]) {
        //有小字
        originY = (twoTemplateTableViewCellHeight - subtextTitleLabelheight) / 2;
        CGRect contentRext = [subtext boundingRectWithSize:(CGSize){MAXFLOAT, subtextTitleLabelheight} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_subtextTitleLabel.font} context:nil];
        [_subtextTitleLabel setFrame:CGRectMake(originX, originY, contentRext.size.width, subtextTitleLabelheight)];
        if (CGRectGetMaxX(_subtextTitleLabel.frame) > screenWidth - 11 ) {
            [_subtextTitleLabel setFrame:CGRectMake(originX, originY, screenWidth - originX - 11, subtextTitleLabelheight)];
        }
        [_subtextTitleLabel setText:subtext];
    } else {
        [_subtextTitleLabel setFrame:CGRectMake(0, 0, 0, 0)];
        [_subtextTitleLabel setText:@""];
    }
    
    CGFloat spaceToRightEdge = 11;
    if (tailText && ![tailText isEqualToString:@""]) {
        //右侧小字
        originY = (twoTemplateTableViewCellHeight - tailTextLabelHeight) / 2;
        CGRect contentRext = [tailText  boundingRectWithSize:(CGSize){MAXFLOAT, tailTextLabelHeight} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_tailTextLabel.font} context:nil];
        originX = screenWidth - contentRext.size.width - spaceToRightEdge;
        [_tailTextLabel setFrame:CGRectMake(originX, originY, contentRext.size.width, tailTextLabelHeight)];
        spaceToRightEdge += contentRext.size.width;
        if (originX < 11) {
            [_tailTextLabel setFrame:CGRectMake(11, originY, screenWidth - 22, tailTextLabelHeight)];
        }
        [_tailTextLabel setText:tailText];
    } else {
        [_tailTextLabel setFrame:CGRectMake(0, 0, 0, 0)];
        [_tailTextLabel setText:@""];
        spaceToRightEdge = 11;
    }
    
    if (tailImageUrl && ![tailImageUrl isEqualToString:@""]) {
        originY = (twoTemplateTableViewCellHeight - tailImageWidth) / 2;
        originX = screenWidth - tailImageWidth - 5 - spaceToRightEdge;
        [_icontailImageView setFrame:CGRectMake(originX, originY, tailImageWidth, tailImageWidth)];
        [_icontailImageView setImageWithURL:tailImageUrl];
        if (_icontailImageView.frame.origin.x < 11) {
            [_icontailImageView setFrame:CGRectMake(11, originY, tailImageWidth, tailImageWidth)];
            if (tailText && ![tailText isEqualToString:@""]) {
                [_tailTextLabel setFrame:CGRectMake(CGRectGetMaxX(_icontailImageView.frame) + 5, _tailTextLabel.frame.origin.y, screenWidth - CGRectGetMaxX(_icontailImageView.frame) - 5 - 11, _tailTextLabel.frame.size.height)];
            }
        }
        if (tailImageType && [tailImageType isEqual:@1]) {
            [_icontailImageView setCornerRadius:_icontailImageView.frame.size.width / 2];
        } else {
            [_icontailImageView setCornerRadius:0];
        }
    } else {
        [_icontailImageView setFrame:CGRectMake(0, 0, 0, 0)];
    }
    
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
