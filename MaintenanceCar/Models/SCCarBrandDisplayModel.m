//
//  SCCarBrandDisplayModel.m
//  MaintenanceCar
//
//  Created by ShiCang on 15/1/12.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import "SCCarBrandDisplayModel.h"
#import "MicroCommon.h"
#import "SCCoreDataManager.h"
#import "SCCarBrandManagedObject.h"
#import "SCCarBrand.h"
#import "SCAPIRequest.h"

static SCCarBrandDisplayModel *displayModel = nil;

@interface SCCarBrandDisplayModel ()

@property (nonatomic, strong) NSMutableArray      *localData;
@property (nonatomic, strong) NSMutableArray      *serverData;
@property (nonatomic, strong) NSMutableDictionary *data;

@property (nonatomic, strong) NSMutableArray      *zipTop;
@property (nonatomic, strong) NSMutableArray      *zipA;
@property (nonatomic, strong) NSMutableArray      *zipB;
@property (nonatomic, strong) NSMutableArray      *zipC;
@property (nonatomic, strong) NSMutableArray      *zipD;
@property (nonatomic, strong) NSMutableArray      *zipE;
@property (nonatomic, strong) NSMutableArray      *zipF;
@property (nonatomic, strong) NSMutableArray      *zipG;
@property (nonatomic, strong) NSMutableArray      *zipH;
@property (nonatomic, strong) NSMutableArray      *zipI;
@property (nonatomic, strong) NSMutableArray      *zipJ;
@property (nonatomic, strong) NSMutableArray      *zipK;
@property (nonatomic, strong) NSMutableArray      *zipL;
@property (nonatomic, strong) NSMutableArray      *zipM;
@property (nonatomic, strong) NSMutableArray      *zipN;
@property (nonatomic, strong) NSMutableArray      *zipO;
@property (nonatomic, strong) NSMutableArray      *zipP;
@property (nonatomic, strong) NSMutableArray      *zipQ;
@property (nonatomic, strong) NSMutableArray      *zipR;
@property (nonatomic, strong) NSMutableArray      *zipS;
@property (nonatomic, strong) NSMutableArray      *zipT;
@property (nonatomic, strong) NSMutableArray      *zipU;
@property (nonatomic, strong) NSMutableArray      *zipV;
@property (nonatomic, strong) NSMutableArray      *zipW;
@property (nonatomic, strong) NSMutableArray      *zipX;
@property (nonatomic, strong) NSMutableArray      *zipY;
@property (nonatomic, strong) NSMutableArray      *zipZ;

@end

@implementation SCCarBrandDisplayModel

#pragma mark - Init Methods
- (id)init
{
    self = [super init];
    if (self) {
        _loadFinish = NO;
        _localData  = [@[] mutableCopy];
        _serverData = [@[] mutableCopy];
        _data       = [@{} mutableCopy];
        _zipTop     = [@[] mutableCopy];
        _zipA       = [@[] mutableCopy];
        _zipB       = [@[] mutableCopy];
        _zipC       = [@[] mutableCopy];
        _zipD       = [@[] mutableCopy];
        _zipE       = [@[] mutableCopy];
        _zipF       = [@[] mutableCopy];
        _zipG       = [@[] mutableCopy];
        _zipH       = [@[] mutableCopy];
        _zipI       = [@[] mutableCopy];
        _zipJ       = [@[] mutableCopy];
        _zipK       = [@[] mutableCopy];
        _zipL       = [@[] mutableCopy];
        _zipM       = [@[] mutableCopy];
        _zipN       = [@[] mutableCopy];
        _zipO       = [@[] mutableCopy];
        _zipP       = [@[] mutableCopy];
        _zipQ       = [@[] mutableCopy];
        _zipR       = [@[] mutableCopy];
        _zipS       = [@[] mutableCopy];
        _zipT       = [@[] mutableCopy];
        _zipU       = [@[] mutableCopy];
        _zipV       = [@[] mutableCopy];
        _zipW       = [@[] mutableCopy];
        _zipX       = [@[] mutableCopy];
        _zipY       = [@[] mutableCopy];
        _zipZ       = [@[] mutableCopy];
    }
    return self;
}

+ (instancetype)share
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        displayModel = [[SCCarBrandDisplayModel alloc] init];
        [displayModel loadLocalData];
        [[SCAPIRequest manager] startUpdateCarBrandAPIRequestWithParameters:nil Success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (operation.response.statusCode == SCAPIRequestStatusCodeGETSuccess)
            {
                for (NSDictionary *carData in responseObject)
                {
                    SCCarBrand *carBrand = [[SCCarBrand alloc] initWithDictionary:carData error:nil];
                    if ([carBrand save])
                        [displayModel addObject:carBrand];
                }
                [displayModel addFinish];
            }
        } failure:nil];
    });
    return displayModel;
}

#pragma mark - Private Methods
- (void)handleDisplayData:(NSArray *)data
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    __weak typeof(self) weakSelf = self;
    for (SCCarBrand *carBrand in data)
    {
        dispatch_group_async(group, queue, ^{
            [weakSelf handelDataWithCar:carBrand];
        });
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    }
    
    dispatch_group_notify(group, queue, ^{
        SCLog(@"finish");
        _loadFinish = YES;
        [weakSelf handleIndexTitles];
    });
}

- (void)handleIndexTitles
{
    @try {
        // 获取可显示的汽车品牌数据首字母，进行升序
        _indexTitles = _loadFinish ? [[_data allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:NSNumericSearch];
        }] : nil;
    }
    @catch (NSException *exception) {
        SCException(@"%@", exception.reason);
    }
    @finally {
    }
}

- (void)handelDataWithCar:(SCCarBrand *)carBrand
{
    @try {
        NSString *key = carBrand.brand_init;
        NSString *propertyName = [NSString stringWithFormat:@"zip%@", key];
        NSMutableArray *zip = (NSMutableArray *)[self valueForKey:propertyName];
        [zip addObject:carBrand];
        if (![_data valueForKey:key])
        {
            [_data setObject:zip forKey:key];
        }
        SCLog(@"%@", propertyName);
    }
    @catch (NSException *exception) {
        SCException(@"SCCarBrandDisplayModel Set Zip Data Error:%@", exception.reason);
    }
    @finally {
    }
}

#pragma mark - Getter And Setter Methods
- (NSDictionary *)displayData
{
    return _loadFinish ? _data : nil;
}

#pragma mark - Public Methods
- (void)addObject:(id)object
{
    [_serverData addObject:object];
}

- (void)loadLocalData
{
    SCCoreDataManager *coreDataManager = [SCCoreDataManager shareManager];
    coreDataManager.entityName         = @"CarBrand";
    coreDataManager.momdName           = @"MaintenanceCar";
    coreDataManager.sqliteName         = @"MaintenanceCar.sqlite";
    NSArray *localManageData = coreDataManager.fetchedObjects;
    for (SCCarBrandManagedObject *object in localManageData)
    {
        SCCarBrand *carBrand = [[SCCarBrand alloc] init];
        carBrand.brand_id    = object.brandID;
        carBrand.brand_name  = object.brandName;
        carBrand.series_id   = object.seriesID;
        carBrand.series_name = object.seriesName;
        carBrand.brand_init  = object.brandInit;
        carBrand.img_name    = object.imgName;
        carBrand.brand_owner = object.brandOwner;
        carBrand.hit_count   = object.hitCount;
        carBrand.status      = object.status;
        carBrand.create_time = object.createTime;
        [_localData addObject:carBrand];
    }
    [self handleDisplayData:_localData];
}

- (void)addFinish
{
    [self handleDisplayData:_serverData];
}

@end
