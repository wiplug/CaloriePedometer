//
//  HomeStepsView.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-19.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "HomeStepsView.h"
#import <CoreText/CoreText.h>

@implementation HomeStepsView

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
        _value = value;
        [self setNeedsDisplay];
    }
}


- (void)drawString:(NSString*)text inRect:(CGRect)rect
{
    //创建AttributeString
    NSMutableAttributedString *string =[[NSMutableAttributedString alloc]initWithString:text];
    //设置字体
    CTFontRef helveticaBold = CTFontCreateWithName((CFStringRef)(@"HelveticaNeue"),60,NULL);
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
//    frame.origin.y = self.bounds.size.height;
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
    [self drawText:@"   今日步数                                               步"
         fillColor:UIColorFromRGB(0x282828)
              font:[UIFont fontWithName:@"HelveticaNeue" size:14]
         alignment:NSTextAlignmentLeft
              rect:CGRectMake(0, rect.size.height - 40, rect.size.width, 24)];
    
    _value = (_value > 99999) ? 99999 :_value;
    NSString *CurrStepsString = [NSString stringWithFormat:@"%lu",(unsigned long)_value];
    NSString *string = @"00000";
    string = [string substringToIndex:string.length - CurrStepsString.length];
    string = [string stringByAppendingString:CurrStepsString];
    [self drawString:string inRect:rect];
}

@end
