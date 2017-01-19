//
//  CredentialsSelectView.m
//  room107
//
//  Created by ningxia on 15/7/22.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "CredentialsSelectView.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "CircleGreenMarkView.h"
#import "SearchTipLabel.h"
#import "CustomImageView.h"
#import "Room107GradientLayer.h"

@interface CredentialsSelectView ()

@property (nonatomic, strong) CustomButton *credentialsButton;
@property (nonatomic, strong) CustomLabel *tipsLabel;
@property (nonatomic, strong) CustomImageView *exampleUpImageView;
@property (nonatomic, strong) CustomImageView *exampleDownImageView;
@end

@implementation CredentialsSelectView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat originX = 60.0f;
        CGFloat originY = 10.0f;
        CGFloat buttonWidth = 144;
        CGFloat buttonHeight = 90;
     
        _credentialsButton = [[CustomButton alloc] initWithFrame:(CGRect){originX, originY, buttonWidth, buttonHeight}];
        [_credentialsButton.titleLabel setFont:[UIFont room107FontFive]];
        [_credentialsButton setBackgroundColor:[UIColor room107GrayColorC]];
        [_credentialsButton setCornerRadius:8];
        [_credentialsButton setTitle:@"\ue62f" forState:UIControlStateNormal];
        [self addSubview:_credentialsButton];
        [_credentialsButton addTarget:self action:@selector(credentialsButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        originX += CGRectGetWidth(_credentialsButton.bounds);
        originX += 11;
//        originY += 10;
        CircleGreenMarkView *markView = [[CircleGreenMarkView alloc] initWithFrame:(CGRect){originX, originY+1, 10, 10}];
        markView.backgroundColor = [UIColor room107GrayColorC];
        [self addSubview:markView];
        
        CGFloat tipsHeight = CGRectGetHeight(markView.bounds) * 2;
        SearchTipLabel *suchAsLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX + CGRectGetWidth(markView.bounds)+2, originY-5, tipsHeight, tipsHeight}];
        [suchAsLabel setFont:[UIFont room107FontTwo]];
        [suchAsLabel setText:lang(@"SuchAs")];
        [self addSubview:suchAsLabel];
        
        CGFloat labelHeight = 20.0f;
        _tipsLabel = [[CustomLabel alloc] initWithFrame:(CGRect){0, CGRectGetHeight(_credentialsButton.bounds) - labelHeight, CGRectGetWidth(_credentialsButton.bounds), labelHeight}];
        [_tipsLabel setFont:[UIFont room107FontOne]];
        [_tipsLabel setTextAlignment:NSTextAlignmentCenter];
        [_credentialsButton addSubview:_tipsLabel];
        
        CGFloat imageViewWidth = 56.0f;
        CGFloat imageViewHeight = 35.0f;
        CGFloat imageY = CGRectGetMaxY(suchAsLabel.frame);
        _exampleUpImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, imageY, imageViewWidth, imageViewHeight}];
        [_exampleUpImageView setCornerRadius:4];
        [self addSubview:_exampleUpImageView];
        
        imageY = CGRectGetMaxY(_exampleUpImageView.frame) + 5 ;
        _exampleDownImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(originX, imageY, imageViewWidth, imageViewHeight)];
        [_exampleDownImageView setCornerRadius:4];
        [self addSubview:_exampleDownImageView];
    }
    
    return self;
}

- (void)setUpExampleImage:(NSString *)upimageName downExampleImage:(NSString *)downimageName {
    [_exampleUpImageView setImageWithName:upimageName];
    [_exampleDownImageView setImageWithName:downimageName];
}

- (void)setCredentialsSelectTips:(NSString *)tips andCredentialsImage:(UIImage *)image {
    [_tipsLabel setText:tips];
    
    if (image) {
        [_credentialsButton setImage:image forState:UIControlStateNormal];
        CGRect frame = _credentialsButton.frame;
        frame.origin.x = 0;
        frame.origin.y = _credentialsButton.frame.size.height - _tipsLabel.frame.size.height;
        frame.size.height = _tipsLabel.frame.size.height;
        
        Room107GradientLayer *gradientLayer = [[Room107GradientLayer alloc] initWithFrame:frame andStartAlpha:0.5f andEndAlpha:0.5f];
        [_credentialsButton.layer insertSublayer:gradientLayer below:_tipsLabel.layer];
    }
}

- (UIImage *)getCredentialsPhoto {
    return _credentialsButton.imageView.image;
}

- (IBAction)credentialsButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(credentialsButtonDidClick:)]) {
        [self.delegate credentialsButtonDidClick:self];
    }
}

@end
