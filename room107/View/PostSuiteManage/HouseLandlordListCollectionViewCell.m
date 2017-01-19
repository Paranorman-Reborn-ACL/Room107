//
//  HouseLandlordListCollectionViewCell.m
//  room107
//
//  Created by ningxia on 16/4/21.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "HouseLandlordListCollectionViewCell.h"
#import "CustomImageView.h"
#import "SearchTipLabel.h"

@interface HouseLandlordListCollectionViewCell ()

@property (nonatomic, strong) CustomImageView *customImageView;
@property (nonatomic, strong) SearchTipLabel *headTextLabel;
@property (nonatomic, strong) SearchTipLabel *middleTextLabel;
@property (nonatomic, strong) SearchTipLabel *middleTailTextLabel;
@property (nonatomic, strong) SearchTipLabel *footTextLabel;
@property (nonatomic, strong) SearchTipLabel *footSubtextLabel;

@end

@implementation HouseLandlordListCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        //圆角
        self.layer.cornerRadius = 4.0f;
        self.layer.masksToBounds = YES;
        //描边
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [UIColor room107GrayColorB].CGColor;
        
        _customImageView = [[CustomImageView alloc] initWithFrame:(CGRect){0, 0, [CommonFuncs houseLandlordListImageViewSize]}];
        [self addSubview:_customImageView];
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){0, CGRectGetHeight(_customImageView.bounds), CGRectGetWidth(frame), 0.5}];
        [lineView setBackgroundColor:[UIColor room107GrayColorB]];
        [self addSubview:lineView];
        
        CGFloat originY = 11;
        CGFloat labelHeight = 25;
        _headTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        [_headTextLabel setBackgroundColor:[UIColor room107YellowColor]];
        [_headTextLabel setTextAlignment:NSTextAlignmentCenter];
        [_headTextLabel setTextColor:[UIColor whiteColor]];
        [_headTextLabel setText:lang(@"HouseHasNewMessage")];
        [_headTextLabel setFont:[UIFont room107SystemFontOne]];
        [_headTextLabel setNumberOfLines:1];
        //计算文字的宽度
        CGRect contentRect = [lang(@"HouseHasNewMessage") boundingRectWithSize:(CGSize){CGRectGetWidth(self.bounds), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_headTextLabel.font} context:nil];
        CGRect textLabelFrame = _headTextLabel.frame;
        textLabelFrame.size.width = contentRect.size.width + 10;
        textLabelFrame.origin.x = CGRectGetWidth(frame) - textLabelFrame.size.width;
        [_headTextLabel setFrame:textLabelFrame];
        [self addSubview:_headTextLabel];
        
        CGFloat originX = 11;
        labelHeight = 35;
        originY = CGRectGetHeight(_customImageView.bounds) - 11 - labelHeight;
        _middleTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        [_middleTextLabel setBackgroundColor:[UIColor colorFromHexString:@"#494949" alpha:0.9]];
        [_middleTextLabel setTextAlignment:NSTextAlignmentCenter];
        [_middleTextLabel setTextColor:[UIColor whiteColor]];
        [_middleTextLabel setFont:[UIFont room107SystemFontFour]];
        [_middleTextLabel setNumberOfLines:1];
        [self addSubview:_middleTextLabel];
        
        labelHeight = 25;
        originY = CGRectGetHeight(_customImageView.bounds) - 11 - labelHeight;
        _middleTailTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        [_middleTailTextLabel setBackgroundColor:[UIColor colorFromHexString:@"#494949" alpha:0.9]];
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
        
        originY += CGRectGetHeight(_footTextLabel.bounds) + 11;
        labelHeight = 12;
        _footSubtextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_footSubtextLabel setFont:[UIFont room107SystemFontOne]];
        [_footSubtextLabel setTextColor:[UIColor room107GrayColorD]];
        [_footSubtextLabel setNumberOfLines:1];
        [self addSubview:_footSubtextLabel];
    }
    
    return self;
}

- (void)setHouseListDataDictionary:(NSDictionary *)dataDic {
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
    
    _headTextLabel.hidden = dataDic[@"newUpdate"] ? [dataDic[@"newUpdate"] boolValue] ? NO : YES : YES;
    
    _middleTextLabel.hidden = dataDic[@"middleText"] ? [dataDic[@"middleText"] isEqualToString:@""] ? YES : NO : YES;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:dataDic[@"middleText"]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontTwo] range:NSMakeRange(0, 1)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontFour] range:NSMakeRange(1, [dataDic[@"middleText"] length] - 1)];
    CGRect textLabelFrame = _middleTextLabel.frame;
    textLabelFrame.size.width = attributedString.size.width + 22;
    [_middleTextLabel setFrame:textLabelFrame];
    [_middleTextLabel setAttributedText:attributedString];
    
    _middleTailTextLabel.hidden = dataDic[@"middleTailText"] ? [dataDic[@"middleTailText"] isEqualToString:@""] ? YES : NO : YES;
    //计算文字的宽度
    CGRect contentRect = [dataDic[@"middleTailText"] ? dataDic[@"middleTailText"] : @"" boundingRectWithSize:(CGSize){CGRectGetWidth(self.bounds), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_middleTailTextLabel.font} context:nil];
    textLabelFrame = _middleTailTextLabel.frame;
    textLabelFrame.size.width = contentRect.size.width + 15;
    textLabelFrame.origin.x = CGRectGetWidth(self.bounds) - textLabelFrame.size.width;
    [_middleTailTextLabel setFrame:textLabelFrame];
    [_middleTailTextLabel setText:dataDic[@"middleTailText"]];
    
    [_footTextLabel setText:dataDic[@"footText"]];
    [_footSubtextLabel setText:dataDic[@"footSubtext"]];
}

@end
