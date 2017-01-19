//
//  FacilityCollectionViewCell.m
//  room107
//
//  Created by ningxia on 15/6/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "FacilityCollectionViewCell.h"
#import "CustomLabel.h"

@interface FacilityCollectionViewCell ()

@property (nonatomic, strong) CustomLabel *iconLabel;
@property (nonatomic, strong) CustomLabel *contentLabel;

@end

@implementation FacilityCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];
    
    if (self) {
        CGFloat iconWidth = 23.0f;
        
        _iconLabel = [[CustomLabel alloc] initWithFrame:(CGRect){(CGRectGetWidth(self.bounds) - iconWidth) / 2, 0, iconWidth, iconWidth}];
        [_iconLabel setTextAlignment:NSTextAlignmentCenter];
        [_iconLabel setFont:[UIFont room107FontFour]];
        [self addSubview:_iconLabel];
        
        CGFloat spacingY = 11;
        CGFloat labelY = _iconLabel.frame.origin.y + CGRectGetHeight(_iconLabel.bounds) + spacingY;
        CGFloat labelHeight = 18.0f;
        _contentLabel = [[CustomLabel alloc] initWithFrame:(CGRect){0, labelY, CGRectGetWidth(self.bounds), labelHeight}];
        [_contentLabel setTextAlignment:NSTextAlignmentCenter];
        [_contentLabel setFont:[UIFont room107SystemFontThree]];
        [self addSubview:_contentLabel];
    }
    
    return self;
}

- (void)setIconText:(NSString *)iconText {
    [_iconLabel setText:iconText];
    [_iconLabel setTextColor:[UIColor room107GrayColorB]];
}

- (void)setContent:(NSString *)content {
    [_contentLabel setText:content];
    [_contentLabel setTextColor:[UIColor room107GrayColorB]];
}

- (void)didSelect {
    [_iconLabel setTextColor:[UIColor room107GrayColorD]];
    [_contentLabel setTextColor:[UIColor room107GrayColorD]];
}

@end
