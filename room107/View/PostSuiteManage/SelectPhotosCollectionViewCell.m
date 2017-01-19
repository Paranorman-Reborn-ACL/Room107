//
//  SelectPhotosCollectionViewCell.m
//  room107
//
//  Created by ningxia on 16/4/27.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SelectPhotosCollectionViewCell.h"
#import "CustomImageView.h"

@interface SelectPhotosCollectionViewCell ()

@property (nonatomic, strong) CustomImageView *customImageView;
@property (nonatomic, strong) CustomImageView *checkedImageView;

@end

@implementation SelectPhotosCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor room107GrayColorB]];
        frame.origin = CGPointMake(0, 0);
        _customImageView = [[CustomImageView alloc] initWithFrame:frame];
        [self addSubview:_customImageView];
        
        CGFloat imageWidth = 22;
        CGFloat imageHeight = 22;
        CGFloat spaceX = 3;
        CGFloat spaceY = 3;
        _checkedImageView = [[CustomImageView alloc] initWithFrame:(CGRect){CGRectGetWidth(frame) - spaceX - imageWidth, CGRectGetHeight(frame) - spaceY - imageHeight, imageWidth, imageHeight}];
        [_checkedImageView setImageWithName:@"AssetsPickerChecked.png"];
        [self addSubview:_checkedImageView];
    }
    
    return self;
}

- (void)setPhotoDataDictionary:(NSDictionary *)dataDic {
    [_customImageView setContentMode:UIViewContentModeCenter]; //图片按实际大小居中显示
    if (dataDic[@"imageUrl"] && ![dataDic[@"imageUrl"] isEqualToString:@""]) {
        WEAK_SELF weakSelf = self;
        [_customImageView setImageWithURL:dataDic[@"imageUrl"] placeholderImage:[UIImage imageNamed:@"imageLoading"] withCompletionHandler:^(UIImage *image) {
            if (image) {
                weakSelf.customImageView.contentMode = UIViewContentModeScaleAspectFill; //图片撑满显示
            }
        }];
    } else {
        [_customImageView setImageWithName:@"imageLoading"];
    }
    
    _checkedImageView.hidden = dataDic[@"selected"] ? [dataDic[@"selected"] boolValue] ? NO : YES : YES;
}

@end
