//
//  SDCycleScrollView.m
//  SDCycleScrollView
//
//  Created by aier on 15-3-22.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

/**
 
 *******************************************************
 *                                                      *
 * 感谢您的支持， 如果下载的代码在使用过程中出现BUG或者其他问题    *
 * 您可以发邮件到gsdios@126.com 或者 到                       *
 * https://github.com/gsdios?tab=repositories 提交问题     *
 *                                                      *
 *******************************************************
 
 */


#import "SDCycleScrollView.h"
#import "SDCollectionViewCell.h"
#import "UIView+SDExtension.h"
#import "TAPageControl.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

NSString * const ID = @"cycleCell";

@interface SDCycleScrollView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView *mainView; // 显示图片的collectionView
@property (nonatomic, weak) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray *imagesGroup;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) NSInteger totalItemsCount;
@property (nonatomic, weak) UIControl *pageControl;
@property (nonatomic, strong) void (^viewDidScrollHandler)(NSInteger index);

@end

@implementation SDCycleScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
        [self setupMainView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialization];
        [self setupMainView];
    }
    return self;
}

- (void)initialization
{
    _pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    _autoScrollTimeInterval = 3.0;
    _titleLabelTextColor = [UIColor whiteColor];
    _titleLabelTextFont= [UIFont systemFontOfSize:14];
    _titleLabelBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _titleLabelHeight = 30;
    _autoScroll = YES;
    _infiniteLoop = YES;
    _showPageControl = YES;
    _pageControlDotSize = CGSizeMake(10, 10);
    _pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    _hidesForSinglePage = YES;
    _sourceViewHeight = 0;
    
//    self.backgroundColor = [UIColor lightGrayColor];
    _placeholderImageContentMode = UIViewContentModeScaleToFill;
}

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame imagesGroup:(NSArray *)imagesGroup
{
    SDCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.imagesGroup = [NSMutableArray arrayWithArray:imagesGroup];
    return cycleScrollView;
}

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame imageURLStringsGroup:(NSArray *)imageURLsGroup
{
    SDCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.imageURLStringsGroup = [NSMutableArray arrayWithArray:imageURLsGroup];
    return cycleScrollView;
}

// 设置显示图片的collectionView
- (void)setupMainView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = self.frame.size;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout = flowLayout;
    
    UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    mainView.backgroundColor = [UIColor clearColor];
    mainView.pagingEnabled = YES;
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.showsVerticalScrollIndicator = NO;
    [mainView registerClass:[SDCollectionViewCell class] forCellWithReuseIdentifier:ID];
    mainView.dataSource = self;
    mainView.delegate = self;
    [self addSubview:mainView];
    _mainView = mainView;
}


#pragma mark - properties


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _flowLayout.itemSize = self.frame.size;
}

- (void)setPageControlDotSize:(CGSize)pageControlDotSize
{
    _pageControlDotSize = pageControlDotSize;
    [self setupPageControl];
    if ([self.pageControl isKindOfClass:[TAPageControl class]]) {
        TAPageControl *pageContol = (TAPageControl *)_pageControl;
        pageContol.dotSize = pageControlDotSize;
    }
}

- (void)setShowPageControl:(BOOL)showPageControl
{
    _showPageControl = showPageControl;
    
    _pageControl.hidden = !showPageControl;
}

- (void)setDotColor:(UIColor *)dotColor
{
    _dotColor = dotColor;
    if ([self.pageControl isKindOfClass:[TAPageControl class]]) {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        pageControl.dotColor = dotColor;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPageIndicatorTintColor = dotColor;
    }
    
}

-(void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    [_timer invalidate];
    _timer = nil;
    
    if (_autoScroll) {
        [self setupTimer];
    }
}

- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval
{
    _autoScrollTimeInterval = autoScrollTimeInterval;
    
    [self setAutoScroll:self.autoScroll];
}

- (void)setPageControlStyle:(SDCycleScrollViewPageContolStyle)pageControlStyle
{
    _pageControlStyle = pageControlStyle;
    
    [self setupPageControl];
}

- (void)setImagesGroup:(NSMutableArray *)imagesGroup
{
    _imagesGroup = imagesGroup;
    
    _totalItemsCount = self.infiniteLoop ? self.imagesGroup.count * 100 : self.imagesGroup.count;
    
    if (imagesGroup.count != 1) {
        self.mainView.scrollEnabled = YES;
        [self setAutoScroll:self.autoScroll];
    } else {
        self.mainView.scrollEnabled = NO;
    }
    
    [self setupPageControl];
    [self.mainView reloadData];
}

- (void)setImageURLStringsGroup:(NSArray *)imageURLStringsGroup
{
    _imageURLStringsGroup = imageURLStringsGroup;
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:imageURLStringsGroup.count];
    for (int i = 0; i < imageURLStringsGroup.count; i++) {
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageURLStringsGroup[i]];
        if (!image) {
            image = [[UIImage alloc] init];
        }
        [images addObject:image];
    }
    self.imagesGroup = images;
    //此时，不需要加载所有图片，避免内存消耗
//    [self loadImageWithImageURLsGroup:imageURLStringsGroup];
}

- (void)setLocalizationImagesGroup:(NSArray *)localizationImagesGroup
{
    _localizationImagesGroup = localizationImagesGroup;
    self.imagesGroup = [NSMutableArray arrayWithArray:localizationImagesGroup];
}

#pragma mark - actions

- (void)loadImageWithImageURLsGroup:(NSArray *)imageURLsGroup
{
    for (int i = 0; i < imageURLsGroup.count; i++) {
        [self loadImageAtIndex:i];
    }
}

- (void)loadImageAtIndex:(NSInteger)index
{
    NSString *urlStr = self.imageURLStringsGroup[index];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlStr];
    if (image) {
        [self.imagesGroup setObject:image atIndexedSubscript:index];
        //避免部分图片无法及时刷新的问题
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainView reloadData];
        });
    } else {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if (image) {
                if (index < self.imageURLStringsGroup.count && [self.imageURLStringsGroup[index] isEqualToString:urlStr]) {
                    // 修复频繁刷新异步数组越界问题
                    [self.imagesGroup setObject:image atIndexedSubscript:index];
                    
                    if (_viewDidScrollHandler) {
                        _viewDidScrollHandler(index);
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.mainView reloadData];
                    });
                }
            }
        }];
    }
}


- (void)setupPageControl
{
    if (_pageControl) [_pageControl removeFromSuperview]; // 重新加载数据时调整
    
    if ((self.imagesGroup.count <= 1) && self.hidesForSinglePage) {
        return;
    }
    
    switch (self.pageControlStyle) {
        case SDCycleScrollViewPageContolStyleAnimated:
        {
            TAPageControl *pageControl = [[TAPageControl alloc] init];
            pageControl.numberOfPages = self.imagesGroup.count;
            pageControl.dotColor = self.dotColor;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
            
        case SDCycleScrollViewPageContolStyleClassic:
        {
            UIPageControl *pageControl = [[UIPageControl alloc] init];
            pageControl.numberOfPages = self.imagesGroup.count;
            pageControl.currentPageIndicatorTintColor = self.dotColor;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
            
        default:
            break;
    }
    
    
}


- (void)automaticScroll
{
    if (0 == _totalItemsCount) return;
    int currentIndex = _mainView.contentOffset.x / _flowLayout.itemSize.width;
    int targetIndex = currentIndex + 1;
    if (targetIndex == _totalItemsCount) {
        if (self.infiniteLoop) {
            targetIndex = _totalItemsCount * 0.5;
        }else{
            targetIndex = 0;
        }
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void)setupTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark - life circles

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _flowLayout.itemSize = self.frame.size;
    
    _mainView.frame = self.bounds;
    if (_mainView.contentOffset.x == 0 &&  _totalItemsCount) {
        int targetIndex = 0;
        if (self.infiniteLoop) {
            targetIndex = _totalItemsCount * 0.5;
        }else{
            targetIndex = 0;
        }
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    CGSize size = CGSizeZero;
    if ([self.pageControl isKindOfClass:[TAPageControl class]]) {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        size = [pageControl sizeForNumberOfPages:self.imagesGroup.count];
    } else {
        size = CGSizeMake(self.imagesGroup.count * self.pageControlDotSize.width * 1.2, self.pageControlDotSize.height);
    }
    CGFloat x = (self.sd_width - size.width) * 0.5;
    if (self.pageControlAliment == SDCycleScrollViewPageContolAlimentRight) {
        x = self.mainView.sd_width - size.width - 10;
    }
    CGFloat y = self.mainView.sd_height - size.height - 10;
    
    if ([self.pageControl isKindOfClass:[TAPageControl class]]) {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        [pageControl sizeToFit];
    }
    
    _pageControl.frame = CGRectMake(x, y, size.width, size.height);
    _pageControl.hidden = !_showPageControl;
    
    [_mainView reloadData];
}

//解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [_timer invalidate];
        _timer = nil;
    }
}

//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    _mainView.delegate = nil;
    _mainView.dataSource = nil;
}

#pragma mark - public actions


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _totalItemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SDCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    CGRect frame = cell.frame;
    //重置cell.imageView的frame，避免部分图片显示比例异常
    frame.origin = CGPointMake(0, 0);
    [cell.imageView setFrame:frame];
    long itemIndex = indexPath.item % self.imagesGroup.count;
    if (_imageURLStringsGroup.count > itemIndex) {
        cell.imageView.contentMode = _placeholderImageContentMode;
        NSURL *imageURL = [NSURL URLWithString:_imageURLStringsGroup[itemIndex]];
        if (_sourceViewHeight > 0) {
            //由外部窗口指定高度
            imageURL = [NSURL URLWithString:[_imageURLStringsGroup[itemIndex] stringByAppendingString:[NSString stringWithFormat:@"%@%.f", imageView2Thumbnails, ([CommonFuncs indexOfDeviceScreen] == 3 ? 3 : 2) * _sourceViewHeight]]];
        }
        [cell.imageView sd_setImageWithURL:imageURL placeholderImage:_placeholderImage options:SDWebImageRetryFailed | SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                if (_imagesGroup.count > itemIndex) {
                    [_imagesGroup replaceObjectAtIndex:itemIndex withObject:image];
                }
                
                if (_viewDidScrollHandler && (itemIndex == _indexOnPageControl)) {
                    _viewDidScrollHandler(itemIndex);
                }
                [self resetImageViewFrame:cell andImage:image];
            }
        }];
    } else {
        if (_localizationImagesGroup.count > itemIndex) {
            [self resetImageViewFrame:cell andImage:_localizationImagesGroup[itemIndex]];
        }
    }
    
    if (_titlesGroup.count) {
        cell.title = _titlesGroup[itemIndex];
    }
    
    if (!cell.hasConfigured) {
        cell.titleLabelBackgroundColor = self.titleLabelBackgroundColor;
        cell.titleLabelHeight = self.titleLabelHeight;
        cell.titleLabelTextColor = self.titleLabelTextColor;
        cell.titleLabelTextFont = self.titleLabelTextFont;
        cell.hasConfigured = YES;
    }
    
    return cell;
}

- (void)resetImageViewFrame:(SDCollectionViewCell *)cell andImage:(UIImage *)image {
    cell.imageView.contentMode = UIViewContentModeScaleToFill;
    [cell.imageView setImage:image];
    CGRect frame = cell.frame;
    CGPoint center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
    frame.size.width = image.size.width * frame.size.height / image.size.height;
    [cell.imageView setFrame:frame];
    [cell.imageView setCenter:center];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)]) {
        [self.delegate cycleScrollView:self didSelectItemAtIndex:indexPath.item % self.imagesGroup.count];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int itemIndex = (scrollView.contentOffset.x + self.mainView.sd_width * 0.5) / self.mainView.sd_width;
    if (!self.imagesGroup.count) return; // 解决清除timer时偶尔会出现的问题
    int index = itemIndex % self.imagesGroup.count;
    
    if (_viewDidScrollHandler && (index != _indexOnPageControl)) {
        _indexOnPageControl = index;
        _viewDidScrollHandler(_indexOnPageControl);
    }
    
    if ([self.pageControl isKindOfClass:[TAPageControl class]]) {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        pageControl.currentPage = index;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPage = index;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.autoScroll) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.autoScroll) {
        [self setupTimer];
    }
}

- (void)setViewDidScrollHandler:(void(^)(NSInteger index))handler {
    _viewDidScrollHandler = handler;
}

@end
