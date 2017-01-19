//
//  HouseSignedWarningTableViewCell.m
//  room107
//
//  Created by ningxia on 16/3/1.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "HouseSignedWarningTableViewCell.h"
#import "CustomImageView.h"
#import "YellowColorTextLabel.h"

static CGFloat originX = 11;
static CGFloat originY = 11;
static CGFloat imageViewWidth = 33;

@interface HouseSignedWarningTableViewCell ()

@property (nonatomic, strong) YellowColorTextLabel *warningContentLabel;
@property (nonatomic, strong) CustomImageView *warningImageView;

@end

@implementation HouseSignedWarningTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView setBackgroundColor:[UIColor room107GrayColorB]];
        
        _warningContentLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){originX, originY, [self maxContentWidth], houseSignedWarningTableViewCellMinHeight - 2 * originY} withTitle:@""];
        [_warningContentLabel setFont:[UIFont room107SystemFontOne]];
        [self.contentView addSubview:_warningContentLabel];

        _warningImageView = [[CustomImageView alloc] initWithFrame:(CGRect){CGRectGetWidth([self cellFrame]) - originX - imageViewWidth, originY, imageViewWidth, imageViewWidth}];
        [_warningImageView setBackgroundColor:[UIColor clearColor]];
        [_warningImageView setImageWithName:@"SignedWarning.png"];
        [self.contentView addSubview:_warningImageView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, houseSignedWarningTableViewCellMinHeight);
}

- (void)setContent:(NSString *)content {
    CGRect warningContentLabelFrame = _warningContentLabel.frame;
    warningContentLabelFrame.size.height = MAX(houseSignedWarningTableViewCellMinHeight, [self getCellHeightWithContent:content]) - 2 * originY;
    [_warningContentLabel setFrame:warningContentLabelFrame];
    [_warningContentLabel setTitle:content withTitleColor:[UIColor room107GrayColorD] withAlignment:NSTextAlignmentLeft];
    
    CGPoint warningImageViewCenter = _warningImageView.center;
    warningImageViewCenter.y = _warningContentLabel.center.y;
    [_warningImageView setCenter:warningImageViewCenter];
}

- (CGFloat)maxContentWidth {
    return CGRectGetWidth([self cellFrame]) - originX * 3 - imageViewWidth;
}

- (NSDictionary *)attributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5; //字体的行间距
    return @{NSFontAttributeName:[UIFont room107SystemFontOne],
                                 NSParagraphStyleAttributeName:paragraphStyle};
}

- (CGFloat)getCellHeightWithContent:(NSString *)content {
    return originY * 2 + [CommonFuncs rectWithText:content ? content : @"" andMaxDisplayWidth:[self maxContentWidth] andAttributes:[self attributes]].size.height + 5;
}

@end
