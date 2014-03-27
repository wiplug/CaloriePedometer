//
//  PBActionSheet.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "PBActionSheet.h"
@interface PBActionSheet()
@property (nonatomic, strong) NSArray *buttonArray;
@property (nonatomic, strong) NSString *cancelBtnTitle;
@property (nonatomic, strong) completeBlock block;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UILabel *titlelabel;
@property (nonatomic, strong) UIView *contentView;
@end

@implementation PBActionSheet

- (id)initWithTitle:(NSString*)title
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    CGRect bounds = [[UIScreen mainScreen]bounds];
    self = [super initWithFrame:bounds];
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        _title = title;
        _cancelBtnTitle = cancelButtonTitle;
        NSMutableArray *arrays = [NSMutableArray array];
//        if(cancelButtonTitle)
//        {
//            [arrays addObject:cancelButtonTitle];
//        }
        va_list args;
        if (otherButtonTitles)
        {
            [arrays addObject:otherButtonTitles];
            va_start(args, otherButtonTitles);
            id arg;
            while ((arg = va_arg(args, id)))
            {
                [arrays addObject:arg];
            }
            va_end(args);
        }
        self.buttonArray = arrays;
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    UIImage *bgImage = [UIImage imageNamed:@"pb_actionsheet_bg_image"];
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:frame];
    bgImageView.image = bgImage;
    [self addSubview:bgImageView];
    
    if (_title)
    {
        _titlelabel = [[UILabel alloc]init];
        [_titlelabel setBackgroundColor:[UIColor clearColor]];
        [_titlelabel setTextColor:[UIColor blackColor]];
        [_titlelabel setTextAlignment:(unsigned)NSTextAlignmentCenter];
        [_titlelabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [_titlelabel setNumberOfLines:2];
        [_titlelabel setLineBreakMode:(unsigned)NSLineBreakByWordWrapping];
        [_titlelabel setText:_title];
    }
    [self layoutSubview];
}

- (void)show:(completeBlock)block
{
    _block = block;
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
    [self MoveIn];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *myTouch = [touches anyObject];
    if ([myTouch.view isEqual:self])
    {
        [self MoveOut];
    }
}

- (UIButton*)buttonWithTitle:(NSString*)title bgImage:(UIImage*)image frame:(CGRect)frame selector:(SEL)selector tag:(NSInteger)tag
{
    UIColor *color = UIColorFromRGB(0x007AFF);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateHighlighted];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [button.titleLabel setTextAlignment:(unsigned)NSTextAlignmentCenter];
    [button setTag:tag + 1000];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)buttonClick:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSInteger buttonIndex = button.tag - 1000;
    if (_block)
    {
        _block (buttonIndex);
    }
    [self MoveOut];
}

- (CGSize)sizeWithText:(NSString*)text font:(UIFont*)font width:(CGFloat)witdh
{
    if (text)
    {
        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(witdh, CGFLOAT_MAX)
                           lineBreakMode:(unsigned)NSLineBreakByWordWrapping];
        return size;
    }
    return CGSizeZero;
}

- (void)layoutSubview
{
    if (_title)
    {
        UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        CGSize titleSize = [self sizeWithText:_title font:titleFont width:KScreenWidth - 40];
        _titlelabel.frame = CGRectMake(10, 10, 280,titleSize.height);
    }
    
    _contentView = [[UIView alloc]init];
    
    CGFloat buttonHeight = 0;
    if (_buttonArray.count > 0)
    {
        buttonHeight = 44.5 * _buttonArray.count;
    }
    UIImage *image = [UIImage imageNamed:@"pb_actionsheet_cbg_image"];
    CGRect frame  = CGRectMake(10, 10, KScreenWidth - 20, _titlelabel.frame.size.height + 20 + buttonHeight);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    imageView.image = [image stretchableImageWithLeftCapWidth:152 topCapHeight:68];
    imageView.userInteractionEnabled = YES;
    [imageView addSubview:_titlelabel];
    [_contentView addSubview:imageView];
    
    UIImage *btnImage = [UIImage imageNamed:@"pb_actionsheet_btn_image"];
    btnImage = [btnImage stretchableImageWithLeftCapWidth:152 topCapHeight:22];
    for (int i = 0; i < _buttonArray.count; i++ )
    {
        NSString *buttonTitle = (NSString*)[_buttonArray objectAtIndex:i];
        CGRect frame = CGRectMake(0, _titlelabel.frame.size.height + 20+i*44.5, KScreenWidth - 20, 44.5);
        
        UIButton *button = [self buttonWithTitle:buttonTitle
                                         bgImage:btnImage
                                           frame:frame
                                        selector:@selector(buttonClick:)
                                             tag:i+1];
        [imageView addSubview:button];
    }
    
    CGFloat contentViewHeight = _titlelabel.frame.size.height + 40 + buttonHeight;
    if (_cancelBtnTitle)
    {
        CGRect cancelBtnframe =  CGRectMake(10, _titlelabel.frame.size.height + 40 + buttonHeight, KScreenWidth - 20, 44.5);
        UIButton *button = [self buttonWithTitle:_cancelBtnTitle
                                         bgImage:btnImage
                                           frame:cancelBtnframe
                                        selector:@selector(buttonClick:)
                                             tag:0];
        contentViewHeight += 60;
        [_contentView addSubview:button];
    }
    
    _contentView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, contentViewHeight);
    [self addSubview:_contentView];
}

- (void)MoveIn
{
    [UIView animateWithDuration:0.35f
                     animations:^{
                         CGRect frame = _contentView.frame;
                         frame.origin.y = KScreenHeight - frame.size.height;
                         _contentView.frame = frame;
                     }
                     completion:^(BOOL finished){}];
}

- (void)MoveOut
{
    [UIView animateWithDuration:0.25f
                     animations:^{
                         CGRect frame = _contentView.frame;
                         frame.origin.y = KScreenHeight;
                         _contentView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

/*
- (void)drawRect:(CGRect)rect
{
     CGContextRef context = UIGraphicsGetCurrentContext();
     size_t locationsCount = 2;
     CGFloat locations[2] = {0.0f, 1.0f};
     CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
     CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
     CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
     CGColorSpaceRelease(colorSpace);
     
     CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
     float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
     CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
     CGGradientRelease(gradient);
}*/


@end
