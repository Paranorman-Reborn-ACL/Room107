//
//  CustomTextField.m
//  room107
//
//  Created by ningxia on 15/7/10.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        UILabel *leftView = [[UILabel alloc] initWithFrame:(CGRect){self.bounds.origin, 20, CGRectGetHeight(self.bounds)}];
        leftView.backgroundColor = [UIColor clearColor];
        self.leftView = leftView;
        self.leftViewMode = UITextFieldViewModeAlways;
        
        self.textAlignment = NSTextAlignmentLeft;
        [self setTextColor:[UIColor room107GrayColorD]];
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  //内容的垂直对齐方式
        self.backgroundColor = [UIColor whiteColor];
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self setFont:[UIFont room107SystemFontThree]];
        [self setTintColor:[UIColor room107GreenColor]];
        
        //键盘顶部增加自定义View
        UIToolbar *topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 30)];
        [topView setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *helloButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:lang(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(controlsResignFirstResponder)];
        [doneButton setTintColor:[UIColor room107GreenColor]]; //改变文本颜色
        NSArray *buttonsArray = [NSArray arrayWithObjects:helloButton, spaceButton, doneButton, nil];
        [topView setItems:buttonsArray];
        [self setInputAccessoryView:topView];
    }
    
    return self;
}

- (void)controlsResignFirstResponder {
    if ([self.responderDelegate respondsToSelector:@selector(textFieldResignFirstResponder)]) {
        [self.responderDelegate textFieldResignFirstResponder];
    }
    [self resignFirstResponder];
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder ? placeholder : @"" attributes:@{NSForegroundColorAttributeName:[UIColor room107GrayColorB]}];
}

- (void)setFontSize:(CGFloat)size {
    self.font = [UIFont systemFontOfSize:size];
}

- (void)setLeftViewWidth:(CGFloat)width {
    [self.leftView setFrame:(CGRect){self.leftView.bounds.origin, width, self.leftView.bounds.size.height}];
}

@end
