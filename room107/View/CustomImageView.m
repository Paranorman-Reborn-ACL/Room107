//
//  CustomImageView.m
//  room107
//
//  Created by ningxia on 15/7/3.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "CustomImageView.h"
#import "UIImageView+WebCache.h"

@implementation CustomImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)setImageWithURL:(NSString *)url {
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder {
    if (url) {
        NSRange foundImageView2 = [url rangeOfString:imageView2Thumbnails options:NSCaseInsensitiveSearch];
        NSRange foundImageMogr2 = [url rangeOfString:imageMogr2 options:NSCaseInsensitiveSearch];
        NSRange foundImageView2ForPC = [url rangeOfString:imageView2ThumbnailsForPC options:NSCaseInsensitiveSearch];
        if(foundImageView2.length == 0 && foundImageMogr2.length == 0 && foundImageView2ForPC.length == 0) {
            //高度固定为suiteImageView高度的两倍，宽度等比缩小
            url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%.f", imageView2Thumbnails, ([CommonFuncs indexOfDeviceScreen] == 3 ? 3 : 2) * CGRectGetHeight(self.bounds)]];
        }
        
        [self sd_setImageWithURL:[NSURL URLWithString:url ? url :@""] placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageHighPriority];
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
    if (url) {
        NSRange foundImageView2 = [url rangeOfString:imageView2Thumbnails options:NSCaseInsensitiveSearch];
        NSRange foundImageMogr2 = [url rangeOfString:imageMogr2 options:NSCaseInsensitiveSearch];
        NSRange foundImageView2ForPC = [url rangeOfString:imageView2ThumbnailsForPC options:NSCaseInsensitiveSearch];
        if(foundImageView2.length == 0 && foundImageMogr2.length == 0 && foundImageView2ForPC.length == 0) {
            //高度固定为suiteImageView高度的两倍，宽度等比缩小
            url = [url stringByAppendingString:[NSString stringWithFormat:@"%@%.f", imageView2Thumbnails, ([CommonFuncs indexOfDeviceScreen] == 3 ? 3 : 2) * CGRectGetHeight(self.bounds)]];
        }
        
        [self sd_setImageWithURL:[NSURL URLWithString:url ? url : @""] placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error && image && completionHandler) {
                completionHandler(image);
            }
        }];
    }
}

- (void)setImageWithName:(NSString *)name {
    [self setImage:[UIImage imageNamed:name]];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)setBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = borderColor.CGColor;
    self.layer.masksToBounds = YES;
}

@end
