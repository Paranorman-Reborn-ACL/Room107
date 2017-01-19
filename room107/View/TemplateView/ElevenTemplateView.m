//
//  ElevenTemplateView.m
//  room107
//
//  Created by 107间 on 16/4/12.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "ElevenTemplateView.h"
#import "CustomImageView.h"
#import "UIImageView+WebCache.h"

@interface ElevenTemplateView()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) CustomImageView *imageView;
@property (nonatomic, strong) UILabel *subTextLabel;
@property (nonatomic, assign) CGFloat templateViewWidth;
@property (nonatomic, assign) CGFloat templateViewHeight;

@end

@implementation ElevenTemplateView

- (instancetype)initWithText:(NSString *)text andImageUrl:(NSString *)imageUrl andSubText:(NSString *)subText andViewWidth:(CGFloat)viewWidth{
    self = [super init];
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    
    [self setBackgroundColor:[UIColor whiteColor]];
    if (self) {
        CGFloat originX = 11;
        CGFloat originY = 11;
        CGFloat space = 11;
        CGFloat elementWidth = viewWidth - 2 * originX;
        
        if (text && ![text isEqualToString:@""]) {
            CGRect contentRect = [text boundingRectWithSize:CGSizeMake(viewWidth, 38.5) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107SystemFontThree]} context:nil];
            self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, elementWidth, contentRect.size.height)];
            [_textLabel setNumberOfLines:0];
            [_textLabel setFont:[UIFont room107SystemFontThree]];
            [_textLabel setText:text];

            [self addSubview:_textLabel];
            
            originY = CGRectGetMaxY(_textLabel.frame) + space;
            _templateViewHeight = CGRectGetMaxY(_textLabel.frame);
        }
        
        if (imageUrl && ![imageUrl isEqualToString:@""]) {
            self.imageView = [[CustomImageView alloc] init];
            [_imageView setImageWithURL:imageUrl];
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            UIImage *image = [UIImage imageWithData:data];
            [_imageView setFrame:CGRectMake(originX, originY, elementWidth, elementWidth * image.size.height / image.size.width)];
            [self addSubview:_imageView];
            
            originY = CGRectGetMaxY(_imageView.frame) + space;
            _templateViewHeight = CGRectGetMaxY(_imageView.frame);
        }
        
        if (subText && ![subText isEqualToString:@""]) {
            CGRect contentRect = [subText boundingRectWithSize:CGSizeMake(viewWidth, 43) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107SystemFontOne]} context:nil];
            self.subTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, elementWidth, contentRect.size.height)];
            [_subTextLabel setNumberOfLines:0];
            [_subTextLabel setFont:[UIFont room107SystemFontOne]];
            [_subTextLabel setTextColor:[UIColor room107GrayColorC]];
            [_subTextLabel setText:subText];
            [self addSubview:_subTextLabel];
            _templateViewHeight = CGRectGetMaxY(_subTextLabel.frame);
        }
        
    }
    return self;
}

- (CGFloat)elevenTemplateViewHeight {
    return _templateViewHeight + 11;
}

@end
