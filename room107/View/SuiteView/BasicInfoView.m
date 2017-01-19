//
//  BasicInfoView.m
//  room107
//
//  Created by ningxia on 15/6/25.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "BasicInfoView.h"
#import "IconLabel.h"
#import "SearchTipLabel.h"

@interface BasicInfoView ()

@property (nonatomic, strong) IconLabel *iconLabel;
@property (nonatomic, strong) SearchTipLabel *contentLabel;

@end

@implementation BasicInfoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];
    
    if (self) {
        if (!_iconLabel) {
            CGFloat iconWidth = 40.0f;
            _iconLabel = [[IconLabel alloc] initWithFrame:(CGRect){10, 0, iconWidth, CGRectGetHeight(self.bounds)}];
            [_iconLabel setTextColor:[UIColor room107GrayColorD]];
            [self addSubview:_iconLabel];
            
            CGFloat labelX = _iconLabel.frame.origin.x + CGRectGetWidth(_iconLabel.bounds);
            _contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){labelX, 0, CGRectGetWidth(self.bounds) - labelX, CGRectGetHeight(self.bounds)}];
            [_contentLabel setTextColor:[UIColor room107GrayColorD]];
            [self addSubview:_contentLabel];
        }
    }
    
    return self;
}

- (void)setContent:(NSString *)content withType:(BasicInfoViewType)type {
    NSString *iconString = @"";
    switch (type) {
        case BasicInfoViewTypeName:
            iconString = @"\ue608";
            break;
        case BasicInfoViewTypeArea:
            iconString = @"\ue609";
            break;
        case BasicInfoViewTypeFloor:
            iconString = @"\ue60a";
            break;
        case BasicInfoViewTypeOrientation:
            iconString = @"\ue60b";
            break;
        default:
            break;
    }
    
    [_iconLabel setText:iconString];
    [_contentLabel setText:content];
}

@end
