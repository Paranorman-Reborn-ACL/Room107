//
//  SuiteDescriptionTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SuiteDescriptionTableViewCell.h"
#import "CustomTextView.h"

@interface SuiteDescriptionTableViewCell () <UITextViewDelegate>

//@property (nonatomic, strong) CustomTextView *suiteDescriptionTextView;

@end

@implementation SuiteDescriptionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        _suiteDescriptionTextView = [[CustomTextView alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], 100}];
//        _suiteDescriptionTextView.delegate = self;
        [self addSubview:_suiteDescriptionTextView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, suiteDescriptionTableViewCellHeight);
}

- (void)setPlaceholder:(NSString *)placeholder {
    [_suiteDescriptionTextView setPlaceholder:placeholder];
}

- (void)setSuiteDescription:(NSString *)suiteDescription {
    [_suiteDescriptionTextView setText:suiteDescription];
}

- (NSString *)suiteDescription {
    return _suiteDescriptionTextView.text;
}
//
//#pragma mark - UITextViewDelegate
//- (void)textViewDidChange:(UITextView *)textView {
//    [(CustomTextView *)textView showPlaceholder:textView.text.length == 0 ? YES : NO];
//}

@end
