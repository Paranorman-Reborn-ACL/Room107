//
//  OtherRoomPhotosTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/31.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "OtherRoomPhotosTableViewCell.h"
#import "SearchTipLabel.h"
#import "CustomImageView.h"
#import "NSString+Valid.h"

@interface OtherRoomPhotosTableViewCell ()

@property (nonatomic, strong) UIView *containerView;

@end

@implementation OtherRoomPhotosTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 11;
        CGFloat originY = 5;
        _containerView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth([self cellFrame]) - 2 * originX, CGRectGetHeight([self cellFrame]) - originY}];
        [_containerView setBackgroundColor:[UIColor room107GrayColorB]];
        _containerView.layer.cornerRadius = 4;
        _containerView.layer.masksToBounds = YES;
        [self addSubview:_containerView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, otherRoomPhotosTableViewCellHeight);
}

- (void)setOtherRoomPhotos:(NSMutableArray *)photos {
    for (UIView *subView in [_containerView subviews]) {
        [subView removeFromSuperview];
    }

    CGFloat imageViewWidth = 50;
    CGFloat imageViewX = 15;
    CGFloat imageViewY = 20;
    CGFloat spacingX = (CGRectGetWidth(_containerView.bounds) - 2 * imageViewX - 4 * imageViewWidth) / 3;
    CGFloat labelHeight = 20;
    CGFloat labelY = imageViewY - labelHeight;
    
    int index = 0;
    for (NSMutableDictionary *photoDic in photos) {
        if (photoDic[@"value"] && ![photoDic[@"value"] isEqualToString:@""]) {
            CustomImageView *coverImageView = [[CustomImageView alloc] initWithFrame:(CGRect){imageViewX, imageViewY, imageViewWidth, imageViewWidth}];
            [coverImageView setCornerRadius:2];
            [coverImageView setImageWithURL:[photoDic[@"value"] firstStringBySeparatedString:@"|"] placeholderImage:[UIImage imageNamed:@"uploadDefault.png"]];
            [_containerView addSubview:coverImageView];
            
            SearchTipLabel *roomlabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){imageViewX, labelY, imageViewWidth, labelHeight}];
            [roomlabel setText:photoDic[@"key"]];
            [roomlabel setFont:[UIFont room107FontTwo]];
            [roomlabel setTextColor:[UIColor room107GrayColorD]];
            [_containerView addSubview:roomlabel];
            
            index++;
            imageViewX += imageViewWidth + spacingX;
        }
    }
}

@end
