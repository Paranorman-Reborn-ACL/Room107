//
//  RedBagBalanceItem.m
//  room107
//
//  Created by Naitong Yu on 15/9/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "InventoryItemView.h"

static CGFloat amountWidth = 170.0f; //价钱活动区域

@interface InventoryItemView ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, assign) double amount;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *amountLabel;

@property (nonatomic) UIView *upperSeperator;
@property (nonatomic) UIView *lowerSeperator;

@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSNumberFormatter *numberFormatter;

@end

@implementation InventoryItemView


- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm";
    }
    return _dateFormatter;
}

- (NSNumberFormatter *)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.minimumFractionDigits = 2;
        _numberFormatter.maximumFractionDigits = 2;
        _numberFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        
    }
    return _numberFormatter;
}

- (NSString *)stringFromDoubleValue:(double)value {
    NSString *str = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:value]];
    if (value < 0) {
        return str;
    } else {
        return [NSString stringWithFormat:@"+%@", str];
    }
}

- (instancetype)initWithTitle:(NSString *)title date:(NSString *)date amount:(double)amount {
    if (self = [super init]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        self.title = title;
        self.date = date;
        self.amount = amount;
        
        [self setup];
    }
    return self;
}

- (void)setDate:(NSString *)date {
    NSString *year = [date substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [date substringWithRange:NSMakeRange(4, 2)];
    NSString *day = [date substringWithRange:NSMakeRange(6, 2)];
    NSString *hour = [date substringWithRange:NSMakeRange(8, 2)];
    NSString *minute = [date substringWithRange:NSMakeRange(10, 2)];
    NSString *second = [date substringWithRange:NSMakeRange(12, 2)];
    _date = [NSString stringWithFormat:@"%@/%@/%@ %@:%@:%@", year, month, day, hour, minute, second];
}


- (void)setup {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat amountWidth = 170.0f;
    CGFloat originX = 22.0f;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor room107GrayColorD];
    _titleLabel.attributedText = [self attributesStringWithText:_title];
    _titleLabel.numberOfLines = 0;
    [_titleLabel setFrame:CGRectMake(originX, 11, width - amountWidth, [self getHeightWithText:_titleLabel.text])];
    [self addSubview:_titleLabel];
    
    _dateLabel = [[UILabel alloc] init];
    _dateLabel.font = [UIFont room107SystemFontOne];
    _dateLabel.textColor = [UIColor room107GrayColorC];
    _dateLabel.text = self.date;
    [_dateLabel sizeToFit];
    CGRect frame = _dateLabel.frame;
    frame.origin = CGPointMake(originX, CGRectGetMaxY(_titleLabel.frame) + 3);
    _dateLabel.frame = frame;
    [self addSubview:_dateLabel];
    
    _amountLabel = [[UILabel alloc] init];
    _amountLabel.font = [UIFont room107SystemFontFour];
    _amountLabel.textColor = [UIColor room107GrayColorD];
    _amountLabel.text = [self stringFromDoubleValue:self.amount];
    [_amountLabel sizeToFit];
    frame = _amountLabel.frame;

    [self addSubview:_amountLabel];
    
    _upperSeperator = [[UIView alloc] init];
    _upperSeperator.backgroundColor = [UIColor room107GrayColorA];
    [self addSubview:_upperSeperator];
    
    _lowerSeperator = [[UIView alloc] init];
    _lowerSeperator.backgroundColor = [UIColor room107GrayColorA];
    [self addSubview:_lowerSeperator];
    
    _upperSeperator.frame = CGRectMake(0, 0, width, 0.5);
    _lowerSeperator.frame = CGRectMake(0, CGRectGetMaxY(_dateLabel.frame) + 5 , width, 0.5);
    
    frame.origin = CGPointMake(width - CGRectGetWidth(frame) - originX, CGRectGetMaxY(_lowerSeperator.frame)/2 - CGRectGetHeight(frame) / 2);
    _amountLabel.frame = frame;
}

- (CGFloat)getHeight {
    return CGRectGetMaxY(_lowerSeperator.frame);
}

- (CGFloat)getOriginY {
    return CGRectGetMaxY(_lowerSeperator.frame) - 0.5;
}

- (CGFloat)getHeightWithText:(NSString *)text {
    CGRect contentRect = [text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - amountWidth ,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[self getAttributes] context:nil];
    return contentRect.size.height;
}

- (NSDictionary *)getAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont room107SystemFontTwo],NSParagraphStyleAttributeName:paragraphStyle};
    return attributes;
}

- (NSAttributedString *)attributesStringWithText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text ? text : @"" attributes:[self getAttributes]];
}
@end
