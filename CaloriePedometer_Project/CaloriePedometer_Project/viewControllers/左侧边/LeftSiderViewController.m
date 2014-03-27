//
//  LeftSiderViewController.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-2-28.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "LeftSiderViewController.h"
#import "SideTableViewCell.h"
#import "DDMenuController.h"
#import "MainViewController.h"
#import "AboutUSViewController.h"
#import "TGoalViewController.h"
#import "ProfileViewController.h"
#import "NewVerionViewController.h"
#import "LoginViewController.h"
#import "SportsRecordViewController.h"
#import "SyncViewController.h"
#import "SleepViewController.h"
#import "MHTabBarController.h"

#define KImageItems @"celll_home_image",@"cell_goal_image",@"cell_record_image",\
@"cell_perData_image",@"cell_update_image",@"cell_about_image"

#define KTextItems @"首页",@"今日目标",@"历史数据",@"个人资料",@"版本更新",@"关于我们"

@interface LeftSiderViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *iconArray;
@property (nonatomic, strong) NSArray *itemArray;
@end

@implementation LeftSiderViewController

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
    
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
       
    }
    return self;
}

#pragma mark -
#pragma mark loadView

- (void)loadView
{
    [super loadView];
    CGRect frame = [[UIScreen mainScreen]applicationFrame];
    UIImage *image = [UIImage imageNamed:@"side_bg_image"];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    imageView.userInteractionEnabled = YES;
    imageView.frame = frame;
    self.view = imageView;
}


- (void)initTableView
{
    CGRect frame = CGRectMake(0, 20, KScreenWidth, KScreenHeight - 160);
    _tableView = [[UITableView alloc]initWithFrame:frame];
    _tableView.scrollEnabled = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 35)];
    [_tableView.tableHeaderView setFrame:headView.frame];
    [_tableView setTableHeaderView:headView];
}

- (void)initSideBgImageView
{
    UIImage *image = [UIImage imageNamed:@"side_bg_image"];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    imageView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    [self.view addSubview:imageView];
}

- (void)initLoginBtn
{
    UIImage *image = [UIImage imageNamed:@"login_btn_image"];
    UIImage *highlightImage = [UIImage imageNamed:@"cell_selected_bg_image"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 380, KScreenWidth, 45)];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(loginBtClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    CGFloat originY = iOS7 ? 15 : 10;
    UIImage *logoImage = [UIImage imageNamed:@"cell_auth_image"];
    UIImageView *logoImageView = [[UIImageView alloc]initWithImage:logoImage];
    [logoImageView setFrame:CGRectMake(originY, (45-23.5)*0.5, 23.5, 23.5)];
    [button addSubview:logoImageView];
    
    CGRect labelframe = CGRectMake(originY*2+25, 21*0.5, 120, 24);
    UILabel *label = [[UILabel alloc]initWithFrame:labelframe];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    label.text = @"登陆/注册";
    [button addSubview:label];
}

- (void)initNoInteractiveView
{
    CGRect frame = CGRectMake(160, 20, KScreenWidth - 160 , KScreenHeight - 20);
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.userInteractionEnabled = YES;
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray *array = [NSArray arrayWithObjects:KImageItems, nil];
    self.iconArray = array;
    
    NSArray *itemArr = [NSArray arrayWithObjects:KTextItems, nil];
    self.itemArray = itemArr;
    
    [self initTableView];
    [self initLoginBtn];
    [self initNoInteractiveView];
    
    // 默认选中第一行
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark -
#pragma mark UIButton Action

- (void)loginBtClick
{
    LoginViewController *loginViewVC = [[LoginViewController alloc]init];
    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:loginViewVC];
    if ([navVC respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        NSString *imageName = iOS7 ? @"nav_bg_image_ios7" :@"nav_bg_image";
        UIImage *navBarImage = [UIImage imageNamed:imageName];
        [[UINavigationBar appearance]setBackgroundImage:navBarImage forBarMetrics: UIBarMetricsDefault];
    }
   
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    DDMenuController *menuController = (DDMenuController*)[appDelegate menuController];
    if ([menuController respondsToSelector:@selector(presentViewController:animated:completion:)])
    {
        [menuController presentViewController:navVC animated:YES completion:^{
            
        }];
    }
    else
    {
        [menuController presentModalViewController:navVC animated:YES];
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
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[SideTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row < _iconArray.count)
    {
        NSString *imageName = [_iconArray objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:imageName];
        
        NSString *itemName = [_itemArray objectAtIndex:indexPath.row];
        cell.textLabel.text = itemName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *navController = nil;
    if (indexPath.row == 0)
    {
        MainViewController *mainViewVC = [[MainViewController alloc] init];
        navController = [[UINavigationController alloc] initWithRootViewController:mainViewVC];
    }
    else if (indexPath.row == 1)
    {
        TGoalViewController *tGoalViewVC = [[TGoalViewController alloc]init];
        navController = [[UINavigationController alloc]initWithRootViewController:tGoalViewVC];
    }
    else if (indexPath.row == 2)
    {
        SportsRecordViewController *sportRecordVC = [[SportsRecordViewController alloc]init];
        SyncViewController *syncVC = [[SyncViewController alloc]init];
        SleepViewController *sleepVC = [[SleepViewController alloc]init];
        NSArray *viewControllers = [NSArray arrayWithObjects:sportRecordVC, syncVC, sleepVC, nil];
        MHTabBarController *tabBarController = [[MHTabBarController alloc] init];
        tabBarController.viewControllers = viewControllers;
        tabBarController.title = @"历史记录";
        navController = [[UINavigationController alloc]initWithRootViewController:tabBarController];
    }
    else if (indexPath.row == 3)
    {
        ProfileViewController *profileViewVC = [[ProfileViewController alloc]init];
        navController = [[UINavigationController alloc]initWithRootViewController:profileViewVC];
    }
    else if (indexPath.row == 4)
    {
        NewVerionViewController *newVersionViewVC = [[NewVerionViewController alloc]init];
        navController = [[UINavigationController alloc]initWithRootViewController:newVersionViewVC];
    }
    else
    {
        AboutUSViewController *aboutUSViewVC = [[AboutUSViewController alloc] init];
        navController = [[UINavigationController alloc] initWithRootViewController:aboutUSViewVC];
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    DDMenuController *menuController = (DDMenuController*)[appDelegate menuController];
    if (navController && menuController)
    {
        [menuController setRootController:navController animated:YES];
    }
}
@end
