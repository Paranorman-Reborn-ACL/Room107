//
//  PostSuiteTableViewCell.m
//  room107
//
//  Created by ningxia on 16/1/8.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "PostSuiteTableViewCell.h"
#import "CustomImageView.h"
#import "SearchTipLabel.h"
#import "YellowColorTextLabel.h"

@implementation PostSuiteTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 11.0f;
        CGFloat originY = 10.0f;
        CGFloat cornerRadius = [CommonFuncs cornerRadius];
        CGFloat containerViewWidth = CGRectGetWidth([self cellFrame]) - 2 * originX;
        CGFloat containerViewHeight = CGRectGetHeight([self cellFrame]) - originY;
        UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, containerViewWidth, containerViewHeight}];
        containerView.layer.cornerRadius = cornerRadius;
        containerView.layer.masksToBounds = YES;
        [containerView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:containerView];
        
        //添加阴影效果
        UIView *shadowView = [[UIView alloc] initWithFrame:containerView.frame];
        shadowView.layer.cornerRadius = cornerRadius;
        [shadowView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:shadowView];
        [self.contentView sendSubviewToBack:shadowView];
        shadowView.layer.shadowColor = [CommonFuncs shadowColor].CGColor;
        shadowView.layer.shadowOffset = CGSizeMake([CommonFuncs shadowRadius], [CommonFuncs shadowRadius]);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3)
        shadowView.layer.shadowOpacity = [CommonFuncs shadowOpacity];//阴影透明度，默认0
        shadowView.layer.shadowRadius = [CommonFuncs shadowRadius];//阴影半径，默认3
        
        CGFloat spaceY = 22.0f;
        CGFloat imageViewHeight = 88.0f;
        CustomImageView *addImageView = [[CustomImageView alloc] initWithImage:[UIImage makeImageFromText:@"\ue62f" font:[UIFont fontWithName:fontIconName size:imageViewHeight] color:[UIColor room107GrayColorC]]];
        CGPoint center = containerView.center;
        center.x -= originX;
        center.y = spaceY + imageViewHeight / 2;
        [addImageView setCenter:center];
        [containerView addSubview:addImageView];
        
        originY = 2 * spaceY + imageViewHeight;
        SearchTipLabel *postSuiteLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, containerViewWidth, 22}];
        [postSuiteLabel setText:lang(@"PostSuite")];
        [postSuiteLabel setTextAlignment:NSTextAlignmentCenter];
        [postSuiteLabel setFont:[UIFont room107SystemFontFour]];
        [containerView addSubview:postSuiteLabel];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2;// 字体的行间距
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont room107SystemFontOne],
                                     NSParagraphStyleAttributeName:paragraphStyle};
        NSString *content = lang(@"PostSuiteManageExplanation");
        CGRect contentRect = [content boundingRectWithSize:(CGSize){containerViewWidth, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        originY = containerViewHeight - spaceY / 2 - contentRect.size.height;
        SearchTipLabel *postSuiteManageExplanationLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, containerViewWidth, contentRect.size.height}];
        [postSuiteManageExplanationLabel setAttributedText:[[NSAttributedString alloc] initWithString:content attributes:attributes]];
        [containerView addSubview:postSuiteManageExplanationLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [CommonFuncs houseImageHeight] + 11);
}

@end
