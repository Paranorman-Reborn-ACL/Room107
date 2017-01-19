//
//  BalanceAccountView.m
//  room107
//
//  Created by Naitong Yu on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "BalanceAccountView.h"
#import "BalanceAccountItemView.h"

@interface BalanceAccountView ()

@property (nonatomic) NSArray *categories;

@property (nonatomic) BOOL payMoney;

@property (nonatomic) UILabel *typeLabel;

@property (nonatomic) NSMutableArray *balanceAccountItems;

@property (nonatomic) UIView *separatorLine;

@property (nonatomic) UILabel *sumTextLabel;
@property (nonatomic) UILabel *sumMoneyLabel;

@property (nonatomic) UILabel *dueTimeLabel;

@property (nonatomic) CGFloat contentHeight;

@end

@implementation BalanceAccountView

- (instancetype)initWithFrame:(CGRect)frame payMoney:(BOOL)payMoney categories:(NSArray *)categories andDueTime:(NSDate *)dueTime {
    self = [super initWithFrame:frame];
    if (self) {
        self.payMoney = payMoney;
        self.categories = categories;
        
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.text = self.payMoney ? lang(@"PayMoneyBalanceAccount") : lang(@"GetMoneyBalanceAccount");
        _typeLabel.textColor = [UIColor room107GrayColorC];
        [self addSubview:_typeLabel];
        
        NSInteger sum = 0;
        _balanceAccountItems = [[NSMutableArray alloc] initWithCapacity:categories.count];
        for (NSDictionary *category in categories) {
            NSString *categoryName = category[@"description"];
            NSArray *details = category[@"details"];
            BalanceAccountItemView *balanceAccountItemView = [[BalanceAccountItemView alloc] initWithFrame:CGRectZero categoryName:categoryName details:details collapse:NO];
            sum += balanceAccountItemView.totalMoney;
            [self addSubview:balanceAccountItemView];
            [self.balanceAccountItems addObject:balanceAccountItemView];
        }
        
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = [UIColor room107GrayColorC];
        [self addSubview:_separatorLine];
        
        _sumTextLabel = [[UILabel alloc] init];
        _sumTextLabel.text = lang(@"Total");
        _sumTextLabel.textColor = [UIColor room107GreenColor];
        [self addSubview:_sumTextLabel];
        
        _sumMoneyLabel = [[UILabel alloc] init];
        _sumMoneyLabel.text = [NSString stringWithFormat:@"¥%ld", (long)sum];
        _sumMoneyLabel.textColor = [UIColor room107GreenColor];
        [self addSubview:_sumMoneyLabel];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:dueTime];
        NSString *dateString = [NSString stringWithFormat:@"%ld/%ld", (long)components.month, (long)components.day];
        _dueTimeLabel = [[UILabel alloc] init];
        _dueTimeLabel.textColor = [UIColor room107GreenColor];
        _dueTimeLabel.text = payMoney ? [NSString stringWithFormat:lang(@"MustCompletePaymentBefore%@"), dateString]
                                      : [NSString stringWithFormat:lang(@"EstimateMoneyArriveBefore%@"), dateString];
        [self addSubview:_dueTimeLabel];
        
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat margin = 20;
    CGFloat rowHeight = 24;
    
    _typeLabel.font = [UIFont systemFontOfSize:rowHeight / 2];
    [_typeLabel sizeToFit];
    _typeLabel.frame = CGRectMake(margin, 0, CGRectGetWidth(_typeLabel.frame), rowHeight);
    
    CGFloat originY = 24;
    for (int i = 0; i < self.categories.count; i++) {
        NSDictionary *category = self.categories[i];
        NSArray *details = category[@"details"];
        BalanceAccountItemView *balanceAccountItemView = self.balanceAccountItems[i];
        balanceAccountItemView.frame = CGRectMake(0, originY, CGRectGetWidth(self.bounds), (details.count + 1) * rowHeight);
        originY += (details.count + 1) * rowHeight;
    }
    
    _separatorLine.frame = CGRectMake(20, originY, CGRectGetWidth(self.bounds) - 2*20, 1);
    originY++;
    
    _sumTextLabel.font = [UIFont systemFontOfSize:rowHeight * 2 / 3];
    [_sumTextLabel sizeToFit];
    _sumTextLabel.frame = CGRectMake(60, originY + rowHeight, CGRectGetWidth(_sumTextLabel.frame), rowHeight);
    
    _sumMoneyLabel.font = [UIFont systemFontOfSize:rowHeight * 4 / 3];
    [_sumMoneyLabel sizeToFit];
    _sumMoneyLabel.frame = CGRectMake(CGRectGetWidth(self.bounds) / 2 + 60, originY, CGRectGetWidth(_sumMoneyLabel.frame), 2 * rowHeight);
    originY += 2 * rowHeight;
    
    _dueTimeLabel.font = [UIFont systemFontOfSize:rowHeight / 2];
    [_dueTimeLabel sizeToFit];
    _dueTimeLabel.frame = CGRectMake(CGRectGetWidth(self.bounds) / 2 + 60, originY, CGRectGetWidth(_dueTimeLabel.frame), CGRectGetHeight(_dueTimeLabel.frame));
    originY += CGRectGetHeight(_dueTimeLabel.frame);
    
    self.contentHeight = originY;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    return CGSizeMake(screenWidth, self.contentHeight);
}

@end
