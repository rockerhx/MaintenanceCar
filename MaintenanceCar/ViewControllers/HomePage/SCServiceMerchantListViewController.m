//
//  SCServiceMerchantListViewController.m
//  MaintenanceCar
//
//  Created by ShiCang on 15/2/2.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import "SCServiceMerchantListViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "SCMerchant.h"
#import "SCMerchantListCell.h"
#import "SCLocationManager.h"
#import "SCMerchantDetailViewController.h"
#import "SCMapViewController.h"
#import "SCMerchantFilterView.h"
#import "SCStarView.h"
#import "SCAllDictionary.h"

@interface SCServiceMerchantListViewController () <UITableViewDelegate, UITableViewDataSource, SCMerchantFilterViewDelegate>
{
    NSMutableArray *_merchantList;
    
    NSString       *_requestQuery;
    NSString       *_distanceCondition;
}

@property (nonatomic, assign) NSInteger      offset;        // 商家列表请求偏移量，用户上拉刷新的分页请求操作

@end

@implementation SCServiceMerchantListViewController

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
    // 用户行为统计，页面停留时间
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[NSString stringWithFormat:@"[%@] - 列表", self.title]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _merchantFilterView.isWash = _isWash;
}

- (void)viewWillDisappear:(BOOL)animated
{
    // 用户行为统计，页面停留时间
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:[NSString stringWithFormat:@"[%@] - 列表", self.title]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
    
    __weak typeof(self) weakSelf = self;
    // 添加上拉刷新控件
    [_tableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf upRefreshMerchantList];
    }];
    
    [self refreshMerchantList];
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _merchantList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCMerchantListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SCMerchantListCell" forIndexPath:indexPath];
    // 刷新商家列表，设置相关数据
    [cell handelWithMerchant:_merchantList[indexPath.row]];
    
    return cell;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 列表栏被点击，执行取消选中动画
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 根据选中的商家，取到其商家ID，跳转到商家页面进行详情展示
    SCMerchantDetailViewController *merchantDetialViewControler = [STORY_BOARD(@"Main") instantiateViewControllerWithIdentifier:@"SCMerchantDetailViewController"];
    merchantDetialViewControler.merchant = _merchantList[indexPath.row];
    [self.navigationController pushViewController:merchantDetialViewControler animated:YES];
}

#pragma mark - Action Methods
- (IBAction)mapItemPressed:(UIBarButtonItem *)sender
{
    // 地图按钮被点击，跳转到地图页面
    UINavigationController *mapNavigationController = [STORY_BOARD(@"Main") instantiateViewControllerWithIdentifier:@"SCMapViewNavigationController"];
    SCMapViewController *mapViewController = (SCMapViewController *)mapNavigationController.topViewController;
    mapViewController.merchants = _merchantList;
    mapNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:mapNavigationController animated:YES completion:nil];
}

- (void)setQuery:(NSString *)query
{
    _query = query;
    _requestQuery = query;
}

#pragma mark - Private Methods
/**
 *  初始化配置，列表设置，全局变量初始化都放在这里
 */
- (void)initConfig
{
    _offset                      = 0;                   // 第一次进入商家列表列表请求偏移量必须为0
    _distanceCondition           = MerchantListRadius;

    _merchantList                = [@[] mutableCopy];   // 商家列表容器初始化
    _merchantFilterView.delegate = self;
}

- (void)viewConfig
{
    _tableView.scrollsToTop      = YES;
    _tableView.tableFooterView   = [[UIView alloc] init];       // 设置footer视图，防止数据不够，显示多余的列表栏
    
    [_merchantFilterView.otherFilterButton setTitle:self.title forState:UIControlStateNormal];
}

- (void)refreshMerchantList
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];      // 加载响应式控件
    
    __weak typeof(self) weakSelf = self;
    [[SCLocationManager share] getLocationSuccess:^(BMKUserLocation *userLocation, NSString *latitude, NSString *longitude) {
        [weakSelf startMerchantListRequestWithLatitude:latitude longitude:longitude];
    } failure:^(NSString *latitude, NSString *longitude, NSError *error) {
        [weakSelf showHUDAlertToViewController:weakSelf.navigationController text:@"定位失败，采用当前城市中心坐标!" delay:0.5f];
        [weakSelf startMerchantListRequestWithLatitude:latitude longitude:longitude];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"定位失败，请检查您的定位服务是否打开：设置->隐私->定位服务"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

- (void)upRefreshMerchantList
{
    SCLocationManager *locationManager = [SCLocationManager share];
    [self startMerchantListRequestWithLatitude:locationManager.latitude longitude:locationManager.longitude];
}

/**
 *  商家列表数据请求方法，参数：query, limit, offset, radius, longtitude, latitude
 */
- (void)startMerchantListRequestWithLatitude:(NSString *)latitude longitude:(NSString *)longitude
{
    __weak typeof(self) weakSelf = self;
    // 配置请求参数
    NSDictionary *parameters     = @{@"query"     : _requestQuery,
                                     @"limit"     : @(MerchantListLimit),
                                     @"offset"    : @(_offset),
                                     @"radius"    : _distanceCondition,
                                     @"longtitude": longitude,
                                     @"latitude"  : latitude};
    
    [[SCAPIRequest manager] startMerchantListAPIRequestWithParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf.tableView.footer endRefreshing];
        if (operation.response.statusCode == SCAPIRequestStatusCodeGETSuccess)
        {
            NSArray *list = [[responseObject objectForKey:@"result"] objectForKey:@"items"];
            
            if (list.count)
            {
                // 遍历请求回来的商家数据，生成SCMerchant用于商家列表显示
                [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    SCMerchant *merchant = [[SCMerchant alloc] initWithDictionary:obj[@"fields"] error:nil];
                    [_merchantList addObject:merchant];
                }];
                [_tableView reloadData];                                   // 数据配置完成，刷新商家列表
                _offset += MerchantListLimit;                              // 偏移量请求参数递增
            }
            else
            {
                [weakSelf showHUDAlertToViewController:weakSelf.navigationController text:@"优质商家陆续添加中..." delay:0.5f];
                [_tableView reloadData];
            }
            _merchantFilterView.hidden = NO;
        }
        else
            NSLog(@"status code error:%@", [NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode]);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];              // 请求完成，移除响应式控件
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get merchant list request error:%@", error);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}

#pragma mark - SCMerchantFilterViewDelegate Methods
- (void)didSelectedFilterCondition:(id)item type:(SCFilterType)type
{
    NSString *filterName      = item[DisplayNameKey];
    NSString *filterCondition = item[RequestValueKey];

    _offset                   = 0;
    [_merchantList removeAllObjects];
    
    SCAllDictionary *allDictionary = [SCAllDictionary share];
    allDictionary.repairCondition  = @"";
    allDictionary.otherCondition   = @"";
    // 筛选条件，选择之后触发请求
    switch (type) {
        case SCFilterTypeRepair:
        {
            if ([filterCondition isEqualToString:@"default"])
                allDictionary.repairCondition = @"";
            else
                allDictionary.repairCondition = [NSString stringWithFormat:@" AND majors:'%@'", filterCondition];
        }
            break;
        case SCFilterTypeOther:
        {
            if (![filterCondition isEqualToString:@"default"])
            {
                if ([filterCondition isEqualToString:@"tag"])
                    allDictionary.otherCondition = [NSString stringWithFormat:@" AND tags:'%@'", filterName];
                else
                    allDictionary.otherCondition = [NSString stringWithFormat:@" AND service:'%@'", filterCondition];
            }
            else
                allDictionary.otherCondition = @"";
        }
            break;
            
        default:
            _distanceCondition = [filterCondition isEqualToString:@"default"] ? MerchantListRadius : filterCondition;
            break;
    }
    _requestQuery = [NSString stringWithFormat:@"%@%@%@", _query, allDictionary.repairCondition, allDictionary.otherCondition];
    [self refreshMerchantList];
}

@end