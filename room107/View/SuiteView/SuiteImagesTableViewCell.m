//
//  SuiteImagesTableViewCell.m
//  room107
//
//  Created by Naitong Yu on 15/8/1.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SuiteImagesTableViewCell.h"
#import "UIColor+Room107.h"
#import "CustomImageView.h"

@interface SuiteImagesTableViewCell()

@property (nonatomic) CustomImageView *suiteImageView;

@property (nonatomic) UIView *seperatorView;

@end

@implementation SuiteImagesTableViewCell

- (void)setSuiteImage:(UIImage *)image {
    self.suiteImageView.image = image;
}

- (void)setSuiteImageWithURL:(NSString *)URLString {
    _suiteImageView.contentMode = UIViewContentModeCenter ;
    WEAK(_suiteImageView) weakImageView = _suiteImageView;
    [self.suiteImageView setImageWithURL:URLString placeholderImage:[UIImage imageNamed:@"imageLoading"] withCompletionHandler:^(UIImage *image) {
        if (image) {
            weakImageView.contentMode = UIViewContentModeScaleToFill ;
        }
    }];
}

- (void)awakeFromNib {
    [self setup];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    if (!_suiteImageView) {
        _suiteImageView = [[CustomImageView alloc] init];
        _suiteImageView.contentMode = UIViewContentModeCenter;
        _suiteImageView.clipsToBounds = YES;
        _suiteImageView.backgroundColor = [UIColor room107GrayColorB];
        [self.contentView addSubview:_suiteImageView];
    }
    if (!_seperatorView) {
        _seperatorView = [[UIView alloc] init];
        _seperatorView.backgroundColor = [UIColor room107ViewBackgroundColor];
        [self.contentView addSubview:_seperatorView];
    }
}

- (void)layoutSubviews {
    CGRect rect = self.contentView.bounds;
    
    _suiteImageView.frame = CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect) - 3);
    _seperatorView.frame = CGRectMake(0, CGRectGetHeight(rect)-3, CGRectGetWidth(rect), 3);
}

@end
