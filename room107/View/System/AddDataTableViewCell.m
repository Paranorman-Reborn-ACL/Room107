//
//  AddDataTableViewCell.m
//  room107
//
//  Created by ningxia on 16/3/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "AddDataTableViewCell.h"
#import "GreenCenterLabel.h"

@interface AddDataTableViewCell ()

@property (nonatomic, strong) GreenCenterLabel *addLabel;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)();

@end

@implementation AddDataTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 11.0f;
        CGFloat originY = 11;
        CGFloat containerViewWidth = CGRectGetWidth([self cellFrame]) - 2 * originX;
        CGFloat containerViewHeight = CGRectGetHeight([self cellFrame]) - originY;
        UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, containerViewWidth, containerViewHeight}];
        containerView.layer.cornerRadius = [CommonFuncs cornerRadius];
        containerView.layer.masksToBounds = YES;
        [containerView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:containerView];
        
        CGRect frame = containerView.frame;
        frame.origin = CGPointMake(0, 0);
        _addLabel = [[GreenCenterLabel alloc] initWithFrame:frame withText:lang(@"AddSubscribe")];
        [_addLabel setFont:[UIFont room107FontTwo]];
        [containerView addSubview:_addLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, addDataTableViewCellHeight);
}

@end
