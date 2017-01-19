//
//  RentInfoItemView.m
//  room107
//
//  Created by ningxia on 15/8/5.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RentInfoItemView.h"
#import "SearchTipLabel.h"

@implementation RentInfoItemView

- (id)initWithFrame:(CGRect)frame viewType:(RentInfoItemViewType)type content:(NSString *)content {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat originX = 0.0f;
        CGFloat titleWidth = 80.0f;
        CGFloat contentHeight = CGRectGetHeight(self.bounds)  * 2 / 3;
        CGFloat originY = (CGRectGetHeight(self.bounds) - contentHeight) / 2;
        CGFloat titleHeight = contentHeight / 2;
        SearchTipLabel *titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY + (contentHeight - titleHeight) / 2, titleWidth, titleHeight}];
        NSString *title = @"";
        switch (type) {
            case RentInfoItemViewTypeCheckInDate:
                title = lang(@"CheckInDate");
                break;
            case RentInfoItemViewTypeCheckOutDate:
                title = lang(@"CheckOutDate");
                break;
            case RentInfoItemViewTypePaymentMethod:
                title = lang(@"PaymentMethod");
                break;
            case RentInfoItemViewTypeContractMoney:
                title = lang(@"ContractMoney");
                break;
            case RentInfoItemViewTypePayableMonthly:
                title = lang(@"PayableMonthly");
                break;
            case RentInfoItemViewTypeSigningRentalGuarantee:
                title = lang(@"SigningRentalGuarantee");
                break;
            default:
                break;
        }
        [titleLabel setText:title];
        [self addSubview:titleLabel];
        
        originX += titleWidth;
        SearchTipLabel *contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth(self.bounds) - originX, contentHeight}];
        [contentLabel setText:content];
        [self addSubview:contentLabel];
    }
    
    return self;
}

@end
