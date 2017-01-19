//
//  DescriptionTableViewCell.m
//  room107
//
//  Created by ningxia on 15/6/25.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "DescriptionTableViewCell.h"
#import "ThirteenTemplateView.h"
#import "SearchTipLabel.h"

static CGFloat spaceX = 11;
static CGFloat spaceY = 11;

@interface DescriptionTableViewCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) SearchTipLabel *contentLabel;

@end

@implementation DescriptionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView setBackgroundColor:[UIColor room107GrayColorA]];
        CGFloat originX = spaceX;
        CGFloat originY = spaceY;
        
        CGFloat viewWidth = CGRectGetWidth([self cellFrame]);
        _containerView = [[UIView alloc] initWithFrame:(CGRect){0, originY, viewWidth, 100}];
        [_containerView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_containerView];
        
        ThirteenTemplateView *titleView = [[ThirteenTemplateView alloc] initWithFrame:(CGRect){0, 0, viewWidth, 36} andTemplateDataDictionary:@{@"image":@"trim.png", @"text":lang(@"Description")}];
        [_containerView addSubview:titleView];
        
        _contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY + CGRectGetHeight(titleView.bounds), viewWidth - 2 * originX, 100}];
        [_contentLabel setTextColor:[UIColor room107GrayColorD]];
        [_containerView addSubview:_contentLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 100);
}

- (void)setDescription:(NSString *)description {
    _contentLabel.attributedText = [[NSAttributedString alloc] initWithString:description ? description : @"" attributes:[self attributes]];
    CGFloat contentHeight = [self getCellHeightWithDescription:description];
    [_contentLabel setFrame:(CGRect){_contentLabel.frame.origin, _contentLabel.frame.size.width, contentHeight - (2 * spaceY + _contentLabel.frame.origin.y)}];
    [_containerView setFrame:(CGRect){_containerView.frame.origin, _containerView.frame.size.width, contentHeight - spaceY}];
}

- (NSDictionary *)attributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    NSDictionary *attributes = @{NSFontAttributeName:_contentLabel.font,
                                 NSParagraphStyleAttributeName:paragraphStyle};
    
    return attributes;
}

- (CGFloat)getCellHeightWithDescription:(NSString *)description {
    float maxMessageDisplayWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - spaceX * 2;
    CGRect contentRect = [description ? description : @"" boundingRectWithSize:(CGSize){maxMessageDisplayWidth, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:[self attributes] context:nil];
    
    return 2 * spaceY + _contentLabel.frame.origin.y + contentRect.size.height;
}

@end
