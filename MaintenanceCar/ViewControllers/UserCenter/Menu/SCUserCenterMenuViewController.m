//
//  SCUserCenterMenuViewController.m
//  MaintenanceCar
//
//  Created by Andy on 15/7/22.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "SCUserCenterMenuViewController.h"
#import "SCStoryBoardManager.h"
#import "SCUserView.h"
#import "SCUserCenterUserCarCell.h"
#import "SCUserCenterAddCarCell.h"
#import "SCUserCenterCell.h"
#import "SCUserCenterViewModel.h"
#import "SCAddCarViewController.h"


static CGFloat CellHeight = 44.0f;


@interface SCUserCenterMenuViewController () <SCUserViewDelegate, SCUserCenterUserCarCellDelegate> {
    SCUserCenterViewModel *_viewModel;
}
@end

@implementation SCUserCenterMenuViewController

#pragma mark - Init Methods
+ (instancetype)instance {
    return [SCStoryBoardManager viewControllerWithClass:self storyBoardName:SCStoryBoardNameUserCenter];
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    [NOTIFICATION_CENTER addObserver:self selector:@selector(reloadUserCars) name:kUserCarsDataNeedReloadSuccessNotification object:nil];
    
    _viewModel = [SCUserCenterViewModel instance];
    @weakify(self);
    [RACObserve([SCUserInfo share], loginState) subscribeNext:^(NSNumber *loginState) {
        @strongify(self);
        [self reloadUserCars];
    }];
    [RACObserve(_viewModel, needRefresh) subscribeNext:^(id x) {
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

- (void)viewConfig {
}

#pragma mark - Private Methods
- (void)reloadData {
    [_userView refreshByViewModel:[_viewModel reload]];
    [_carAmountLabel setText:[@(_viewModel.userCarItems.count-1) stringValue]];
    [_tableView setTableHeaderView:[SCUserInfo share].loginState ? _carAmountPromptView : nil];
    [_tableView reloadData];
}

- (void)hideMenu {
    [self.frostedViewController hideMenuViewController];
}

- (void)reloadUserCars {
    [_viewModel reloadCars];
}

#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _viewModel.itemSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
        case SCUserCenterItemSectionUserCars:
            rows = _viewModel.userCarItems.count;
            break;
        case SCUserCenterItemSectionSelectedItems:
            rows = _viewModel.selectedItems.count;
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SCUserCenterCell *cell = nil;
    SCUserCenterMenuItem *item = nil;
    switch (indexPath.section) {
        case SCUserCenterItemSectionUserCars: {
            item = _viewModel.userCarItems[indexPath.row];
            if (item.last) {
                cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SCUserCenterAddCarCell class])
                                                       forIndexPath:indexPath];
                [cell displayCellWithItem:item];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SCUserCenterUserCarCell class])
                                                       forIndexPath:indexPath];
                [(SCUserCenterUserCarCell *)cell displayCellWithItem:item selected:[_viewModel.selectedUserCarID isEqualToString:item.userCar.userCarID]];
            }
            break;
        }
        case SCUserCenterItemSectionSelectedItems: {
            item = _viewModel.selectedItems[indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SCUserCenterCell class])
                                                   forIndexPath:indexPath];
            [cell displayCellWithItem:item];
            break;
        }
    }
    return cell;
}

#pragma mark - Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case SCUserCenterItemSectionUserCars: {
            SCUserCenterMenuItem *item = _viewModel.userCarItems[indexPath.row];
            if (item.last) {
                if ([SCUserInfo share].loginState) {
                    if (_delegate && [_delegate respondsToSelector:@selector(willShowAddCarSence)]) {
                        [_delegate willShowAddCarSence];
                    }
                    UINavigationController *addCarNavigaitonController = [SCAddCarViewController navigationInstance];
                    [self presentViewController:addCarNavigaitonController animated:YES completion:nil];
                } else {
                    [self showShoulLoginAlert];
                }
            } else {
                [_viewModel recordUserCarSelected:indexPath.row];
                [tableView reloadData];
                return;
            }
            break;
        }
        case SCUserCenterItemSectionSelectedItems: {
            if (_delegate && [_delegate respondsToSelector:@selector(shouldShowViewControllerOnRow:)]) {
                [_delegate shouldShowViewControllerOnRow:indexPath.row];
            }
            break;
        }
    }
    [self hideMenu];
}

#pragma mark - REFrostedViewController Delegate
- (void)frostedViewController:(REFrostedViewController *)frostedViewController willShowMenuViewController:(UIViewController *)menuViewController {
    [self reloadData];
}

#pragma mark - SCUserView Delegate
- (void)shouldLogin {
    [self hideMenu];
    [NOTIFICATION_CENTER postNotificationName:kUserNeedLoginNotification object:nil];
}

#pragma mark - SCUserCenterUserCarCell Delegate
- (void)shouldEditUserCarData:(SCUserCar *)userCar {
    [self hideMenu];
    if (_delegate && [_delegate respondsToSelector:@selector(shouldShowCarDataViewController:)]) {
        [_delegate shouldShowCarDataViewController:userCar];
    }
}

@end
