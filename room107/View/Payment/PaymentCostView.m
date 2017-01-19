//
//  PaymentCostView.m
//  room107
//
//  Created by ningxia on 16/3/30.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "PaymentCostView.h"
#import "SearchTipLabel.h"

@interface PaymentCostView ()

@property (nonatomic, strong) SearchTipLabel *paymentCostLabel;

@end

@implementation PaymentCostView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        CGFloat iconLabelWidth = 44;
        CGFloat spaceX = 11;
        CGFloat paymentCostLabelWidth = 190;
        CGFloat originX = (CGRectGetWidth(frame) - iconLabelWidth - spaceX - paymentCostLabelWidth) / 2;
        SearchTipLabel *iconLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0, iconLabelWidth, CGRectGetHeight(frame)}];
        [iconLabel setFont:[UIFont fontWithName:fontIconName size:iconLabelWidth]];
        [iconLabel setText:@"\ue640"];
        [self addSubview:iconLabel];
        
        originX += iconLabelWidth + spaceX;
        _paymentCostLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0, paymentCostLabelWidth, CGRectGetHeight(frame)}];
        [self addSubview:_paymentCostLabel];
    }
    
    return self;
}

- (void)setPaymentInfo:(NSString *)payment andDate:(NSString *)date {
    NSString *content = [[payment stringByAppendingString:@"\n"] stringByAppendingFormat:lang(@"MustCompletePaymentBefore%@"), [TimeUtil friendlyDateTimeFromDateTime:date withFormat:@"%Y/%m/%d"]];
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:content];
    NSArray *components = [content componentsSeparatedByString:@"\n"];
    NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor room107GreenColor], NSFontAttributeName:[UIFont room107SystemFontFive]};
    [attributedContent addAttributes:attrs range:NSMakeRange(0, [(NSString *)components[0] length])];
    attrs = @{NSForegroundColorAttributeName:[UIColor room107GrayColorD], NSFontAttributeName:[UIFont room107SystemFontOne]};
    [attributedContent addAttributes:attrs range:NSMakeRange([(NSString *)components[0] length] + 1, [(NSString *)components[1] length])];
    [_paymentCostLabel setAttributedText:attributedContent];
}

@end
