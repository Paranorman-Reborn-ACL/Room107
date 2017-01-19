//
//  SixSubTemplateCollectionViewCell.m
//  room107
//
//  Created by ningxia on 16/4/12.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SixSubTemplateCollectionViewCell.h"
#import "CustomImageView.h"
#import "SearchTipLabel.h"
#import "TemplateViewFuncs.h"

@interface SixSubTemplateCollectionViewCell ()

@property (nonatomic, strong) CustomImageView *customImageView;
@property (nonatomic, strong) CustomImageView *headImageView;
@property (nonatomic, strong) SearchTipLabel *headTextLabel;
@property (nonatomic, strong) SearchTipLabel *middleTextLabel;
@property (nonatomic, strong) SearchTipLabel *middleTailTextLabel;
@property (nonatomic, strong) SearchTipLabel *footTextLabel;
@property (nonatomic, strong) SearchTipLabel *footSubtextLabel;
@property (nonatomic, strong) SearchTipLabel *footTailTextLabel;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);
@property (nonatomic, strong) NSDictionary *infoDict;

@end

@implementation SixSubTemplateCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        //圆角
        self.layer.cornerRadius = 4.0f;
        self.layer.masksToBounds = YES;
        //描边
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [UIColor room107GrayColorB].CGColor;
        
        _customImageView = [[CustomImageView alloc] initWithFrame:(CGRect){0, 0, [TemplateViewFuncs sixSubTemplateImageViewSize]}];
        [self addSubview:_customImageView];
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){0, CGRectGetHeight(_customImageView.bounds), CGRectGetWidth(frame), 0.5}];
        [lineView setBackgroundColor:[UIColor room107GrayColorB]];
        [self addSubview:lineView];
        
        CGFloat originX = 11;
        CGFloat originY = 11;
        CGFloat imageViewWidth = 44;
        CGFloat imageViewHeight = 44;
        _headImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, originY, imageViewWidth, imageViewHeight}];
        [_headImageView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_headImageView];
        
        CGFloat labelHeight = 30;
        _headTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){CGRectGetWidth(frame), originY, 0, labelHeight}];
        [_headTextLabel setTextAlignment:NSTextAlignmentCenter];
        [_headTextLabel setTextColor:[UIColor whiteColor]];
        [_headTextLabel setFont:[UIFont room107SystemFontOne]];
        [_headTextLabel setNumberOfLines:1];
        [self addSubview:_headTextLabel];
        
        labelHeight = 45;
        originY = CGRectGetHeight(_customImageView.bounds) - 11 - labelHeight;
        _middleTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        [_middleTextLabel setTextAlignment:NSTextAlignmentCenter];
        [_middleTextLabel setTextColor:[UIColor whiteColor]];
        [_middleTextLabel setNumberOfLines:1];
        [self addSubview:_middleTextLabel];
        
        labelHeight = 30;
        originY = CGRectGetHeight(_customImageView.bounds) - 11 - labelHeight;
        _middleTailTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){CGRectGetWidth(frame), originY, 0, labelHeight}];
        [_middleTailTextLabel setTextAlignment:NSTextAlignmentCenter];
        [_middleTailTextLabel setTextColor:[UIColor whiteColor]];
        [_middleTailTextLabel setFont:[UIFont room107SystemFontOne]];
        [_middleTailTextLabel setNumberOfLines:1];
        [self addSubview:_middleTailTextLabel];
        
        originX = 11;
        originY = CGRectGetHeight(_customImageView.bounds) + 11;
        CGFloat labelWidth = CGRectGetWidth(frame) - 2 * originX;
        labelHeight = 16;
        _footTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_footTextLabel setTextColor:[UIColor room107GrayColorE]];
        [_footTextLabel setNumberOfLines:1];
        [self addSubview:_footTextLabel];
        
        originY += CGRectGetHeight(_footTextLabel.bounds) + 8;
        labelHeight = 12;
        _footSubtextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_footSubtextLabel setFont:[UIFont room107SystemFontOne]];
        [_footSubtextLabel setTextColor:[UIColor room107GrayColorD]];
        [_footSubtextLabel setNumberOfLines:1];
        [self addSubview:_footSubtextLabel];
        
        _footTailTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_footTailTextLabel setTextAlignment:NSTextAlignmentRight];
        [_footTailTextLabel setFont:[UIFont room107SystemFontOne]];
        [_footTailTextLabel setNumberOfLines:1];
        [self addSubview:_footTailTextLabel];
        
        UILongPressGestureRecognizer *longPressGestureRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewDidLongPress:)];
        longPressGestureRec.minimumPressDuration = 0.5f;
        [self addGestureRecognizer:longPressGestureRec];
    }
    
    return self;
}

- (void)setTemplateDataDictionary:(NSDictionary *)dataDic {
    self.infoDict = dataDic;
    if (dataDic[@"imageUrl"] && ![dataDic[@"imageUrl"] isEqualToString:@""]) {
        [_customImageView setContentMode:UIViewContentModeCenter]; //图片按实际大小居中显示
        WEAK_SELF weakSelf = self;
        [_customImageView setImageWithURL:dataDic[@"imageUrl"] placeholderImage:[UIImage imageNamed:@"imageLoading"] withCompletionHandler:^(UIImage *image) {
            if (image) {
                weakSelf.customImageView.contentMode = UIViewContentModeScaleAspectFill; //图片撑满显示
            }
        }];
    } else {
        [_customImageView setImageWithName:@"defaultRoomPic.jpg"];
        _customImageView.contentMode = UIViewContentModeScaleAspectFill; //图片撑满显示
    }
    
    _headImageView.hidden = YES;
    if (dataDic[@"headImageUrl"] && ![dataDic[@"headImageUrl"] isEqualToString:@""]) {
        _headImageView.hidden = NO;
        [_headImageView setImageWithURL:dataDic[@"headImageUrl"]];
    } else {
        if (dataDic[@"headImageName"] && ![dataDic[@"headImageName"] isEqualToString:@""]) {
            _headImageView.hidden = NO;
            [_headImageView setImageWithName:dataDic[@"headImageName"]];
        }
    }
    [_headImageView setCornerRadius:0];
    if ([dataDic[@"headImageType"] isEqual:@1]) {
        [_headImageView setCornerRadius:CGRectGetHeight(_headImageView.bounds) / 2];
    }
    
    _headTextLabel.hidden = dataDic[@"headText"] ? [dataDic[@"headText"] isEqualToString:@""] ? YES : NO : YES;
    //计算文字的宽度
    CGRect contentRect = [dataDic[@"headText"] ? dataDic[@"headText"] : @"" boundingRectWithSize:(CGSize){CGRectGetWidth(self.bounds), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_headTextLabel.font} context:nil];
    CGRect frame = _headTextLabel.frame;
    frame.size.width = contentRect.size.width + 15;
    frame.origin.x = CGRectGetWidth(self.bounds) - frame.size.width;
    [_headTextLabel setFrame:frame];
    [_headTextLabel setText:dataDic[@"headText"]];
    [_headTextLabel setBackgroundColor:[UIColor colorFromHexString:[@"#" stringByAppendingString:dataDic[@"headBackgroundColor"] ? dataDic[@"headBackgroundColor"] : @""]]];
    
    _middleTextLabel.hidden = dataDic[@"middleText"] || dataDic[@"middleSubtext"] ? ([dataDic[@"middleText"] isEqualToString:@""] && [dataDic[@"middleSubtext"] isEqualToString:@""]) ? YES : NO : YES;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[dataDic[@"middleText"] stringByAppendingFormat:@" %@", dataDic[@"middleSubtext"] ? dataDic[@"middleSubtext"] : @""]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontFour] range:NSMakeRange(0, [dataDic[@"middleText"] length])];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontOne] range:NSMakeRange([dataDic[@"middleText"] length] + 1, [dataDic[@"middleSubtext"] length])];
    frame = _middleTextLabel.frame;
    frame.size.width = attributedString.size.width + 22;
    [_middleTextLabel setFrame:frame];
    [_middleTextLabel setAttributedText:attributedString];
    //90%透明度
    [_middleTextLabel setBackgroundColor:[UIColor colorFromHexString:[@"#" stringByAppendingString:dataDic[@"middleBackgroundColor"] ? dataDic[@"middleBackgroundColor"] : @""] alpha:0.9]];
    
    _middleTailTextLabel.hidden = dataDic[@"middleTailText"] ? [dataDic[@"middleTailText"] isEqualToString:@""] ? YES : NO : YES;
    //计算文字的宽度
    contentRect = [dataDic[@"middleTailText"] ? dataDic[@"middleTailText"] : @"" boundingRectWithSize:(CGSize){CGRectGetWidth(self.bounds), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_middleTailTextLabel.font} context:nil];
    frame = _middleTailTextLabel.frame;
    frame.size.width = contentRect.size.width + 15;
    frame.origin.x = CGRectGetWidth(self.bounds) - frame.size.width;
    [_middleTailTextLabel setFrame:frame];
    [_middleTailTextLabel setText:dataDic[@"middleTailText"]];
    //90%透明度
    [_middleTailTextLabel setBackgroundColor:[UIColor colorFromHexString:[@"#" stringByAppendingString:dataDic[@"middleTailBackgroundColor"] ? dataDic[@"middleTailBackgroundColor"] : @""] alpha:0.9]];
    
    [_footTextLabel setText:dataDic[@"footText"]];
    [_footSubtextLabel setText:dataDic[@"footSubtext"]];
    [_footTailTextLabel setText:dataDic[@"footTailText"]];
}

- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler {
    _viewDidLongPressHandlerBlock = handler;
}

- (void)containerViewDidLongPress:(UILongPressGestureRecognizer *)rec {
    if (rec.state == UIGestureRecognizerStateBegan) {
        //避免长按事件执行两次
        if (_viewDidLongPressHandlerBlock) {
            _viewDidLongPressHandlerBlock(_infoDict[@"holdTargetUrl"]);
        }
    }
}
@end
