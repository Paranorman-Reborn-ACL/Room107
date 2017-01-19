//
//  HistoryBalanceViewController.m
//  room107
//
//  Created by Naitong Yu on 15/9/14.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "HistoryBalanceViewController.h"
#import "InventoryItemView.h"
#import "UserAccountAgent.h"

@interface HistoryBalanceViewController ()

@property (nonatomic) UILabel *historyBalanceDetailTextLabel;

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray *historyBalanceItems;
@property (nonatomic, strong) NSNumber *contractID;

@end

@implementation HistoryBalanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:_scrollView];
    
    _historyBalanceDetailTextLabel = [[UILabel alloc] init];
    [_historyBalanceDetailTextLabel  setBackgroundColor:[UIColor whiteColor]];
    _historyBalanceDetailTextLabel.textColor = [UIColor room107GrayColorC];
    _historyBalanceDetailTextLabel.font = [UIFont room107SystemFontTwo];
    _historyBalanceDetailTextLabel.hidden = YES;
    [_historyBalanceDetailTextLabel setHidden:YES];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self.title stringByAppendingString:lang(@"Details")]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    [paragraphStyle setFirstLineHeadIndent:22];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    _historyBalanceDetailTextLabel.attributedText = attributedString;
    [self.scrollView addSubview:_historyBalanceDetailTextLabel];
    
    _historyBalanceItems = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadData];
}

- (id)initWithContractID:(NSNumber *)contractID {
    self = [super init];
    if (self != nil) {
        _contractID = contractID;
    }
    
    return self;
}

- (void)loadData {
    [self showLoadingView];
    if (_contractID) {
        [[UserAccountAgent sharedInstance] getContractHistoryBillsInfoWithContractID:_contractID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *historyBillsInfo) {
            [self refreshUIWithHistoryBillsInfo:historyBillsInfo andErrorTitle:errorTitle andErrorMsg:errorMsg andErrorCode:errorCode];
        }];
    } else {
        [[UserAccountAgent sharedInstance] getHistoryBillsInfoWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *historyBillsInfo) {
            [self refreshUIWithHistoryBillsInfo:historyBillsInfo andErrorTitle:errorTitle andErrorMsg:errorMsg andErrorCode:errorCode];
        }];
    }
}

- (void)refreshUIWithHistoryBillsInfo:(NSDictionary *)historyBillsInfo andErrorTitle:(NSString *)errorTitle andErrorMsg:(NSString *)errorMsg andErrorCode:(NSNumber *)errorCode {
    [self hideLoadingView];
    if (errorTitle || errorMsg) {
        [PopupView showTitle:errorTitle message:errorMsg];
    }
                
    if (!errorCode) {
        [self refreshDataWithHistoryBillsInfo:historyBillsInfo];
    } else {
        if ([self isLoginStateError:errorCode]) {
            return;
        }
        
        WEAK_SELF weakSelf = self;
        if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
            [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                [weakSelf loadData];
            }];
        } else {
            [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                [weakSelf loadData];
            }];
        }
    }
}

- (void)refreshDataWithHistoryBillsInfo:(NSDictionary *)historyBillsInfo {
    for (UIView *historyItemView in self.historyBalanceItems) {
        [historyItemView removeFromSuperview];
    }
    [self.historyBalanceItems removeAllObjects];
    
    NSArray *histories = historyBillsInfo[@"histories"];
    if (histories && [histories count] > 0) {
        self.historyBalanceDetailTextLabel.hidden = NO;
        for (NSDictionary *inventory in histories) {
            NSString *title = inventory[@"title"];
            NSString *date = inventory[@"date"];
            double amount = [inventory[@"amount"] doubleValue] / 100.0f;
            InventoryItemView *inventoryItem = [[InventoryItemView alloc] initWithTitle:title date:date amount:amount];
            [self.historyBalanceItems addObject:inventoryItem];
            [self.scrollView addSubview:inventoryItem];
        }
    } else {
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        [self showContent:lang(@"NoHistoryBalance") withFrame:frame];
    }
    
    [self.view setNeedsLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    _scrollView.frame = CGRectMake(0, 0, width, height);
    CGFloat originY = 0;

    [_historyBalanceDetailTextLabel setFrame:CGRectMake(0, 0, width, 36)];
    
    originY = CGRectGetMaxY(_historyBalanceDetailTextLabel.frame);
    
    for (InventoryItemView *inventoryItemView in self.historyBalanceItems) {
        inventoryItemView.frame = CGRectMake(0, originY, width, [inventoryItemView getHeight]);
        originY += [inventoryItemView getOriginY];
    }
    
    _scrollView.contentSize = CGSizeMake(width, originY + 11);
}

@end
