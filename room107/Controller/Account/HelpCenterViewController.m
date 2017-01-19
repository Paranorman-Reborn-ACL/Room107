//
//  HelpCenterViewController.m
//  room107
//
//  Created by 107间 on 16/4/14.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "HelpCenterViewController.h"
#import "TwoTemplateTableViewCell.h"
#import "SystemAgent.h"
#import "TemplateViewFuncs.h"
#import "NSString+JSONCategories.h"
#import "NSDictionary+JSONString.h"

@interface HelpCenterViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) UITableView *sectionsTableView;


@end

@implementation HelpCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:lang(@"ServiceAndHelp")];
    [self getHelpCentInfo];
    
    //监听当前页面列表删除卡片
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCard:) name:DeleteCardNotification object:nil];
}

- (void)deleteCard:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        //判断当前窗口是否可视
        NSNumber *cardID = [notification object];
        [TemplateViewFuncs deleteCardByCardID:cardID andTableView:_sectionsTableView andData:_sections];
    }
}


- (void)getHelpCentInfo {
    [self showLoadingView];
    WEAK_SELF weakSelf = self;
    [[SystemAgent sharedInstance] getHelpCenter:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards) {
        [weakSelf hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        if (!errorCode) {
            if (!_sectionsTableView) {
                weakSelf.sectionsTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
                _sectionsTableView.delegate = self;
                _sectionsTableView.dataSource = self;
                [_sectionsTableView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
                [_sectionsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
                [self.view addSubview:_sectionsTableView];
            }
            weakSelf.sections = [TemplateViewFuncs cardsDataConvert:cards];
            [weakSelf.sectionsTableView reloadData];
        } else {
            if (_sectionsTableView) {
                
            } else {
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                        [weakSelf showLoadingView];
                        [weakSelf getHelpCentInfo];
                    }];
                } else {
                    [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                        [weakSelf getHelpCentInfo];
                    }];
                }

            }
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [TemplateViewFuncs numberOfRowsByData:_sections[section]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_sections && _sections.count > indexPath.section && [TemplateViewFuncs numberOfRowsByData:_sections[indexPath.section]] > indexPath.row) {
        return [TemplateViewFuncs tableViewCellByData:_sections[indexPath.section] atIndex:indexPath.row andTableView:tableView andViewController:self];
    }
    
    return [Room107TableViewCell new];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return twoTemplateTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 11;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //若tableView是Group类型 返回值是0,则会返回默认值  所以保证隐藏footerInsection 给一极小值。
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_sections && _sections.count > indexPath.section && [TemplateViewFuncs numberOfRowsByData:_sections[indexPath.section]] > indexPath.row) {
        [TemplateViewFuncs goToTargetPageByData:_sections[indexPath.section] atIndex:indexPath.row andViewController:self];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]};
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [headerView setBackgroundColor:[UIColor room107GrayColorA]];
    
    return headerView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
