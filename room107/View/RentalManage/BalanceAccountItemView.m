//
//  BalanceAccountItemView.m
//  room107
//
//  Created by Naitong Yu on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "BalanceAccountItemView.h"

@interface BalanceAccountItemView ()

@property (nonatomic) UILabel *categoryNameLabel;
@property (nonatomic) UILabel *categoryMoneyLabel;

@property (nonatomic) UIButton *collapseButton;

@property (nonatomic) NSMutableArray *detailNames;
@property (nonatomic) NSMutableArray *detailMoneys;

@property (nonatomic) BOOL collapse;

@end

@implementation BalanceAccountItemView

- (instancetype)initWithFrame:(CGRect)frame categoryName:(NSString *)name details:(NSArray *)details collapse:(BOOL)collapse {
    self = [super initWithFrame:frame];
    if (self) {
        self.collapse = collapse;
        
        _categoryNameLabel = [[UILabel alloc] init];
        _categoryNameLabel.text = name;
        _categoryNameLabel.textColor = [UIColor room107GrayColorD];
        [self addSubview:_categoryNameLabel];
        
        NSInteger sum = 0;
        _detailNames = [[NSMutableArray alloc] initWithCapacity:details.count];
        _detailMoneys = [[NSMutableArray alloc] initWithCapacity:details.count];
        
        for (NSDictionary *detail in details) {
            NSString *description = detail[@"description"];
            NSInteger money = [detail[@"amount"] integerValue];
            sum += money;
            
            UILabel *detailNameLabel = [[UILabel alloc] init];
            detailNameLabel.text = description;
            detailNameLabel.textColor = [UIColor room107GrayColorD];
            [self addSubview:detailNameLabel];
            [self.detailNames addObject:detailNameLabel];
            
            UILabel *detailMoneyLabel = [[UILabel alloc] init];
            detailMoneyLabel.text = [NSString stringWithFormat:@"¥%ld", (long)money];
            detailMoneyLabel.textColor = [UIColor room107GrayColorD];
            [self addSubview:detailMoneyLabel];
            [self.detailMoneys addObject:detailMoneyLabel];
        }
        _totalMoney = sum;
        
        _categoryMoneyLabel = [[UILabel alloc] init];
        _categoryMoneyLabel.text = [NSString stringWithFormat:@"¥%ld", (long)sum];
        _categoryMoneyLabel.textColor = [UIColor room107GrayColorD];
        [self addSubview:_categoryMoneyLabel];
        
        _collapseButton = [[UIButton alloc] init];
        [_collapseButton setTitle:@"^" forState:UIControlStateNormal];
        [_collapseButton setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateNormal];
        [_collapseButton addTarget:self action:@selector(collapseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_collapseButton];
        
        
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat margin = 60;
    CGFloat rowHeight = self.frame.size.height / (1 + self.detailMoneys.count);
    CGFloat width = self.frame.size.width;
    
    _categoryNameLabel.font = [UIFont systemFontOfSize:rowHeight * 2 / 3];
    _categoryNameLabel.frame = CGRectMake(margin, 0, width / 2 - margin, rowHeight);
    
    _categoryMoneyLabel.font = [UIFont systemFontOfSize:rowHeight * 2 / 3];
    [_categoryMoneyLabel sizeToFit];
    _categoryMoneyLabel.frame = CGRectMake(width / 2 + margin, 0, CGRectGetWidth(_categoryMoneyLabel.frame), rowHeight);
    
    _collapseButton.titleLabel.font = [UIFont systemFontOfSize:rowHeight * 2 / 3];
    _collapseButton.frame = CGRectMake(width * 3 / 4, 0, rowHeight, rowHeight);
    
    CGFloat originY = rowHeight;
    for (int i = 0; i < self.detailNames.count; i++) {
        UILabel *detailNameLabel = self.detailNames[i];
        UILabel *detailMoneyLabel = self.detailMoneys[i];
        
        detailNameLabel.font = [UIFont systemFontOfSize:rowHeight / 2];
        detailNameLabel.frame = CGRectMake(margin, originY, width / 2 - margin, rowHeight);
        
        detailMoneyLabel.font = [UIFont systemFontOfSize:rowHeight / 2];
        [detailMoneyLabel sizeToFit];
        detailMoneyLabel.frame = CGRectMake(width / 2 + margin, originY, CGRectGetWidth(detailMoneyLabel.frame), rowHeight);
        
        originY += rowHeight;
    }
    
}

- (void)collapseButtonTapped:(UIButton *)sender {
    self.collapse = !self.collapse;
    
    for (UILabel *nameLabel in self.detailNames) {
        nameLabel.hidden = self.collapse;
    }
    for (UILabel *moneyLabel in self.detailMoneys) {
        moneyLabel.hidden = self.collapse;
    }    
}

@end
