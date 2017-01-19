//
//  MapPositionTableViewCell.m
//  room107
//
//  Created by ningxia on 15/11/26.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "MapPositionTableViewCell.h"
#import "ThirteenTemplateView.h"
#import "CustomImageView.h"

@interface MapPositionTableViewCell()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic) CustomImageView *mapPositonImageView;
@property (nonatomic) CustomImageView *annotationImageView;

@end

@implementation MapPositionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView setBackgroundColor:[UIColor room107GrayColorA]];
        CGFloat originX = 11;
        CGFloat originY = 11;
        CGRect frame = [self cellFrame];
        frame.origin.y = originY;
        frame.size.height -= originY;
        _containerView = [[UIView alloc] initWithFrame:frame];
        [_containerView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_containerView];
        
        ThirteenTemplateView *titleView = [[ThirteenTemplateView alloc] initWithFrame:(CGRect){0, 0, frame.size.width, 36} andTemplateDataDictionary:@{@"image":@"trim.png", @"text":lang(@"Location")}];
        [_containerView addSubview:titleView];
        
        frame.origin.x = originX;
        frame.origin.y = originY + CGRectGetHeight(titleView.bounds);
        frame.size = [CommonFuncs suiteViewOtherCellSize];
        _mapPositonImageView = [[CustomImageView alloc] initWithFrame:frame];
        [_containerView addSubview:_mapPositonImageView];
        
        CGFloat width = 33;
        _annotationImageView = [[CustomImageView alloc] initWithFrame:(CGRect){(CGRectGetWidth(_mapPositonImageView.bounds) - width) / 2, (CGRectGetHeight(_mapPositonImageView.bounds) - width) / 2, width, width}];
        _annotationImageView.image = [UIImage makeImageFromText:@"\ue60e" font:[UIFont fontWithName:fontIconName size:33] color:[UIColor room107GreenColor]];
        [_mapPositonImageView addSubview:_annotationImageView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [CommonFuncs suiteViewOtherCellSize].height + 64);
}

- (void)setMapPositionWithURL:(NSString *)URLString {
    self.contentView.hidden = URLString ? [URLString isEqualToString:@""] ? YES : NO : YES;
    _annotationImageView.hidden = YES;
    _mapPositonImageView.contentMode = UIViewContentModeCenter ;
    WEAK_SELF weakSelf = self;
    [self.mapPositonImageView setImageWithURL:URLString placeholderImage:[UIImage imageNamed:@"imageLoading"] withCompletionHandler:^(UIImage *image) {
        if (image) {
            weakSelf.annotationImageView.hidden = NO;
            weakSelf.mapPositonImageView.contentMode = UIViewContentModeScaleToFill ;
        }
    }];
}

@end
