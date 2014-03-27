//
//  SportsRecordTableViewCell.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-19.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "SportsRecordTableViewCell.h"
#import <CoreText/CoreText.h>

@implementation SportsStepsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)setValue:(UInt32)value
{
    if (_value != value)
    {
        DEBUG_METHOD(@"--%s--setValue--",__func__);
        _value = value;
        [self setNeedsDisplay];
    }
}
- (void)drawString:(NSString*)text inRect:(CGRect)rect
{
    //创建AttributeString
    NSMutableAttributedString *string =[[NSMutableAttributedString alloc]initWithString:text];
    //设置字体
    CTFontRef helveticaBold = CTFontCreateWithName((CFStringRef)(@"HelveticaNeue"),30,NULL);
    [string addAttribute:(id)kCTFontAttributeName
                   value:(__bridge id)helveticaBold
                   range:NSMakeRange(0,[string length])];
    //设置字间距
    long number = 4.5;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt32Type,&number);
    [string addAttribute:(id)kCTKernAttributeName
                   value:(__bridge id)num
                   range:NSMakeRange(0,[string length])];
    CFRelease(num);
    
    //设置字体颜色
    [string addAttribute:(id)kCTForegroundColorAttributeName
                   value:(id)(UIColorFromRGB(0x020001).CGColor)
                   range:NSMakeRange(0,[string length])];
    
    //创建文本对齐方式
    CTTextAlignment alignment = kCTTextAlignmentCenter;
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;
    alignmentStyle.valueSize = sizeof(alignment);
    alignmentStyle.value = &alignment;
    
    //创建设置数组
    CTParagraphStyleSetting settings[ ] ={alignmentStyle};
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings ,1);
    //给文本添加设置
    [string addAttribute:(id)kCTParagraphStyleAttributeName
                   value:(__bridge id)style
                   range:NSMakeRange(0 , [string length])];
    //排版
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
    
    CGRect frame = rect;
    frame.origin.y = -12;
    //    frame.origin.x = self.bounds.size.width;
    CGPathAddRect(leftColumnPath, NULL,frame);
    CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0), leftColumnPath , NULL);
    //翻转坐标系统（文本原来是倒的要翻转下）
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context , CGAffineTransformIdentity);
    CGContextTranslateCTM(context , 0 ,self.bounds.size.height);
    CGContextScaleCTM(context, 1.0 ,-1.0);
    //画出文本
    CTFrameDraw(leftFrame,context);
    //释放
    CGPathRelease(leftColumnPath);
    CFRelease(leftFrame);
    CFRelease(style);
    CFRelease(framesetter);
    CFRelease(helveticaBold);
    string = nil;
    UIGraphicsPushContext(context);
}

- (void)drawText:(NSString*)text fillColor:(UIColor*)color font:(UIFont*)font alignment:(NSTextAlignment)textAlignMent rect:(CGRect)rect
{
    [color setFill];
    [text drawInRect:rect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:textAlignMent];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    UIImage *image = [UIImage imageNamed:@"cell_step_image"];
    [image drawInRect:CGRectMake(20, (rect.size.height - 29.5)*0.5, 23.5, 29.5)];
    
    [self drawText:@"步(step)"
         fillColor:UIColorFromRGB(0x282828)
              font:[UIFont fontWithName:@"HelveticaNeue" size:16]
         alignment:NSTextAlignmentLeft
              rect:CGRectMake(rect.size.width-80, (rect.size.height - 10)*0.5, 80, 24)];
    
    _value = (_value > 99999) ? 99999 :_value;
    NSString *CurrStepsString = [NSString stringWithFormat:@"%lu",(unsigned long)_value];
    NSString *string = @"00000";
    string = [string substringToIndex:string.length - CurrStepsString.length];
    string = [string stringByAppendingString:CurrStepsString];
    [self drawString:string inRect:rect];
}



@end

@implementation SportsRecordTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        self.superview.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *image = [UIImage imageNamed:@"cell_bg_image"];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        imageView.userInteractionEnabled = YES;
        self.backgroundView = imageView;
        
        UIImageView *selectedimageView = [[UIImageView alloc]initWithImage:image];
        selectedimageView.userInteractionEnabled = YES;
        self.selectedBackgroundView = selectedimageView;
        
        
        _distanceView = [[CaloriesOrDistanceView alloc]init];
        _distanceView.textColor = UIColorFromRGB(0x000000);
        _distanceView.targetTitle = @"距离 (m)";
        _distanceView.iconImage = [UIImage imageNamed:@"home_distance_image"];
        [self addSubview:_distanceView];
        
        _caloriesView = [[CaloriesOrDistanceView alloc]init];
        _caloriesView.textColor = UIColorFromRGB(0xD53328);
        _caloriesView.targetTitle = @"卡路 (kcal)";
        _caloriesView.iconImage = [UIImage imageNamed:@"home_carolies_image"];
        [self addSubview:_caloriesView];
        
        _sportsStepsView = [[SportsStepsView alloc]init];
        [self addSubview:_sportsStepsView];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect textRect = self.textLabel.frame;
    textRect.origin.x += 8;
    textRect.origin.y = 5;
    textRect.size.width -= 16;
    textRect.size.height = 24;
    self.textLabel.frame = textRect;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    self.textLabel.textColor = UIColorFromRGB(0x414141);
    
    CGRect frame = self.backgroundView.frame;
    frame.origin.x += 8;
    frame.size.width -= 16;
    self.backgroundView.frame = frame;
    
    CGRect selectframe = self.selectedBackgroundView.frame;
    selectframe.origin.x += 8;
    selectframe.size.width -= 16;
    self.selectedBackgroundView.frame = selectframe;
    
    _distanceView.frame = CGRectMake(frame.origin.x, self.frame.size.height - 60, KScreenWidth*0.5 - 8, 60);
    _caloriesView.frame = CGRectMake(KScreenWidth*0.5, self.frame.size.height - 60, KScreenWidth*0.5 - 8, 60);
    
    UIImage *verticalImage = [UIImage imageNamed:@"cell_vertical_image"];
    UIImageView *verticalImageView = [[UIImageView alloc]initWithImage:verticalImage];
    verticalImageView.frame = CGRectMake(KScreenWidth*0.5 - 0.5, self.frame.size.height - 59, 1, 57);
    [self addSubview:verticalImageView];
    
    CGFloat originY = iOS7 ? 9 : 18;
    UIImage *horizontalImage = [UIImage imageNamed:@"cell_horizontally_image@2x"];
    UIImageView *horizontalImageView = [[UIImageView alloc]initWithImage:horizontalImage];
    horizontalImageView.frame = CGRectMake(originY, self.frame.size.height - 60, self.frame.size.width - originY*2, 1);
    [self addSubview:horizontalImageView];
    
    UIImageView *ToplineImageView = [[UIImageView alloc]initWithImage:horizontalImage];
    ToplineImageView.frame = CGRectMake(originY, 30, self.frame.size.width - originY*2, 1);
    [self addSubview:ToplineImageView];
    
    _sportsStepsView.frame = CGRectMake(10, 31, self.frame.size.width - 20, self.frame.size.height - 92);
}

@end
