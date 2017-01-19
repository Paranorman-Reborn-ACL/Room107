//
//  PopImageAdsView.m
//  room107
//
//  Created by ningxia on 16/3/9.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "PopImageAdsView.h"
#import "CustomButton.h"

@interface PopImageAdsView ()

@property (nonatomic, strong) NSString *htmlURL;
@property (nonatomic, strong) void (^adsImageClickHandlerBlock)(NSString *htmlURL);

@end

@implementation PopImageAdsView

- (instancetype)initWithAdsImageURL:(NSString *)imageURL andHtmlURL:(NSString *)htmlURL {
    CGRect frame = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:frame];
    if (self) {
        _htmlURL = htmlURL;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelf)];
        [self addGestureRecognizer:tapGesture];

        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        [[App window] addSubview:self]; //铺满整个屏幕
        
        CGFloat originX = 11;
        CGFloat originY = statusBarHeight + 11;
        CGFloat buttonWidth = 22;
        UIButton *closeButton = [[UIButton alloc] initWithFrame:(CGRect){CGRectGetWidth(frame) - originX - buttonWidth, originY, buttonWidth, buttonWidth}];
        [closeButton setImage:[UIImage makeImageFromText:@"\ue66c" font:[UIFont room107FontFour] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        buttonWidth = CGRectGetWidth(frame) * 0.7;
        CGFloat buttonHeight = buttonWidth * 1.5;
        CustomButton *imageAdsButton = [[CustomButton alloc] initWithFrame:(CGRect){self.center.x - buttonWidth / 2, self.center.y - buttonHeight / 2, buttonWidth, buttonHeight}];
        imageAdsButton.layer.cornerRadius = 8.0f;
        imageAdsButton.layer.masksToBounds = YES;
        [imageAdsButton setBackgroundColor:[UIColor room107GrayColorB]];
        WEAK(imageAdsButton) weakImageAdsButton = imageAdsButton;
        [imageAdsButton setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"imageLoading.png"] withCompletionHandler:^(UIImage *image) {
            //setBackgroundImage较之setImage可以撑满整个Button
            [weakImageAdsButton setBackgroundImage:image forState:UIControlStateNormal];
        }];
        [imageAdsButton addTarget:self action:@selector(imageAdsButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:imageAdsButton];
    }
    
    return self;
}

- (void)hideSelf {
    [self removeFromSuperview];
}

- (IBAction)closeButtonDidClick:(id)sender {
    [self hideSelf];
}

- (IBAction)imageAdsButtonDidClick:(id)sender {
    [self hideSelf];
    
    if (_adsImageClickHandlerBlock) {
        _adsImageClickHandlerBlock(_htmlURL);
    }
}

- (void)setAdsImageDidClickHandler:(void (^)(NSString *))handler {
    _adsImageClickHandlerBlock = handler;
}

@end
