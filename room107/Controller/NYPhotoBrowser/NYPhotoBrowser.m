//
//  NYPhotoBrowser.m
//  NYPhotoBrowserDemo
//
//  Created by Naitong Yu on 15/8/8.
//  Copyright (c) 2015年 107间. All rights reserved.
//

#import "NYPhotoBrowser.h"
#import "NYZoomingScrollView.h"
#import "NYConstants.h"

@interface NYPhotoBrowser () <UIScrollViewDelegate, UIAlertViewDelegate>

@property (nonatomic) NSMutableArray *images;
@property (nonatomic) NSMutableArray *pages;
@property (nonatomic) UIScrollView *pagingScrollView;

@property (nonatomic) UIButton *deleteButton;

@property (nonatomic) NSUInteger currentPageIndex;
@property (nonatomic) NSUInteger initialPageIndex;

@property (nonatomic, weak) UIWindow *applicationWindow;
@property (nonatomic, weak) UIViewController *applicationTopViewController;
@property (nonatomic) int previousModalPresentationStyle;

@property (nonatomic) UIView *senderViewForAnimation;
@property (nonatomic) CGRect senderViewOriginalFrame;

@property (nonatomic) UIImage *scaleImage;

@property (nonatomic) BOOL supportDelete;

@property (nonatomic) NSArray *imageNames;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation NYPhotoBrowser

#pragma mark - init

- (instancetype)init {
    if (self = [super init]) {
        // default
        self.hidesBottomBarWhenPushed = YES;
        
        _pages = [[NSMutableArray alloc] init];
        
        _initialPageIndex = 0;
        _currentPageIndex = 0;
        
        _animationDuration = 0.28;
        _senderViewForAnimation = nil;
        _scaleImage = nil;
        _supportDelete = YES;
        
        if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        self.applicationWindow = [[[UIApplication sharedApplication] delegate] window];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            self.modalPresentationStyle = UIModalPresentationCustom;
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            self.modalPresentationCapturesStatusBarAppearance = YES;
        } else {
            self.applicationTopViewController = [self topviewController];
            self.previousModalPresentationStyle = self.applicationTopViewController.modalPresentationStyle;
            self.applicationTopViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        }
        
    }
    return self;
}

- (instancetype)initWithImages:(NSArray *)images {
    return [self initWithImages:images supportDelete:YES];
}

- (instancetype)initWithImages:(NSArray *)images supportDelete:(BOOL)supportDelete {
    if (self = [self init]) {
        _images = [[NSMutableArray alloc] initWithArray:images];
        _supportDelete = supportDelete;
    }
    
    return self;
}

- (void)setImageNames:(NSArray *)imageNames {
    _imageNames = imageNames;
}

- (instancetype)initWithImages:(NSArray *)images animatedFromView:(UIView *)view {
    if (self = [self init]) {
        _images = [[NSMutableArray alloc] initWithArray:images];
        _senderViewForAnimation = view;
    }
    return self;
}

- (void)dealloc {
    _pagingScrollView.delegate = nil;
}

- (void)setInitialPageIndex:(NSUInteger)index {
    // Validate
    if (index >= [self numberOfImages]) index = [self numberOfImages]-1;
    _initialPageIndex = index;
    _currentPageIndex = index;
    if ([self isViewLoaded]) {
        [self jumpToPageAtIndex:index];
    }
}

#pragma mark - data

- (id)objectAtIndex:(NSUInteger)index {
    return self.images[index];
}

- (NSUInteger)numberOfImages {
    return self.images.count;
}

- (void)reloadData {
    [self performLayout];
    [self.view setNeedsLayout];
}

#pragma mark - viewcontroller lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor room107GrayColorA];
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapOnImage)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapOnImage:)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTapGestureRecognizer];
    //这行很关键，意思是只有当没有检测到doubleTapGestureRecognizer 或者 检测doubleTapGestureRecognizer失败，singleTapGestureRecognizer才有效
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    
    self.view.clipsToBounds = YES;
    
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    //_pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.backgroundColor = [UIColor clearColor];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    [self.view addSubview:_pagingScrollView];
    
    if (_supportDelete) {
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setTitle:lang(@"Delete") forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _deleteButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _deleteButton.layer.cornerRadius = 15;
        _deleteButton.layer.borderWidth = 1;
        _deleteButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        _deleteButton.layer.masksToBounds = YES;
        [_deleteButton addTarget:self action:@selector(pressDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_deleteButton];
    }
    
    CGFloat labelWidth = 55.0f;
    CGFloat labelHeight = 22.0f;
    CGFloat originX = 11.0f;
    CGFloat originY = statusBarHeight + 11.0f;
    CGRect frame = (CGRect){originX, originY, labelWidth, labelHeight};
    _indexLabel = [[UILabel alloc] initWithFrame:frame];
    [_indexLabel setBackgroundColor:[UIColor room107BlackColorWithAlpha:0.3]];
    [_indexLabel setTextColor:[UIColor whiteColor]];
    [_indexLabel setTextAlignment:NSTextAlignmentCenter];
    [_indexLabel setFont:[UIFont room107SystemFontTwo]];
    _indexLabel.layer.cornerRadius = labelHeight / 2;
    _indexLabel.layer.masksToBounds = YES;
    [self.view addSubview:_indexLabel];
    [_indexLabel setText:[NSString stringWithFormat:@"%d/%d", _currentPageIndex + 1, _images.count]];
    
    if (_imageNames.count > 0) {
        frame = (CGRect){CGRectGetWidth(self.view.bounds) - originX - labelWidth, originY, labelWidth, labelHeight};
        _nameLabel = [[UILabel alloc] initWithFrame:frame];
        [_nameLabel setBackgroundColor:[UIColor room107BlackColorWithAlpha:0.3]];
        [_nameLabel setTextColor:[UIColor whiteColor]];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [_nameLabel setFont:[UIFont room107SystemFontTwo]];
        _nameLabel.layer.cornerRadius = labelHeight / 2;
        _nameLabel.layer.masksToBounds = YES;
        [self.view addSubview:_nameLabel];
        
        if (_imageNames && _imageNames.count > _currentPageIndex) {
            [_nameLabel setText:_imageNames[_currentPageIndex]];
        }
    }
    
    // Transition animation
    [self performPresentAnimation];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadData];
    
    [super viewWillAppear:animated];
}

#pragma mark - delete action

- (void)pressDeleteButton:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:lang(@"WhetherToDeletePhoto")
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:lang(@"Cancel")
                                              otherButtonTitles:lang(@"Confirm"), nil];
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self deleteImageAtIndex:_currentPageIndex];
    }
}

- (void)deleteImageAtIndex:(NSUInteger)index {
    if (index >= [self numberOfImages]) {
        return;
    }
    
    if (index != _currentPageIndex) {
        return;
    }
    
    if (index > 0) {
        _currentPageIndex--;
        [self.images removeObjectAtIndex:index];
        
        [UIView animateWithDuration:0.28 animations:^{
            NYZoomingScrollView *page = [self.pages objectAtIndex:index];
            [page removeFromSuperview];
            [self.pages removeObjectAtIndex:index];
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];
    } else if ([self numberOfImages] > 1) {
        [self.images removeObjectAtIndex:index];
        
        [UIView animateWithDuration:0.28 animations:^{
            NYZoomingScrollView *page = [self.pages objectAtIndex:index];
            [page removeFromSuperview];
            [self.pages removeObjectAtIndex:index];
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];
    } else {
        [self dismissPhotoBrowserAnimated:YES];
    }
    
    if ([_delegate respondsToSelector:@selector(photoBrowser:DidDeletePhotoAtIndex:)]) {
        [_delegate photoBrowser:self DidDeletePhotoAtIndex:index];
    }
}

#pragma mark - layout subviews

- (void)jumpToPageAtIndex:(NSUInteger)index {
    // Change page
    if (index < [self numberOfImages]) {
        CGRect pageFrame = [self frameForPageAtIndex:index];
        [_pagingScrollView setContentOffset:CGPointMake(pageFrame.origin.x - PADDING, 0) animated:YES];
    }
}

- (void)viewWillLayoutSubviews {
    // Remember index
    NSUInteger indexPriorToLayout = _currentPageIndex;
    
    // Get paging scroll view frame to determine if anything needs changing
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
    // Frame needs changing
    _pagingScrollView.frame = pagingScrollViewFrame;
    
    // Recalculate contentSize based on current orientation
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    for (NSUInteger i = 0; i < [self numberOfImages]; i++) {
        NYZoomingScrollView *page = self.pages[i];
        page.frame = [self frameForPageAtIndex:i];
        [page setMaxMinZoomScalesForCurrentBounds];
    }
    
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
    _currentPageIndex = indexPriorToLayout;
    
    self.deleteButton.frame = [self frameForDeleteButton];
    [super viewWillLayoutSubviews];
}

- (void)performLayout {
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self tilePages];
}

#pragma mark - page

- (void)tilePages {
    for (NYZoomingScrollView *page in self.pages) {
        [page removeFromSuperview];
    }
    [self.pages removeAllObjects];
    
    for (NSUInteger i = 0; i < [self numberOfImages]; i++) {
        NYZoomingScrollView *page = [[NYZoomingScrollView alloc] initWithPhotoBrowser:self];
        page.backgroundColor = [UIColor clearColor];
        page.opaque = YES;
        [self configurePage:page forIndex:i];
        
        [self.pages addObject:page];
        [self.pagingScrollView addSubview:page];
    }
    
    //只加载当前index的图片，避免批量加载，影响速度
    if (self.pages.count > _initialPageIndex) {
        ((NYZoomingScrollView *)self.pages[_initialPageIndex]).object = [self objectAtIndex:_initialPageIndex];
    }
}

- (void)configurePage:(NYZoomingScrollView *)page forIndex:(NSUInteger)index {
    page.frame = [self frameForPageAtIndex:index];
    page.tag = PAGE_INDEX_TAG_OFFSET + index;
}

#pragma mark - frame calculation

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self.images count], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = index * pageWidth;
    return CGPointMake(newOffset, 0);
}

- (CGRect)frameForDeleteButton {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    CGRect frame = CGRectMake((width - 100) / 2, height - 100, 100, 30);
    return frame;
}

- (BOOL)isLandscape:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsLandscape(orientation);
}

#pragma mark - animation

- (void)performPresentAnimation {
    self.view.alpha = 0.0f;
    self.pagingScrollView.alpha = 0.0f;
    
    UIImage *imageFromView = _scaleImage ? _scaleImage : [self getImageFromView:_senderViewForAnimation];
    imageFromView = [self rotateImageToCurrentOrientation:imageFromView];
    
    _senderViewOriginalFrame = [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenBound.size.width;
    CGFloat screenHeight = screenBound.size.height;
    
    UIView *fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    fadeView.backgroundColor = [UIColor clearColor];
    [_applicationWindow addSubview:fadeView];
    
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = _senderViewOriginalFrame;
    resizableImageView.clipsToBounds = YES;
    resizableImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    [_applicationWindow addSubview:resizableImageView];
    _senderViewForAnimation.hidden = YES;
    
    void (^completion)() = ^() {
        self.view.alpha = 1.0f;
        _pagingScrollView.alpha = 1.0f;
        resizableImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
    };
    
    [UIView animateWithDuration:_animationDuration animations:^{
        fadeView.backgroundColor = [UIColor blackColor];
    }];
    
    float scaleFactor = (imageFromView ? imageFromView.size.width : screenWidth) / screenWidth;
    CGRect finalImageViewFrame = CGRectMake(0, (screenHeight/2)-((imageFromView.size.height / scaleFactor)/2), screenWidth, imageFromView.size.height / scaleFactor);
    
    [UIView animateWithDuration:_animationDuration animations:^{
        resizableImageView.layer.frame = finalImageViewFrame;
    } completion:^(BOOL finished) {
        completion();
    }];
    
}

- (void)dismissPhotoBrowserAnimated:(BOOL)animated {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self dismissViewControllerAnimated:animated completion:^{
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            self.applicationTopViewController.modalPresentationStyle = self.previousModalPresentationStyle;
        }
    }];
}

#pragma mark - tap gesture

- (void)singleTapOnImage {
    _senderViewForAnimation.hidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
    [self dismissPhotoBrowserAnimated:YES];
}

- (void)doubleTapOnImage:(UITapGestureRecognizer *)sender {
    if (_pages.count > _currentPageIndex) {
        NYZoomingScrollView *zoomingScrollView = _pages[_currentPageIndex];
        UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)sender;
        [zoomingScrollView handleDoubleTap:[tapRecognizer locationInView:tapRecognizer.view]];
    }
}

#pragma mark - status bar

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Calculate current page 拖动停止后刷新UI，避免多次重绘，导致内存溢出
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger index = (NSInteger) (floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self numberOfImages] - 1) index = [self numberOfImages] - 1;
    _currentPageIndex = index;
    [_indexLabel setText:[NSString stringWithFormat:@"%d/%lu", index + 1, (unsigned long)_images.count]];
    if (_imageNames && _imageNames.count > index) {
        [_nameLabel setText:_imageNames[index]];
    }
    
    //按需加载
    if (self.pages.count > index) {
        ((NYZoomingScrollView *)self.pages[index]).object = [self objectAtIndex:index];
    }
}

#pragma mark - general

- (UIViewController *)topviewController {
    UIViewController *topviewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topviewController.presentedViewController) {
        topviewController = topviewController.presentedViewController;
    }
    
    return topviewController;
}

- (UIImage*)getImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)rotateImageToCurrentOrientation:(UIImage*)image {
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        UIImageOrientation orientation = ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) ? UIImageOrientationLeft : UIImageOrientationRight;
        
        UIImage *rotatedImage = [[UIImage alloc] initWithCGImage:image.CGImage
                                                           scale:1.0
                                                     orientation:orientation];
        
        image = rotatedImage;
    }
    
    return image;
}

@end
