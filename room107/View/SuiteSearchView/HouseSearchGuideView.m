//
//  HouseSearchGuideView.m
//  room107
//
//  Created by ningxia on 16/4/6.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "HouseSearchGuideView.h"
#import "CustomImageView.h"
#import "SearchTipLabel.h"

@implementation HouseSearchGuideView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat originY = 0;
        CGFloat imageViewWidth = 80;
        CGFloat imageViewHeight = 64;
        CustomImageView *imageView = [[CustomImageView alloc] initWithFrame:(CGRect){(CGRectGetWidth(frame) - imageViewWidth) / 2, 0, imageViewWidth, imageViewHeight}];
        [imageView setImageWithName:@"houseSearchGuide.png"];
        [self addSubview:imageView];
        
        originY += CGRectGetHeight(imageView.bounds) + 22;
        CGFloat labelWidth = CGRectGetWidth(frame);
        CGFloat labelHeight = 45;
        SearchTipLabel *enterPositionTipsLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, labelWidth, labelHeight}];
        [enterPositionTipsLabel setAttributedText:[self attributedContentByText:lang(@"EnterPositionTips")]];
        [self addSubview:enterPositionTipsLabel];
        
        originY += CGRectGetHeight(enterPositionTipsLabel.bounds) + 22;
        SearchTipLabel *suiteFromMapTipsLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, labelWidth, labelHeight}];
        [suiteFromMapTipsLabel setAttributedText:[self attributedContentByText:lang(@"SuiteFromMapTips")]];
        [self addSubview:suiteFromMapTipsLabel];
        
        frame.size.height = originY + CGRectGetHeight(suiteFromMapTipsLabel.bounds);
        [self setFrame:frame];
        CGPoint center = self.center;
        center.y = CGRectGetHeight([CommonFuncs tableViewFrame]) / 2;
        self.center = center;
    }
    
    return self;
}

- (NSMutableAttributedString *)attributedContentByText:(NSString *)text {
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:text];
    NSArray *components = [text componentsSeparatedByString:@"\n"];
    NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor room107GrayColorD], NSFontAttributeName:[UIFont room107SystemFontThree]};
    [attributedContent addAttributes:attrs range:NSMakeRange(0, [components[0] length])];
    attrs = @{NSForegroundColorAttributeName:[UIColor room107GrayColorC], NSFontAttributeName:[UIFont room107SystemFontTwo]};
    [attributedContent addAttributes:attrs range:NSMakeRange([components[0] length] + 1, [components[1] length])];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 5;
    attrs = @{NSParagraphStyleAttributeName:paragraphStyle};
    [attributedContent addAttributes:attrs range:NSMakeRange(0, text.length)];
    
    return attributedContent;
}

@end
