//
//  ProfileViewController.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-6.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileTableViewCell.h"
#import "PBActionSheet.h"
#import "PLActionSheet.h"
#import "MBProgressHUD.h"

@interface ProfileViewController () <UITableViewDataSource,UITableViewDelegate>
{
    MBProgressHUD *_progressHUD;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *profileDic;
@property (nonatomic, assign) NSInteger  sex;
@property (nonatomic, assign) NSInteger  height;
@property (nonatomic, assign) NSInteger  weight;
@property (nonatomic, assign) NSInteger  stride;
@property (nonatomic, assign) NSInteger  age;

@end

@implementation ProfileViewController

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"个人资料";
        _sex = -1;
        _progressHUD = [self progressHUD];
    }
    return self;
}

#pragma mark -
#pragma mark MBProgressHUD

- (MBProgressHUD*)progressHUD
{
    if (_progressHUD == nil)
    {
        _progressHUD = [[MBProgressHUD alloc]initWithWindow:[self appWindow]];
    }
    return _progressHUD;
}

- (UIWindow*)appWindow
{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return delegate.window;
}


- (void)show:(NSString *)labelText image:(UIImage*)image time:(NSTimeInterval)time
{
    _progressHUD.labelText = labelText;
    _progressHUD.detailsLabelText = @"";
    UIImageView *imageView =  [[UIImageView alloc] initWithImage:image];
    _progressHUD.customView = imageView;
    imageView = nil;
    _progressHUD.mode = MBProgressHUDModeCustomView;
    [[self appWindow] addSubview:_progressHUD];
    [_progressHUD show:YES];
    [_progressHUD hide:YES afterDelay:time];
}


#pragma mark -
#pragma mark loadView

- (void)loadView
{
    [super loadView];
    CGRect frame = [[UIScreen mainScreen]applicationFrame];
    UIView *contentView = [[UIView alloc]initWithFrame:frame];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.view = contentView;
}

- (void)initTableView
{
    CGRect frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64);
    _tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundView = nil;
    [self.view addSubview:_tableView];
}

- (void)initTableFooterView
{
    CGRect frame = CGRectMake(0, 0, KScreenWidth, 100);
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = YES;
    
    UIImage *normalImage = [UIImage imageNamed:@"table_foot_btn_image"];
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake((KScreenWidth - 303.5)*0.5, 20, 303.5, 44);
    
    [doneButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [doneButton setTitle:@"保存" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(clickToSaveProfileInfo) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:doneButton];
    
    [_tableView.tableFooterView setFrame:frame];
    _tableView.tableFooterView = view;
}

- (NSMutableDictionary*)loadProfileInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = (NSMutableDictionary*)[userDefaults objectForKey:@"BLeUserInfo"];
    return dictionary;
}

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveUpdateNotify) name:@"EVENT_UPDATE_PROFILE_NOTIFY" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    [self initTableFooterView];
    [self registerNotification];
    self.profileDic = [self loadProfileInfo];
    if (_profileDic)
    {
        int BStride = [[_profileDic objectForKey:@"stride"]intValue];
        _stride = BStride;
    }
}

- (void)receiveUpdateNotify
{
    self.profileDic = [self loadProfileInfo];
    if (_profileDic)
    {
        int BStride = [[_profileDic objectForKey:@"stride"]intValue];
        _stride = BStride;
    }
    [self.tableView reloadData];
}

- (void)clickToSaveProfileInfo
{
    if (_sex != -1 && _age > 0 && _height > 0 && _weight > 0 && _stride > 0)
    {
        @try
        {
            UInt32 BStepTarget = (UInt32)[[_profileDic objectForKey:@"stepTarget"]unsignedLongValue];
            BStepTarget = (BStepTarget == 0 ) ? 10000:BStepTarget;
            
            NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
            [paramsDic setObject:[NSNumber numberWithUnsignedLong:_weight] forKey:@"weight"];
            [paramsDic setObject:[NSNumber numberWithInteger:_age] forKey:@"age"];
            [paramsDic setObject:[NSNumber numberWithInteger:_height] forKey:@"height"];
            [paramsDic setObject:[NSNumber numberWithInteger:_stride] forKey:@"stride"];
            [paramsDic setObject:[NSNumber numberWithInteger:_sex] forKey:@"sex"];
            [paramsDic setObject:[NSNumber numberWithUnsignedLong:BStepTarget] forKey:@"stepTarget"];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:paramsDic forKey:@"BLeUserInfo"];
            [userDefaults synchronize];
            DEBUG_METHOD(@"-【%s】---保存完成----",__FUNCTION__);
            UIImage *image = [UIImage imageNamed:@"MB_Checkmark"];
            [self show:@"保存完成" image:image time:1.35];
        }
        @catch (NSException *exception)
        {
            DEBUG_METHOD(@"-----exception--[name]:%@",exception.name);
            DEBUG_METHOD(@"-----exception--[description]:%@",exception.description);
        }
    }
    else
    {
        UIImage *image = [UIImage imageNamed:@"MB_Error"];
        [self show:@"保存失败" image:image time:1.35];
        DEBUG_METHOD(@"-【%s】---保存失败----",__FUNCTION__);
    }
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    ProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[ProfileTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"性别：";
        if (_profileDic)
        {
            int BSex = [[_profileDic objectForKey:@"sex"]intValue];
            _sex = BSex;
            cell.contentlabel.text = (BSex == 0) ? @"女" : @"男";
        }
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"年龄：";
        if (_profileDic)
        {
            int BAge = [[_profileDic objectForKey:@"age"]intValue];
            _age = BAge;
            cell.contentlabel.text = [NSString stringWithFormat:@"%d 岁",BAge];
        }
    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = @"身高：";
        if (_profileDic)
        {
            int BHeight = [[_profileDic objectForKey:@"height"]intValue];
            _height = BHeight;
            cell.contentlabel.text = [NSString stringWithFormat:@"%d cm",BHeight];
        }
    }
    else
    {
        cell.textLabel.text = @"体重：";
        if (_profileDic)
        {
            UInt32 BWeight = (UInt32)[[_profileDic objectForKey:@"weight"]unsignedLongValue];
            _weight = BWeight;
            cell.contentlabel.text = [NSString stringWithFormat:@"%u kg",(unsigned int)BWeight/10];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0)
    {
        __block ProfileViewController *this = self;
        PBActionSheet *actionSheet = [[PBActionSheet alloc]initWithTitle:@"性别" cancelButtonTitle:@"取消" otherButtonTitles:@"男",@"女", nil];
        [actionSheet show:^(NSInteger buttonIndex) {
            DEBUG_METHOD(@"----buttonIndex---%d",buttonIndex);
            if (buttonIndex == 1)
            {
                this->_sex = 1;
                ProfileTableViewCell *cell = (ProfileTableViewCell*)[this->_tableView cellForRowAtIndexPath:indexPath];
                cell.contentlabel.text = @"男";
            }
            
            if (buttonIndex == 2)
            {
                this->_sex = 0;
                ProfileTableViewCell *cell = (ProfileTableViewCell*)[this->_tableView cellForRowAtIndexPath:indexPath];
                cell.contentlabel.text = @"女";
            }
        }];
    }
    
    /* 年龄*/
    if (indexPath.row == 1)
    {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponent = [calendar components:NSYearCalendarUnit fromDate:[NSDate date]];
        NSInteger year = [dateComponent year];
        
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 1900; i <= year; i+=1)
        {
            NSString *age = [NSString stringWithFormat:@"%d",i];
            [array addObject:age];
        }
         __block ProfileViewController *this = self;
        PLActionSheet *actionSheet = [[PLActionSheet alloc]initWithTitle:@"请选择出身日期" Unit:@"年" Parmas:array];
        [actionSheet show:^(NSInteger result) {
            DEBUG_METHOD(@"------age---%d",result);
            this->_age = year - result;
            ProfileTableViewCell *cell = (ProfileTableViewCell*)[this->_tableView cellForRowAtIndexPath:indexPath];
            cell.contentlabel.text = [NSString stringWithFormat:@"%ld 岁",(long)this->_age];
        }];
    }
    
    /* 身高*/
    if (indexPath.row == 2)
    {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 30; i < 260; i++)
        {
            NSString *height = [NSString stringWithFormat:@"%d",i];
            [array addObject:height];
        }
        __block ProfileViewController *this = self;
        PLActionSheet *actionSheet = [[PLActionSheet alloc]initWithTitle:@"请选择身高" Unit:@"cm" Parmas:array];
        [actionSheet show:^(NSInteger result) {
            
            this->_height = result;
            this->_stride = result*0.22;
            DEBUG_METHOD(@"------height---%d",result);
            DEBUG_METHOD(@"------_stride---%d",this->_stride);
            ProfileTableViewCell *cell = (ProfileTableViewCell*)[this->_tableView cellForRowAtIndexPath:indexPath];
            cell.contentlabel.text = [NSString stringWithFormat:@"%ld cm",(long)this->_height];
        }];
    }
    /* 体重*/
    if (indexPath.row == 3)
    {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 15; i < 300; i++)
        {
            NSString *height = [NSString stringWithFormat:@"%d",i];
            [array addObject:height];
        }
        __block ProfileViewController *this = self;
        PLActionSheet *actionSheet = [[PLActionSheet alloc]initWithTitle:@"请选择体重" Unit:@"kg" Parmas:array];
        [actionSheet show:^(NSInteger result) {
            DEBUG_METHOD(@"------weight---%d",result);
            this->_weight = result*10;
            ProfileTableViewCell *cell = (ProfileTableViewCell*)[this->_tableView cellForRowAtIndexPath:indexPath];
            cell.contentlabel.text = [NSString stringWithFormat:@"%ld kg",(long)result];
        }];
    }
    
    
}

@end
