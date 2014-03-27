//
//  GoalsAndHistoryView.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-2-28.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "GoalsAndHistoryView.h"
#import <CoreText/CoreText.h>

@implementation GoalsAndHistoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setGoalsSteps:(NSUInteger)goalsSteps
{
    if (_goalsSteps != goalsSteps)
    {
        _goalsSteps = goalsSteps;
        [self setNeedsDisplay];
    }
}

- (void)setTotalSteps:(NSUInteger)totalSteps
{
    if (_totalSteps != totalSteps)
    {
        _totalSteps = totalSteps;
        [self setNeedsDisplay];
    }
}

- (void)drawText:(NSString*)text
       fillColor:(UIColor*)color
            font:(UIFont*)font
            rect:(CGRect)rect
{
    [color setFill];
    [text drawInRect:rect withFont:font];
}

- (void)drawText:(NSString*)text
       fillColor:(UIColor*)color
            font:(UIFont*)font
       alignment:(NSTextAlignment)textAlignMent
            rect:(CGRect)rect
{
    [color setFill];
    [text drawInRect:rect
            withFont:font
       lineBreakMode:NSLineBreakByWordWrapping
           alignment:textAlignMent];
}

- (void)drawString:(NSString*)text inRect:(CGRect)rect
{
    //创建AttributeString
    NSMutableAttributedString *string =[[NSMutableAttributedString alloc]initWithString:text];
    //设置字体
    CTFontRef helveticaBold = CTFontCreateWithName((CFStringRef)(@"HelveticaNeue"),20,NULL);
    [string addAttribute:(id)kCTFontAttributeName
                   value:(__bridge id)helveticaBold
                   range:NSMakeRange(0,[string length])];
    //设置字间距
    long number = 2.0;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt32Type,&number);
    [string addAttribute:(id)kCTKernAttributeName
                   value:(__bridge id)num
                   range:NSMakeRange(0,[string length])];
    CFRelease(num);
    
    //设置字体颜色
    [string addAttribute:(id)kCTForegroundColorAttributeName
                   value:(id)(UIColorFromRGB(0x16B201).CGColor)
                   range:NSMakeRange(0,[string length])];
    
    //创建文本对齐方式
    CTTextAlignment alignment = kCTRightTextAlignment;
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
    frame.origin.y = self.bounds.size.height -  49;
    frame.origin.x = self.bounds.size.width - 150;
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

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    UIImage *image = [UIImage imageNamed:@"home_box_image"];
    [image drawInRect:rect];
    
    UIImage *stepImage = [UIImage imageNamed:@"home_step_image"];
    CGRect stepRect =  CGRectMake(25, 25, 18.5, 23);
    [stepImage drawInRect:stepRect];
    
    UIImage *recordImage = [UIImage imageNamed:@"home_record_image"];
    CGRect recordRect =  CGRectMake(25, 60, 18.5, 18.5);
    [recordImage drawInRect:recordRect];
    
    [self drawText:@"离今日目标：                  步"
         fillColor:UIColorFromRGB(0x4D4D4D)
              font:[UIFont fontWithName:@"HelveticaNeue" size:18]
         alignment:NSTextAlignmentCenter
              rect:CGRectMake(50, 25, rect.size.width - 55, 24)];
    
    [self drawText:@"历史总步数：                  步"
         fillColor:UIColorFromRGB(0x626262)
              font:[UIFont fontWithName:@"HelveticaNeue" size:18]
         alignment:NSTextAlignmentCenter
              rect:CGRectMake(50, 60, rect.size.width - 55, 24)];

    [self drawText:@"加油哦~坚持就是胜利~！"
         fillColor:UIColorFromRGB(0x5C5C5C)
              font:[UIFont fontWithName:@"HelveticaNeue" size:14]
         alignment:NSTextAlignmentCenter
              rect:CGRectMake(0, rect.size.height - 30, rect.size.width, 24)];
    
//    [self drawText:@"00380"
//         fillColor:UIColorFromRGB(0x16B201)
//              font:[UIFont fontWithName:@"HelveticaNeue" size:20]
//         alignment:NSTextAlignmentRight
//              rect:CGRectMake(150, 25, 110, 24)];
   
    // 绘制历史步数
    {
        _totalSteps = (_totalSteps > 10000000 ? 10000000:_totalSteps);
        NSString *totalStepsString = [NSString stringWithFormat:@"%lu",(unsigned long)_totalSteps];
        NSString *string = @"00000000";
        string = [string substringToIndex:string.length - totalStepsString.length];
        string = [string stringByAppendingString:totalStepsString];
        [self drawText:string
             fillColor:UIColorFromRGB(0x2E2E2E)
                  font:[UIFont fontWithName:@"HelveticaNeue" size:20]
             alignment:NSTextAlignmentRight
                  rect:CGRectMake(150, 60, 110, 24)];
    }
    // 绘制今日目标步数
    {
        _goalsSteps = (_goalsSteps > 10000 ? 10000:_goalsSteps);
        NSString *goalStepsString = [NSString stringWithFormat:@"%lu",(unsigned long)_goalsSteps];
        NSString *string = @"00000";
        string = [string substringToIndex:string.length - goalStepsString.length];
        string = [string stringByAppendingString:goalStepsString];
        [self drawString:string inRect:CGRectMake(150, 25, 110, 24)];
    }
}

@end
