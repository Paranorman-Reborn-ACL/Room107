//
//  SuiteFacilityCollectionViewCell.m
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SuiteFacilityCollectionViewCell.h"
#import "CustomLabel.h"

@interface SuiteFacilityCollectionViewCell ()

@property (nonatomic, strong) CustomLabel *iconLabel;
@property (nonatomic, strong) CustomLabel *contentLabel;
@property (nonatomic, strong) NSArray *facilityViewTypes;
@property (nonatomic) BOOL didSelected;

@end

@implementation SuiteFacilityCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        self.layer.cornerRadius = 10.0f;
        self.layer.masksToBounds = YES;
        
        if (!_iconLabel) {
            CGFloat iconWidth = 25.0f;
            CGFloat labelHeight = 18.0f;
            CGFloat spacingY = (CGRectGetHeight(self.bounds) - iconWidth - labelHeight) / 3;
            _iconLabel = [[CustomLabel alloc] initWithFrame:(CGRect){(CGRectGetWidth(self.bounds) - iconWidth) / 2, spacingY, iconWidth, iconWidth}];
            [_iconLabel setTextAlignment:NSTextAlignmentCenter];
            [_iconLabel setTextColor:[UIColor room107GrayColorC]];
            [_iconLabel setFont:[UIFont room107FontFour]];
            [self addSubview:_iconLabel];
            
            CGFloat labelY = _iconLabel.frame.origin.y + CGRectGetHeight(_iconLabel.bounds) + spacingY;
            _contentLabel = [[CustomLabel alloc] initWithFrame:(CGRect){0, labelY, CGRectGetWidth(self.bounds), labelHeight}];
            [_contentLabel setTextAlignment:NSTextAlignmentCenter];
            [_contentLabel setTextColor:[UIColor room107GrayColorC]];
            [_contentLabel setFont:[UIFont room107FontThree]];
            [self addSubview:_contentLabel];
        }
        
        _didSelected = NO;
    }
    
    return self;
}

- (void)setContent:(NSDictionary *)content {
    
    [_iconLabel setText:content[@"icon"]];
    [_contentLabel setText:content[@"content"]];
}

- (void)didSelect {
    _didSelected = !_didSelected;
    if (_didSelected) {
        [self setBackgroundColor:[UIColor room107GreenColor]];
        [_iconLabel setTextColor:[UIColor whiteColor]];
        [_contentLabel setTextColor:[UIColor whiteColor]];
    } else {
        [self setBackgroundColor:[UIColor whiteColor]];
        [_iconLabel setTextColor:[UIColor room107GrayColorC]];
        [_contentLabel setTextColor:[UIColor room107GrayColorC]];
    }
}

- (BOOL)isSelected {
    return _didSelected;
}

@end
