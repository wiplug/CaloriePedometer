//
//  LoginViewController.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-6.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
        self.title = @"登陆";
    }
    return self;
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

- (void)initNavBarButtonItem
{
    UIImage *image = [UIImage imageNamed:@"home_right_btn_image"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(20, 0, 21, 16)];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavBarButtonItem];
}

#pragma mark -
#pragma mark UIControl Action

- (void)clickBackButton:(id)sender
{
    if ([self.navigationController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
    }
    else
    {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}



@end
