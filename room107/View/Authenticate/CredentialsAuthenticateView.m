//
//  CredentialsAuthenticateView.m
//  room107
//
//  Created by ningxia on 15/7/22.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "CredentialsAuthenticateView.h"
#import "RoundedGreenButton.h"
#import "CredentialsSelectView.h"
#import "CustomImageView.h"
#import "CustomLabel.h"
#import "YellowColorTextLabel.h"
#import "TitleGreenColorTextLabel.h"

@interface CredentialsAuthenticateView () <CredentialsSelectViewDelegate>

@property (nonatomic, strong) CredentialsSelectView *IDPhotoView;
@property (nonatomic, strong) CredentialsSelectView *studentcardOrWorkpermitPhotoView;
@property (nonatomic, strong) CredentialsSelectView *currentCredentialsSelectView;
@property (nonatomic, strong) UIScrollView *authenticateView;
@property (nonatomic, strong) UIScrollView *resultView;
@property (nonatomic, strong) CustomImageView *IDCareImageView;
@property (nonatomic, strong) CustomImageView *workCardImageView;;

@end

@implementation CredentialsAuthenticateView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        //frame的origin置0，避免位置偏移
        frame.origin.x = 0;
        frame.origin.y = 0;
        if (!_authenticateView) {
            _authenticateView = [[UIScrollView alloc] initWithFrame:frame];
            [_authenticateView setBackgroundColor:[UIColor clearColor]];
            [self addSubview:_authenticateView];
            
            CGFloat originX = 20.0f;
            CGFloat originY = 22.0f;
            CGRect frame = (CGRect){0, originY, self.bounds.size.width, 60};
            TitleGreenColorTextLabel *titleGreenColorTextLabel = [[TitleGreenColorTextLabel alloc] initWithFrame:CGRectMake(0, originY, self.bounds.size.width, 100) withTitle:lang(@"WhyAuthenticate") withContent:lang(@"ReasonAuthenticate")];
            [_authenticateView addSubview:titleGreenColorTextLabel];
            
            originY += CGRectGetHeight(titleGreenColorTextLabel.frame) + 22;
            UIView *separatedView = [[UIView alloc] initWithFrame:CGRectMake(22, originY, self.frame.size.width - 44, 1)];
            [separatedView setBackgroundColor:[UIColor room107GrayColorC]];
            [_authenticateView addSubview:separatedView];

            originY = CGRectGetMaxY(separatedView.frame) + 22;
            CGFloat maxDisplayWidth = CGRectGetWidth(_authenticateView.bounds) - originX * 2;
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 5; //字体的行间距
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont room107SystemFontThree],
                                         NSParagraphStyleAttributeName:paragraphStyle};
            YellowColorTextLabel *credentialsAuthenticateTipsLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){originX, originY, maxDisplayWidth, [CommonFuncs rectWithText:lang(@"CredentialsAuthenticateTips") andMaxDisplayWidth:maxDisplayWidth andAttributes:attributes].size.height} withTitle:lang(@"CredentialsAuthenticateTips") withTitleColor:[UIColor room107GrayColorC] withAlignment:NSTextAlignmentLeft];
            [_authenticateView addSubview:credentialsAuthenticateTipsLabel];
            
            originY += CGRectGetHeight(credentialsAuthenticateTipsLabel.bounds) + 5;
            CGFloat photoViewHeight = 120.0f;
            _IDPhotoView = [[CredentialsSelectView alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), photoViewHeight}];
            [_IDPhotoView setUpExampleImage:nil downExampleImage:@"identification.png"];
            [_IDPhotoView setCredentialsSelectTips:lang(@"SelectIDPhoto") andCredentialsImage:nil];
            _IDPhotoView.delegate = self;
            [_authenticateView addSubview:_IDPhotoView];
            
            originY += CGRectGetHeight(_IDPhotoView.bounds);
            _studentcardOrWorkpermitPhotoView = [[CredentialsSelectView alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), photoViewHeight}];
            [_studentcardOrWorkpermitPhotoView setUpExampleImage:@"workcard.png" downExampleImage:@"studentcard.png"];
            [_studentcardOrWorkpermitPhotoView setCredentialsSelectTips:lang(@"SelectStudentcardOrWorkpermitPhoto") andCredentialsImage:nil];
            _studentcardOrWorkpermitPhotoView.delegate = self;
            [_authenticateView addSubview:_studentcardOrWorkpermitPhotoView];
            
            originY += CGRectGetHeight(_studentcardOrWorkpermitPhotoView.bounds) + 44;
            frame = (CGRect){0, originY, CGRectGetWidth(self.bounds), 100};
            SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"Confirm") andAssistantButtonTitle:@""];
            [_authenticateView addSubview:mutualBottomView];
            [mutualBottomView setMainButtonDidClickHandler:^{
                if (![self IDPhoto]) {
                    [PopupView showMessage:lang(@"SelectIDPhoto")];
                    return;
                }
                
                if (![self studentcardOrWorkpermitPhoto]) {
                    [PopupView showMessage:lang(@"SelectStudentcardOrWorkpermitPhoto")];
                    return;
                }
                
                if ([self.delegate respondsToSelector:@selector(confirmAuthenticateButtonDidClick:)]) {
                    [self.delegate confirmAuthenticateButtonDidClick:self];
                }
            }];
            
            [_authenticateView setContentSize:CGSizeMake(CGRectGetWidth(self.bounds), originY + CGRectGetHeight(mutualBottomView.bounds))];
        }
        
        if (!_resultView) {
            _resultView = [[UIScrollView alloc] initWithFrame:frame];
            [_resultView setBackgroundColor:[UIColor clearColor]];
            [self addSubview:_resultView];
            
            CGFloat originX = 30.0f;
            CGFloat originY = 22.0f;
            CGFloat spaceX = 20.0f;
            CGFloat imageViewWidth = (CGRectGetWidth(self.bounds) - 2 * originX - spaceX) / 2;
            CGFloat imageViewHeight = imageViewWidth * 2 / 3;
            
            _IDCareImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, originY, imageViewWidth, imageViewHeight}];
            [_IDCareImageView setCornerRadius:5.0f];
            [_resultView addSubview:_IDCareImageView];
            
            originX += imageViewWidth + spaceX;
            _workCardImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, originY, imageViewWidth, imageViewHeight}];
            [_workCardImageView setCornerRadius:5.0f];
            [_resultView addSubview:_workCardImageView];
            
            originY += CGRectGetHeight(_IDCareImageView.bounds) + 22;
            CustomLabel *uploadSuccessLabel = [[CustomLabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.bounds), 60}];
            [uploadSuccessLabel setNumberOfLines:0];
            [uploadSuccessLabel setText:lang(@"UploadSuccess")];
            [uploadSuccessLabel setFont:[UIFont room107SystemFontThree]];
            [uploadSuccessLabel setTextAlignment:NSTextAlignmentCenter];
            [uploadSuccessLabel setTextColor:[UIColor room107GrayColorC]];
            [_resultView addSubview:uploadSuccessLabel];
            
            originY += CGRectGetHeight(uploadSuccessLabel.bounds);
            CGRect frame = (CGRect){0, originY, CGRectGetWidth(self.bounds), 100};
            SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:@"" andAssistantButtonTitle:lang(@"Reupload")];
            [_resultView addSubview:mutualBottomView];
            [mutualBottomView setAssistantButtonDidClickHandler:^{
                if ([self.delegate respondsToSelector:@selector(reuploadButtonDidClick:)]) {
                    [self.delegate reuploadButtonDidClick:self];
                }
            }];
            
            [_resultView setContentSize:CGSizeMake(CGRectGetWidth(self.bounds), originY + CGRectGetHeight(mutualBottomView.bounds))];
        }
    }
    
    return self;
}

- (void)showStep:(NSUInteger)step {
    if (step == 1) {
        _authenticateView.hidden = NO;
        _resultView.hidden = YES;
    } else {
        _authenticateView.hidden = YES;
        _resultView.hidden = NO;
    }
}

- (void)setCredentialsPhoto:(UIImage *)photo {
    if (_currentCredentialsSelectView) {
        [_currentCredentialsSelectView setCredentialsSelectTips:lang(@"ReselectPhoto") andCredentialsImage:photo];
    }
}

- (UIImage *)IDPhoto {
    return [_IDPhotoView getCredentialsPhoto];
}

- (UIImage *)studentcardOrWorkpermitPhoto {
    return [_studentcardOrWorkpermitPhotoView getCredentialsPhoto];
}

- (void)setIDCareImageURL:(NSString *)idCardImageURL andWorkCardImageURL:(NSString *)workCardImageURL {
    [_IDCareImageView setImageWithURL:idCardImageURL];
    [_workCardImageView setImageWithURL:workCardImageURL];
}

#pragma mark - CredentialsSelectViewDelegate
- (void)credentialsButtonDidClick:(CredentialsSelectView *)credentialsSelectView {
    _currentCredentialsSelectView = credentialsSelectView;
    
    if ([self.delegate respondsToSelector:@selector(selectCredentialsButtonDidClick:)]) {
        [self.delegate selectCredentialsButtonDidClick:self];
    }
}

@end
