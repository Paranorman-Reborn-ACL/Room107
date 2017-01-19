//
//  OtherRoomsCollectionViewCell.m
//  room107
//
//  Created by ningxia on 15/6/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "OtherRoomsCollectionViewCell.h"
#import "CustomLabel.h"
#import "CustomImageView.h"
#import "NSString+AttributedString.h"
#import "Room107GradientLayer.h"

@interface OtherRoomsCollectionViewCell ()

@property (nonatomic, strong) CustomImageView *roomImageView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CustomLabel *areaLabel;
@property (nonatomic, strong) CustomLabel *orientationLabel;
@property (nonatomic, strong) CustomLabel *nameLabel;
@property (nonatomic, strong) CustomLabel *priceLabel;

@end

@implementation OtherRoomsCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        if (!_roomImageView) {
            _roomImageView = [[CustomImageView alloc] initWithFrame:self.bounds];
            [_roomImageView setCornerRadius:10.0f];
            [self addSubview:_roomImageView];
            CGRect frame = _roomImageView.frame;
            frame.origin.x = 0;
            frame.origin.y = frame.size.height / 2;
            frame.size.height -= frame.origin.y;
            Room107GradientLayer *gradientLayer = [[Room107GradientLayer alloc] initWithFrame:frame andStartAlpha:0.0 andEndAlpha:1.0];
            [_roomImageView.layer insertSublayer:gradientLayer atIndex:0];
            
            CGFloat containerViewHeight = CGRectGetHeight(self.bounds)  * 3 / 7;
            _containerView = [[UIView alloc] initWithFrame:(CGRect){0, CGRectGetHeight(self.bounds) - containerViewHeight, CGRectGetWidth(self.bounds), containerViewHeight}];
            [_containerView setBackgroundColor:[UIColor clearColor]];
            [self addSubview:_containerView];

            CGFloat originX = 5;
            CGFloat originY = 0;
            CGFloat fontSize = 14.0f;
            CGFloat leftWidth = CGRectGetWidth(self.bounds) * 2 / 5;
            CGFloat rightWidth = CGRectGetWidth(self.bounds) - leftWidth;
            _nameLabel = [[CustomLabel alloc] initWithFrame:(CGRect){leftWidth, originY, rightWidth - originX, fontSize + 2}];
            [_nameLabel setFontSize:fontSize];
            [_containerView addSubview:_nameLabel];
            
            fontSize = 12.0f;
            _areaLabel = [[CustomLabel alloc] initWithFrame:(CGRect){originX, originY + 5, leftWidth - originX, fontSize + 2}];
            [_areaLabel setTextAlignment:NSTextAlignmentLeft];
            [_areaLabel setFontSize:fontSize];
            [_containerView addSubview:_areaLabel];
            originY += CGRectGetHeight(_areaLabel.bounds);
            
            _priceLabel = [[CustomLabel alloc] initWithFrame:(CGRect){leftWidth, originY, rightWidth - originX, 60}];
            [_containerView addSubview:_priceLabel];
            
            UIView *splitLineView = [[UIView alloc] initWithFrame:(CGRect){leftWidth - 0.5, 5, 1, CGRectGetHeight(_containerView.bounds) - 5 * 2}];
            [splitLineView setBackgroundColor:[UIColor lightGrayColor]];
            [_containerView addSubview:splitLineView];
            
            originY += 5;
            _orientationLabel = [[CustomLabel alloc] initWithFrame:(CGRect){originX, originY, leftWidth - originX, fontSize + 2}];
            [_orientationLabel setTextAlignment:NSTextAlignmentLeft];
            [_orientationLabel setFontSize:fontSize];
            [_containerView addSubview:_orientationLabel];
        }
    }
    
    return self;
}

- (void)setRoomImageURL:(NSString *)url {
    [_roomImageView setImageWithURL:url];
}

- (void)setName:(NSString *)name {
    [_nameLabel setText:name];
}

- (void)setArea:(NSNumber *)area {
    [_areaLabel setText:[NSString stringWithFormat:@"%@m²", area]];
}

- (void)setPrice:(NSNumber *)price {
    if (price) {
        CGFloat unitFontSize = 8.0f;
        CGFloat priceFontSize = 20.0f;
        
        NSMutableAttributedString *attributedString = [NSString attributedStringFromPriceStr:[NSString stringWithFormat:@"￥%@", price] andPriceFont:[UIFont systemFontOfSize:priceFontSize] andPriceColor:[UIColor whiteColor] andUnitFont:[UIFont systemFontOfSize:unitFontSize] andUnitColor:[UIColor whiteColor]];
        [_priceLabel setFrame:(CGRect){_priceLabel.frame.origin, CGRectGetWidth(_priceLabel.bounds), attributedString.size.height}];
        [_priceLabel setAttributedText:attributedString];
    }
}

- (void)setOrientation:(NSString *)orientation {
    if (orientation && ![orientation isKindOfClass:[NSNull class]]) {
        [_orientationLabel setText:[NSString stringWithFormat:@"%@%@", [lang(@"Orientation") substringToIndex:1], orientation]];
    }
}

@end
