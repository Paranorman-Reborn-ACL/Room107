//
//  AddHouseCollectionViewCell.m
//  room107
//
//  Created by ningxia on 16/4/21.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "AddHouseCollectionViewCell.h"
#import "CustomImageView.h"
#import "SearchTipLabel.h"

@implementation AddHouseCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        //圆角
        self.layer.cornerRadius = 4.0f;
        self.layer.masksToBounds = YES;
        //描边
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [UIColor room107GrayColorB].CGColor;
        
        CGFloat originY = 71.0f;
        CGFloat imageViewHeight = 60.0f;
        CustomImageView *addImageView = [[CustomImageView alloc] initWithImage:[UIImage makeImageFromText:@"\ue62f" font:[UIFont fontWithName:fontIconName size:imageViewHeight] color:[UIColor room107GrayColorC]]];
        CGPoint center = CGPointMake(CGRectGetWidth(self.frame) / 2, originY + imageViewHeight / 2);
        [addImageView setCenter:center];
        [self addSubview:addImageView];
        
        originY += CGRectGetHeight(addImageView.bounds) + 22;
        SearchTipLabel *postSuiteLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.frame), 16}];
        [postSuiteLabel setText:lang(@"PostSuite")];
        [postSuiteLabel setTextAlignment:NSTextAlignmentCenter];
        [postSuiteLabel setNumberOfLines:1];
        [self addSubview:postSuiteLabel];
    }
    
    return self;
}

@end
