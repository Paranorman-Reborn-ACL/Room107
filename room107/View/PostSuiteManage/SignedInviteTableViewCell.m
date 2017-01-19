//
//  SignedInviteTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/1.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SignedInviteTableViewCell.h"
#import "SearchTipLabel.h"
#import "CustomLabel.h"
#import "CustomImageView.h"
#import "ReddieView.h"

static CGFloat labelWidth = 120.0f;
static CGFloat labelHeight = 30.0f;

@interface SignedInviteTableViewCell ()

@property (nonatomic, strong) CustomImageView *avatarImageView;
@property (nonatomic, strong) SearchTipLabel *tenantNameLabel;
@property (nonatomic, strong) SearchTipLabel *telephoneLabel;
@property (nonatomic, strong) SearchTipLabel *signedStatusLabel;
@property (nonatomic, strong) SearchTipLabel *checkinTimeLabel;
@property (nonatomic, strong) SearchTipLabel *exitTimeLabel;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) ReddieView *flagView;
@property (nonatomic, strong) void (^handlerBlock)(SignedInviteTableViewCell *signedInviteTableViewCell);

@end

@implementation SignedInviteTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 10.0f;
        CGFloat originY = 5.0f;
        CGFloat cornerRadius = 5.0f;
        CGFloat containerViewWidth = CGRectGetWidth([self cellFrame]) - 2 * originX;
        CGFloat containerViewHeight = CGRectGetHeight([self cellFrame]) - originY;
        UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, containerViewWidth, containerViewHeight}];
        containerView.layer.cornerRadius = cornerRadius;
        containerView.layer.masksToBounds = YES;
        [containerView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:containerView];
        UILongPressGestureRecognizer *containerViewRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewDidLongPress:)];
        containerViewRec.minimumPressDuration = 0.5f;
        [containerView addGestureRecognizer:containerViewRec];
        
        CGFloat imageViewWidth = containerViewHeight * 2 / 3;
        _avatarImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, (containerView.frame.size.height - imageViewWidth) / 2, imageViewWidth, imageViewWidth}];
        [_avatarImageView setCornerRadius:CGRectGetWidth(_avatarImageView.bounds) / 2];
        [_avatarImageView setBackgroundColor:[UIColor room107GrayColorA]];
        [containerView addSubview:_avatarImageView];
        
        //未读标示
        _flagView = [[ReddieView alloc] initWithOrigin:CGPointMake(originX + imageViewWidth, _avatarImageView.frame.origin.y - 5)];
        [containerView addSubview:_flagView];
        
        originX += CGRectGetWidth(_avatarImageView.bounds) + 10;
        _tenantNameLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth / 2, labelHeight}];
        [_tenantNameLabel setTextColor:[UIColor room107GrayColorD]];
        [containerView addSubview:_tenantNameLabel];
        
        originY += CGRectGetHeight(_tenantNameLabel.bounds) - 5;
        _telephoneLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_telephoneLabel setFont:[UIFont room107FontThree]];
        [containerView addSubview:_telephoneLabel];
        
        _signedStatusLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){(CGRectGetWidth(containerView.bounds) - labelWidth / 2) / 2, 0, labelWidth / 2, labelHeight * 0.8}];
        [_signedStatusLabel setTextColor:[UIColor whiteColor]];
        [_signedStatusLabel setFont:[UIFont room107FontTwo]];
        [_signedStatusLabel setTextAlignment:NSTextAlignmentCenter];
        [containerView addSubview:_signedStatusLabel];
        
        originX = _signedStatusLabel.frame.origin.x + _signedStatusLabel.frame.size.width + 5;
        _checkinTimeLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, _tenantNameLabel.frame.origin.y, labelWidth, labelHeight}];
        [_checkinTimeLabel setFont:[UIFont room107FontOne]];
        [containerView addSubview:_checkinTimeLabel];
        
        _exitTimeLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, _telephoneLabel.frame.origin.y, labelWidth, labelHeight}];
        [_exitTimeLabel setFont:[UIFont room107FontOne]];
        [containerView addSubview:_exitTimeLabel];
        
        CustomLabel *iconLabel = [[CustomLabel alloc] initWithFrame:(CGRect){containerView.frame.size.width - 10 - labelHeight, (containerView.frame.size.height - labelHeight) / 2, labelHeight, labelHeight}];
        [iconLabel setFont:[UIFont room107FontOne]];
        [iconLabel setTextColor:[UIColor room107GrayColorC]];
        [iconLabel setText:@">"];
        [containerView addSubview:iconLabel];
        
        CGRect frame = containerView.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        _coverView = [[UIView alloc] initWithFrame:frame];
        [_coverView setBackgroundColor:[UIColor room107GrayColorC]];
        _coverView.alpha = 0.5f;
        [containerView addSubview:_coverView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, signedInviteTableViewCellHeight);
}

- (void)setWaitOtherContract:(BOOL)wait {
    if (wait) {
        [_signedStatusLabel setBackgroundColor:[UIColor room107GrayColorB]];
        [_signedStatusLabel setText:lang(@"OtherContractsUnderReview")];
        CGFloat width = labelWidth * 0.9;
        CGPoint origin = _signedStatusLabel.frame.origin;
        origin.x += (_signedStatusLabel.frame.size.width - width) / 2;
        [_signedStatusLabel setFrame:(CGRect){origin, width, _signedStatusLabel.frame.size.height}];
    }
}

- (void)setTenantName:(NSString *)name {
    [_tenantNameLabel setText:name];
}

- (void)setTelephone:(NSString *)telephone {
    [_telephoneLabel setText:[@"\ue618" stringByAppendingString:telephone ? telephone : @""]];
}

- (void)setAvatarImageURL:(NSString *)url {
    [_avatarImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"loginlogo.png"]];
}

- (void)setRequestStatus:(NSNumber *)status {
    //FILLING, CONFIRMING, RENTING, TERMINATED, CLOSE_BY_ADMIN, CLOSE_BY_LANDLORD, CLOSE_BY_TENANT
    NSArray *requestStatuses = @[lang(@"Filling"), lang(@"Confirming"), lang(@"Renting"), lang(@"Terminated"), lang(@"AuditFailed"), lang(@"CloseByLandlord"), lang(@"CloseByTenant")];
    [_signedStatusLabel setText:requestStatuses[[status intValue]]];
    _coverView.hidden = YES;
    [_signedStatusLabel setFrame:(CGRect){(CGRectGetWidth([self cellFrame]) - 20 - labelWidth / 2) / 2, 0, labelWidth / 2, labelHeight * 0.8}];
    if ([status intValue] == 0) {
        [_signedStatusLabel setBackgroundColor:[UIColor room107YellowColor]];
    } else if ([status intValue] < 4) {
        [_signedStatusLabel setBackgroundColor:[UIColor room107GreenColor]];
    } else {
        _coverView.hidden = NO;
        [_signedStatusLabel setBackgroundColor:[UIColor room107GrayColorB]];
        if ([status intValue] == 6) {
            CGFloat width = labelWidth * 0.9;
            CGPoint origin = _signedStatusLabel.frame.origin;
            origin.x += (_signedStatusLabel.frame.size.width - width) / 2;
            [_signedStatusLabel setFrame:(CGRect){origin, width, _signedStatusLabel.frame.size.height}];
        }
    }
}

- (void)setCheckinTime:(NSString *)time {
    [_checkinTimeLabel setText:[NSString stringWithFormat:@"%@ %@", lang(@"CheckIn"), [TimeUtil friendlyDateTimeFromDateTime:time withFormat:@"%Y/%m/%d"]]];
}

- (void)setExitTime:(NSString *)time {
    [_exitTimeLabel setText:[NSString stringWithFormat:@"%@ %@", lang(@"Reimburse"), [TimeUtil friendlyDateTimeFromDateTime:time withFormat:@"%Y/%m/%d"]]];
}

- (void)setNewUpdate:(NSNumber *)newUpdate {
    _flagView.hidden = ![newUpdate boolValue];
}

- (void)setLongPressHandler:(void(^)(SignedInviteTableViewCell *signedInviteTableViewCell))handler {
    self.handlerBlock = handler;
}

- (void)containerViewDidLongPress:(UILongPressGestureRecognizer *)rec {
    if (rec.state == UIGestureRecognizerStateBegan) {
        //避免长按事件执行两次
        if (self.handlerBlock) {
            self.handlerBlock(self);
        }
    }
}

@end
