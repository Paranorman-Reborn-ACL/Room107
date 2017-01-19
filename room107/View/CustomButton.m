//
//  CustomButton.m
//  room107
//
//  Created by ningxia on 15/6/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "CustomButton.h"
#import "UIButton+WebCache.h"

@implementation CustomButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setTitleColor:[UIColor room107GreenColor] forState:UIControlStateNormal];
        [self setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
    }
    
    return self;
}

- (void)setImageWithName:(NSString *)name {
    [self setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
}

- (void)setImageWithURL:(NSString *)url {
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder {
    if (url) {
        NSRange foundImageView2 = [url rangeOfString:imageView2Thumbnails options:NSCaseInsensitiveSearch];
        NSRange foundImageMogr2 = [url rangeOfString:imageMogr2 options:NSCaseInsensitiveSearch];
        if(foundImageView2.length == 0 && foundImageMogr2.length == 0) {
            //高度固定为suiteImageView高度的两倍，宽度等比缩小
            url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%.f", imageView2Thumbnails, ([CommonFuncs indexOfDeviceScreen] == 3 ? 3 : 2) * CGRectGetHeight(self.bounds)]];
        }
        
        [self sd_setImageWithURL:[NSURL URLWithString:url ? url :@""] forState:UIControlStateNormal placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageHighPriority];
    }
}

- (void)setImageWithURL:(NSString *)url withCompletionHandler:(void(^)(UIImage *image))completionHandler {
    [self setImageWithURL:url placeholderImage:nil withCompletionHandler:^(UIImage *image) {
        if (image && completionHandler) {
            completionHandler(image);
        }
    }];
}

- (void)setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder withCompletionHandler:(void(^)(UIImage *image))completionHandler {
    [self setImage:placeholder forState:UIControlStateNormal];
    if (url) {
        NSRange foundImageView2 = [url rangeOfString:imageView2Thumbnails options:NSCaseInsensitiveSearch];
        NSRange foundImageMogr2 = [url rangeOfString:imageMogr2 options:NSCaseInsensitiveSearch];
        if(foundImageView2.length == 0 && foundImageMogr2.length == 0) {
            //高度固定为suiteImageView高度的两倍，宽度等比缩小
            url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%.f", imageView2Thumbnails, ([CommonFuncs indexOfDeviceScreen] == 3 ? 3 : 2) * CGRectGetHeight(self.bounds)]];
        }
        
        [self sd_setImageWithURL:[NSURL URLWithString:url ? url :@""] forState:UIControlStateNormal placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageHighPriority  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error && image && completionHandler) {
                completionHandler(image);
            }
        }];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)setBackgroundColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    [self setBackgroundColor:[UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0f]];
}

- (void)setFontSize:(CGFloat)size {
    [self.titleLabel setFont:[UIFont fontWithName:fontIconName size:size]];
}

@end
