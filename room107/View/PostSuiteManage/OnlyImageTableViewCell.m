//
//  OnlyImageTableViewCell.m
//  room107
//
//  Created by ningxia on 15/11/20.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "OnlyImageTableViewCell.h"
#import "CustomImageView.h"

@interface OnlyImageTableViewCell ()

@property (nonatomic, strong) CustomImageView *urlImageView;
@property (nonatomic, strong) UIView *shadowView;

@end

@implementation OnlyImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _urlImageView = [[CustomImageView alloc] init];
        _urlImageView.contentMode = UIViewContentModeCenter; //方便显示placeholderImage
        [_urlImageView setBackgroundColor:[UIColor whiteColor]];
        CGFloat cornerRadius = [CommonFuncs cornerRadius];
        _urlImageView.layer.cornerRadius = cornerRadius;
        _urlImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_urlImageView];
        
        //添加阴影效果
        _shadowView = [[UIView alloc] init];
        _shadowView.layer.cornerRadius = cornerRadius;
        [_shadowView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_shadowView];
        [self.contentView sendSubviewToBack:_shadowView];
        _shadowView.layer.shadowColor = [CommonFuncs shadowColor].CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake([CommonFuncs shadowRadius], [CommonFuncs shadowRadius]);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3)
        _shadowView.layer.shadowOpacity = [CommonFuncs shadowOpacity];//阴影透明度，默认0
        _shadowView.layer.shadowRadius = [CommonFuncs shadowRadius];//阴影半径，默认3
    }
    
    return self;
}

- (void)setImageURL:(NSString *)imageURL andHeight:(CGFloat)height {
    CGFloat originX = 11.0f;
    [_urlImageView setFrame:CGRectMake(originX, 10, [[UIScreen mainScreen] bounds].size.width - 2 * originX, height)];
    WEAK(_urlImageView) weakImageView = _urlImageView;
    [_urlImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"imageLoading"] withCompletionHandler:^(UIImage *image) {
        if (image) {
            weakImageView.contentMode = UIViewContentModeScaleToFill ;
        }
    }];
    [_shadowView setFrame:_urlImageView.frame];
}

@end
