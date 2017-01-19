//
//  NXURLHandler.m
//  room107
//
//  Created by ningxia on 15/9/9.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "NXURLHandler.h"
#import "NSString+Encoded.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "IconMutualView.h"
#import "NSString+JSONCategories.h"

@implementation NXURLHandler

+ (NXURLHandler *)sharedInstance {
    static NXURLHandler *sharedInstace = nil;
    
    if (sharedInstace == nil) {
        sharedInstace = [[NXURLHandler alloc] init];
    }
    
    return sharedInstace;
}

- (BOOL)handleOpenURL:(NSString *)targetURL params:(NSDictionary *)params context:(id)context {
    if (targetURL && [targetURL isKindOfClass:[NSString class]]) {
//        targetURL = [targetURL URLDecodedString];
//        //包含中文的URL需要转码
//        targetURL = [targetURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    } else {
        targetURL = @"";
    }

    NSURL *url = [NSURL URLWithString:targetURL];
    if ([[url scheme] isEqualToString:@"room107"]) {
        NSString *host = [url host];
        NSString *path = [url path];
        NSString *function = [path substringFromIndex:0];
        NSString *query = [url query];
        NSDictionary *arguments = [self argumentsFromQueryString:query];
        LogDebug(@"handleOpenURL:context: - host:%@, function:%@, params:%@, arguments:%@", host, function, params, arguments);
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:params];
        //room107://houseLandlordManage?contractId=320#income
        NSString *fragment = [url fragment];
        if (fragment) {
            [dic setValue:fragment forKey:@"fragment"];
        }
        if ([host isEqualToString:@"houseManageAdd"]) {
            //发房
            if (context) {
                [dic setValue:context forKey:@"rootViewController"];
            }
        } else {
            if (arguments) {
                NSArray *keys = [arguments allKeys];
                if (keys.count > 0) {
                    for (NSUInteger i = 0; i < keys.count; i++) {
                        id object = [arguments objectForKey:[keys objectAtIndex:i]];
                        if (object) {
                            [dic setObject:object forKey:[keys objectAtIndex:i]];
                        }
                    }
                }
            }
        }
        
        if ([host isEqualToString:@"call"]) {
            //识别room107://call?uri=tel%3A52882522类型的H5中拨打电话的功能
            NSString *title = [dic[@"uri"] ? [dic[@"uri"] URLDecodedString] : @"" substringFromIndex:@"tel:".length];
            NSString *message = @"";
            NSString *cancelButtonTitle = lang(@"Cancel");
            NSString *otherTitle = lang(@"Dial");
            RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:cancelButtonTitle action:^{
            }];
            RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:otherTitle action:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dic[@"uri"] ? [dic[@"uri"] URLDecodedString] : @""]];
            }];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
            [alert show];
            
            return NO;
        } else if ([host isEqualToString:@"finishPage"]) {
            //返回到上一级
            [[(Room107ViewController *)context navigationController] popViewControllerAnimated:YES];
            
            return YES;
        } else if ([host isEqualToString:@"share"]) {
            //分享
            [self showShareViewWithParams:dic];
            
            return YES;
        } else if ([host isEqualToString:@"simplePopup"] || [host isEqualToString:@"toast"]) {
            //simplePopup或toast弹窗
            WEAK(context) weakContext = context;
            RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"OK") action:^{
                if (dic[@"url"]) {
                    [[NXURLHandler sharedInstance] handleOpenURL:dic[@"url"] params:nil context:weakContext];
                }
            }];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[dic[@"title"] URLDecodedString]
                                                            message:[dic[@"content"] URLDecodedString]
                                                   cancelButtonItem:nil
                                                   otherButtonItems:otherButtonItem, nil];
            [alert show];
            
            return YES;
        } else if ([host isEqualToString:@"selectPopup"]) {
            //selectPopup弹窗
            RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
            }];
            WEAK(context) weakContext = context;
            RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
                NSArray *URLs = dic[@"url"] ? [dic[@"url"] JSONValue] : @[];
                for (NSString *URL in URLs) {
                    [[NXURLHandler sharedInstance] handleOpenURL:URL params:nil context:weakContext];
                }
            }];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[dic[@"title"] URLDecodedString]
                                                            message:[dic[@"content"] URLDecodedString]
                                                            cancelButtonItem:cancelButtonItem
                                                   otherButtonItems:otherButtonItem, nil];
            [alert show];
            
            return YES;
        } else if ([host isEqualToString:@"silence"]) {
            //静默后台请求
            if (dic && dic[@"url"] && [dic[@"url"] isKindOfClass:[NSString class]]) {
                NSString *URLString = [dic[@"url"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSURL *strURL = [NSURL URLWithString:URLString ? URLString : @""];
                [[Client sharedClient] POSTRequestWithURL:strURL parameters:nil completion:^(Response *response, NSError *error) {
                    if (!error) {
                        
                    }
                }];
            }
            
            return YES;
        } else if ([host isEqualToString:@"main"]) {
            if (fragment && ![fragment isEqualToString:@""]) {
                //Tab的切换
                NSArray *tabKeys = @[@"home", @"houseList", @"", @"messageList", @"personal"]; //有CenterButton，所以对应于一个@""
                if ([CommonFuncs arrayHasThisContent:tabKeys andObject:fragment]) {
                    NSUInteger index = [tabKeys indexOfObject:fragment];
                    [[NSNotificationCenter defaultCenter] postNotificationName:TabBarControllerSelectedIndexDidChangeNotification object:[NSNumber numberWithUnsignedInteger:index]];

                    return YES;
                }
            }
        } else if ([host isEqualToString:@"deleteCard"]) {
            //从列表删除当前模板
            [[NSNotificationCenter defaultCenter] postNotificationName:DeleteCardNotification object:dic[@"id"]];
        }
        
        Room107ViewController *viewController = (Room107ViewController *)[self viewControllerFromModule:host];
        if (viewController != nil) {
            if (![self authorityJudge:arguments context:context]) {
                return NO;
            }
            //                [[App visibleViewController].navigationController pushViewController:viewController animated:YES];

            [viewController setValue:dic forKey:@"URLParams"];
            [context pushViewController:viewController];
        }
            
        return NO;
    }
        
    return YES;
}

- (void)showShareViewWithParams:(NSDictionary *)params {
    IconMutualView *iconMutualView = [[IconMutualView alloc] initWithIcons:@[@{@"title":@"\ue612", @"color":[UIColor room107YellowColor]}, @{@"title":@"\ue615", @"color":[UIColor room107YellowColor]}, @{@"title":@"\ue616", @"color":[UIColor room107YellowColor]}]];
    [iconMutualView setIconButtonDidClickHandler:^(NSInteger index) {
        switch (index) {
            case 0:
            case 1:
                if([WXApi isWXAppInstalled]) {
                    WXMediaMessage *message = [WXMediaMessage message];
                    message.title = [params[@"title"] URLDecodedString];
                    message.description = [params[@"content"] URLDecodedString];
                    [message setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:params[@"imageUrl"] ? params[@"imageUrl"] : @""]]]];
                    WXWebpageObject *object = [WXWebpageObject object];
                    object.webpageUrl = params[@"targetUrl"];
                    message.mediaObject = object;
                    SendMessageToWXReq *wxreq = [[SendMessageToWXReq alloc] init];
                    wxreq.message = message;
                    wxreq.bText = NO;
                    if (index == 0) {
                        wxreq.scene = WXSceneSession;
                    } else {
                        message.title = [message.title stringByAppendingFormat:@" %@", message.description];
                        wxreq.message = message;
                        wxreq.scene = WXSceneTimeline;
                    }
                    [WXApi sendReq:wxreq];
                } else {
                    [PopupView showMessage:lang(@"WXAppSharedFail")];
                }
                break;
            default:
                [App InitializeTencentOAuth];
                if ([QQApiInterface isQQInstalled]) {
                    //判断是否有qq
                    QQApiObject *message = [QQApiNewsObject objectWithURL:[NSURL URLWithString:params[@"targetUrl"] ? params[@"targetUrl"] : @""] title:[params[@"title"] URLDecodedString] description:[params[@"content"] URLDecodedString] previewImageURL:[NSURL URLWithString:params[@"imageUrl"] ? params[@"imageUrl"] : @""] targetContentType:QQApiURLTargetTypeNews];
                    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:message];
                    [QQApiInterface sendReq:req];
                } else {
                    [PopupView showMessage:lang(@"QQAppSharedFail")];
                }
                break;
        }
    }];
}

- (BOOL)authorityJudge:(NSDictionary *)arguments context:(id)context {
    //authority=login表示该页面访问需要登录权限，authority=verify表示该页面访问需要认证权限，authority=none或者缺省表示无需访问权限
    if ([arguments[@"authority"] isEqualToString:@"login"]) {
        //需要登录权限
        if (![[AppClient sharedInstance] isLogin]) {
            [[NXURLHandler sharedInstance] handleOpenURL:userLoginURI params:nil context:context];
            return NO;
        }
    } else if ([arguments[@"authority"] isEqualToString:@"verify"]) {
        //需要认证权限
        if (![[AppClient sharedInstance] isLogin]) {
            [[NXURLHandler sharedInstance] handleOpenURL:userLoginURI params:nil context:context];
            return NO;
        } else {
            if (![[AppClient sharedInstance] isAuthenticated]) {
                [[NXURLHandler sharedInstance] handleOpenURL:userVerifyURI params:nil context:context];
                return NO;
            }
        }
    }
    
    return YES;
}

//- (BOOL)handleOpenURL:(NSURL *)url context:(id)context {
//    if ([[url scheme] isEqualToString:@"room107"]) {
//        NSString *module = [url host];
//        NSString *function = [[url path] substringFromIndex:0];
//        NSDictionary *arguments = [self argumentsFromQueryString:[url query]];
//        LogDebug(@"handleOpenURL:context: - module:%@, function:%@, arguments:%@", module, function, arguments);
//        
//        if ([function isEqualToString:@"view"]) {
//            UIViewController *viewController = [self viewControllerFromModule:module];
//            if (viewController != nil) {
//                [viewController setValue:arguments forKey:@"URLArguments"];
//                [[App visibleViewController].navigationController pushViewController:viewController animated:YES];
//            }
//        } else if ([function isEqualToString:@"modify"]) {
//            SEL actionSelector = NSSelectorFromString([NSString stringWithFormat:@"modify%@:", [module stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[module  substringToIndex:1] capitalizedString]]]);
//            NSAssert(context != nil, @"%@ field should not with a nil context!", function);
//            
//            if ([context respondsToSelector:actionSelector]) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//                [context performSelector:actionSelector withObject:arguments];
//#pragma clang diagnostic pop
//            }
//        }
//        return NO;
//    }
//    return YES;
//}

- (NSDictionary *)argumentsFromQueryString:(NSString *)query {
    NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
    if (query && [query isKindOfClass:[NSString class]]) {
        query = [query URLDecodedString];
    }
    
    for (NSString *param in [query componentsSeparatedByString:@"&"]) {
        NSArray *kv = [param componentsSeparatedByString:@"="];
        if ([kv count] > 1) {
            //处理“url=http://101.200.204.65/app/html/supportCenter/submenu?type=0”的特殊情况
//            [arguments setObject:kv[1] forKey:kv[0]];
            [arguments setObject:[param substringFromIndex:[kv[0] length] + 1] forKey:kv[0]];
        }
    }

    return arguments;
}

- (UIViewController *)viewControllerFromModule:(NSString *)name {
    static NSDictionary *moduleViewControllerMap = nil;
    if (moduleViewControllerMap == nil) {
        moduleViewControllerMap = @{
            //用户账户类：
            @"userLogin":@"LoginAndRegisterViewController", //登录页
            @"userResetPassword":@"LoginAndRegisterViewController", //重置密码页（进入后自动发送验证码）
            @"userVerify":@"AuthenticateViewController", //认证页
            @"userInfo":@"MyAccountViewController", //账户设置页
            @"accountInfo":@"UserCenterViewController", //用户中心页
            @"accountBalance":@"BalanceViewController", //余额页
            @"accountWithdrawal":@"WithdrawViewController", //提现页
            @"accountCoupon":@"RedBagViewController", //红包页
            @"accountHistory":@"HistoryBalanceViewController", //历史账单页
            
            //租客类：
            @"houseSearch":@"HouseSearchViewController", //房子搜索页
            @"houseSubscribes":@"HouseSubscribesViewController", //我的订阅页
            @"manageSubscribes":@"ManageSubscribesViewController", //管理订阅页
            @"houseDetail":@"HouseDetailViewController", //房子详情页
            @"houseGetInterest":@"InterestSuiteViewController", //目标房源页
            @"contractTenantStatus":@"TenantTradingViewController", //租客合同填写页
            @"houseTenantList":@"RentalManageViewController", //租客租住管理列表页
            @"houseTenantManage":@"TenantContractManageViewController", //租客租住管理详情页
            @"houseTenantManage#expense":@"TenantContractManageViewController", //租客租住管理详情页
            @"houseTenantManage#income":@"TenantContractManageViewController", //租客租住管理详情页
            @"houseTenantManage#info":@"TenantContractManageViewController", //租客租住管理详情页
            
            //房东类：
            @"houseManageAdd":@"PostSuiteViewController", //发房页
            @"houseManageStatus":@"SuiteManageViewController", //理房页
            @"contractLandlordStatus":@"LandlordTradingViewController", //房东合同填写页
            @"houseLandlordList":@"HouseLandlordListViewController", //房东出租管理列表页
            @"houseLandlordManage":@"LandlordContractManageViewController", //房东出租管理详情页
            @"houseLandlordManage#expense":@"LandlordContractManageViewController", //房东租住管理详情页
            @"houseLandlordManage#income":@"LandlordContractManageViewController", //房东租住管理详情页
            @"houseLandlordManage#info":@"LandlordContractManageViewController", //房东租住管理详情页
            
            //主页类：
            @"home":@"HomeViewController", //首页
            @"main":@"HomeViewController", //首页
            @"main#home":@"HomeViewController", //首页
            @"main#houseList":@"HouseSearchViewController", //房子搜索页
            @"main#landlordManageList":@"HouseLandlordListViewController", //房东出租管理列表页
            @"personal":@"IndividualViewController", //个人页
            @"main#personal":@"IndividualViewController", //个人页
            @"main#messageList":@"MessageListViewController", //消息列表页
            
            //辅助功能类：
            @"feedback":@"SuggestionViewController", //反馈页
            @"messageCenter":@"MessageCenterViewController", //消息中心页
            @"messageSublist":@"MessageSublistViewController", //消息分类列表页
            @"messageDetail":@"MessageDetailViewController", //消息详情页
            @"helpCenter":@"HelpCenterViewController", //客服与帮助页
            @"about":@"AboutViewController", //关于页
            
            //特殊类：
            @"html":@"NXWebViewController" //html页面
        };
    }
    
    return [[NSClassFromString(moduleViewControllerMap[name]) alloc] init] ;
}

@end
