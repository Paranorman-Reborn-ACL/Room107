//
//  SuiteCotenantGuideTableViewCell.m
//  room107
//
//  Created by ningxia on 16/3/2.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SuiteCotenantGuideTableViewCell.h"
#import "ThirteenTemplateView.h"
#import "UserAvatarCollectionViewCell.h"
#import "YellowColorTextLabel.h"
#import "RoundedGreenButton.h"

static CGFloat originX = 11;
static CGFloat originY = 11;
static CGFloat spaceY = 20;
static CGFloat titleViewHeight = 36.5;
static CGFloat avatarViewWidth = 55;
static NSString *identifier = @"UserAvatarCollectionViewCell";

@interface SuiteCotenantGuideTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) RoundedGreenButton *cotenantGuideButton;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) YellowColorTextLabel *guideContentLabel;
@property (nonatomic, strong) NSMutableArray *cotenants;
@property (nonatomic, strong) void (^cotenantGuideButtonDidClickHandlerBlock)();
@property (nonatomic, strong) void (^cotenantAvatarDidClickHandlerBlock)(NSUInteger index);

@end

@implementation SuiteCotenantGuideTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView setBackgroundColor:[UIColor room107GrayColorA]];
        
        CGFloat viewWidth = CGRectGetWidth([self cellFrame]);
        _containerView = [[UIView alloc] initWithFrame:(CGRect){0, originY, viewWidth, suiteCotenantGuideTableViewCellMinHeight}];
        [_containerView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_containerView];
        _containerView.hidden = YES;
        
        ThirteenTemplateView *titleView = [[ThirteenTemplateView alloc] initWithFrame:(CGRect){0, 0, viewWidth, 36} andTemplateDataDictionary:@{@"image":@"trim.png", @"text":lang(@"CotenantGuide")}];
        [_containerView addSubview:titleView];
        
        CGFloat buttonWidth = 85;
        CGFloat buttonHeight = 25;
        _cotenantGuideButton = [[RoundedGreenButton alloc] initWithFrame:(CGRect){CGRectGetWidth([self cellFrame]) - originX - buttonWidth, originY / 2, buttonWidth, buttonHeight}];
        [_cotenantGuideButton.titleLabel setFont:[UIFont room107SystemFontTwo]];
        [_cotenantGuideButton setTitle:lang(@"RentSingleRoom") forState:UIControlStateNormal];
        [_containerView addSubview:_cotenantGuideButton];
        [_cotenantGuideButton addTarget:self action:@selector(cotenantGuideButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect frame = (CGRect){0, originY + CGRectGetHeight(titleView.bounds) + spaceY, CGRectGetWidth([self cellFrame]), avatarViewWidth};
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, [self originLeftX], 0, [self originLeftX]);
        collectionViewLayout.minimumLineSpacing = 22; //每一行之间的间隔
        collectionViewLayout.itemSize = CGSizeMake(avatarViewWidth, avatarViewWidth);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:collectionViewLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UserAvatarCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView setCollectionViewLayout:collectionViewLayout];
        [_containerView addSubview:_collectionView];
        
        _guideContentLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){originX, originY + CGRectGetHeight(titleView.bounds) + 10, [self maxContentWidth], 15} withTitle:@""];
        [_guideContentLabel setFont:[UIFont room107SystemFontOne]];
        [_containerView addSubview:_guideContentLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, suiteCotenantGuideTableViewCellMinHeight);
}

- (void)setContent:(NSString *)content andCotenants:(NSMutableArray *)cotenants {
    if (content && ![content isEqualToString:@""]) {
        _containerView.hidden = NO;
    }
    
    CGRect guideContentLabelFrame = _guideContentLabel.frame;
    if (cotenants.count > 0) {
        guideContentLabelFrame.origin.y = titleViewHeight + spaceY + avatarViewWidth + spaceY;
    } else {
        guideContentLabelFrame.origin.y = titleViewHeight + spaceY;
    }
    guideContentLabelFrame.size.height = [CommonFuncs rectWithText:content ? content : @"" andMaxDisplayWidth:[self maxContentWidth] andAttributes:[self attributes]].size.height + 5;
    [_guideContentLabel setFrame:guideContentLabelFrame];
    [_guideContentLabel setTitle:content withTitleColor:[UIColor room107GrayColorD] withAlignment:NSTextAlignmentLeft];
    
    CGRect containerViewFrame = _containerView.frame;
    containerViewFrame.size.height = [self getCellHeightWithContent:content andCotenants:cotenants] - originY;
    [_containerView setFrame:containerViewFrame];
}

- (CGFloat)maxContentWidth {
    return CGRectGetWidth([self cellFrame]) - originX * 2;
}

- (NSDictionary *)attributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5; //字体的行间距
    return @{NSFontAttributeName:[UIFont room107SystemFontOne],
             NSParagraphStyleAttributeName:paragraphStyle};
}

- (CGFloat)getCellHeightWithContent:(NSString *)content andCotenants:(NSMutableArray *)cotenants {
    CGFloat cellHeight = suiteCotenantGuideTableViewCellMinHeight + [CommonFuncs rectWithText:content ? content : @"" andMaxDisplayWidth:[self maxContentWidth] andAttributes:[self attributes]].size.height + 5;
    if (cotenants.count > 0) {
        cellHeight += avatarViewWidth + spaceY;
        _cotenants = cotenants;
        [_collectionView reloadData];
    }
    
    return cellHeight;
}

- (void)setCotenantGuideButtonDidClickHandler:(void(^)())handler {
    _cotenantGuideButtonDidClickHandlerBlock = handler;
}

- (void)setCotenantAvatarDidClickHandler:(void(^)(NSUInteger index))handler {
    _cotenantAvatarDidClickHandlerBlock = handler;
}

- (IBAction)cotenantGuideButtonDidClick:(id)sender {
    if (_cotenantGuideButtonDidClickHandlerBlock) {
        _cotenantGuideButtonDidClickHandlerBlock();
    }
}

- (void)refreshCotenantGuideButtonStatusByIsCotenant:(BOOL)isCotenant {
    NSString *buttonTitle = isCotenant ? lang(@"MarkedInterest") : lang(@"RentSingleRoom");
    UIColor *buttonBackgroundColor = isCotenant ? [UIColor room107YellowColor] : [UIColor room107GreenColor];
    [_cotenantGuideButton setBackgroundColor:buttonBackgroundColor];
    [_cotenantGuideButton setTitle:buttonTitle forState:UIControlStateNormal];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _cotenants.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserAvatarCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (_cotenants.count > indexPath.row) {
        [cell setAvatarImageURL:_cotenants[indexPath.row][@"favicon"] ? _cotenants[indexPath.row][@"favicon"] : @""];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_cotenantAvatarDidClickHandlerBlock) {
        _cotenantAvatarDidClickHandlerBlock(indexPath.row);
    }
}

@end
