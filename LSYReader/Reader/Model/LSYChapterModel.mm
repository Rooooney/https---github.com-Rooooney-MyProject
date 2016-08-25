//
//  LSYChapterModel.m
//  LSYReader
//
//  Created by Labanotation on 16/5/31.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "LSYChapterModel.h"
#import "LSYReadConfig.h"
#import "LSYReadParser.h"
#import "NSString+HTML.h"
#import "DTHTMLAttributedStringBuilder.h"
#import "DTCoreTextConstants.h"
#include <vector>
@interface LSYChapterModel ()
@property (nonatomic) std::vector<NSUInteger> pages;
@property (nonatomic,strong) NSMutableArray *pageArray;
@end

@implementation LSYChapterModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _pageArray = [NSMutableArray array];
    }
    return self;
}
+(id)chapterWithEpub:(NSString *)chapterpath title:(NSString *)title
{
    LSYChapterModel *model = [[LSYChapterModel alloc] init];
    model.title = title;
    
    //NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Tian_Yuan_split_000" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:chapterpath]];
    
    // Set our builder to use the default native font face and size. We also set the
    // DTUseiOS6Attributes boolean, which is required when using an attributed string
    // from this builder in a native iOS view.
    NSDictionary *builderOptions = @{
                                     
                                     DTDefaultFontFamily: @"Helvetica",
                                     DTUseiOS6Attributes: @YES
                                     };
    
    DTHTMLAttributedStringBuilder *stringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:htmlData
                                                                                               options:builderOptions
                                                                                    documentAttributes:nil];

//    NSString* html = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:chapterpath]] encoding:NSUTF8StringEncoding];
//    model.content = [html stringByConvertingHTMLToPlainText];//将每一个HTML文档转换成了字符串
    //model.content = chapterpath;
    model.content = [stringBuilder generatedAttributedString].string;
    if([model.content isEqualToString:@"\n"]){
        model.content = [[chapterpath stringByDeletingLastPathComponent]lastPathComponent];//开始页用书名
    }
    if([chapterpath containsString:@"北京折叠"]&& model.pageCount==1){
         model.content = @"北京折叠－－郝景芳";//开始页用书名
    }
    return model;
}

+(id)chapterWithPdf:(NSString *)chapterTitle WithPageCount:(NSUInteger)pageNum{
    LSYChapterModel *model = [[LSYChapterModel alloc] init];
    model.title = chapterTitle;
    model.content = @"pdf";
    model.pageCount = pageNum;
    return model;
}
-(id)copyWithZone:(NSZone *)zone
{
    LSYChapterModel *model = [[LSYChapterModel allocWithZone:zone] init];
    model.content = self.content;
    model.title = self.title;
    model.pageCount = self.pageCount;
    return model;
    
}
-(void)setContent:(NSString *)content
{
    _content = content;
    [self paginateWithBounds:CGRectMake(LeftSpacing, TopSpacing, [UIScreen mainScreen].bounds.size.width-LeftSpacing-RightSpacing, [UIScreen mainScreen].bounds.size.height-TopSpacing-BottomSpacing)];
}
-(void)updateFont
{
    [self paginateWithBounds:CGRectMake(LeftSpacing, TopSpacing, [UIScreen mainScreen].bounds.size.width-LeftSpacing-RightSpacing, [UIScreen mainScreen].bounds.size.height-TopSpacing-BottomSpacing)];
}
-(void)paginateWithBounds:(CGRect)bounds
{
//    _pages.clear();
    [_pageArray removeAllObjects];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString  alloc] initWithString:self.content];
    NSDictionary *attribute = [LSYReadParser parserAttribute:[LSYReadConfig shareInstance]];//文本的样式
    [attrString setAttributes:attribute range:NSMakeRange(0, attrString.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrString);
    CGPathRef path = CGPathCreateWithRect(bounds, NULL);
    int currentOffset = 0;
    int currentInnerOffset = 0;
    BOOL hasMorePages = YES;
    // 防止死循环，如果在同一个位置获取CTFrame超过2次，则跳出循环
    int preventDeadLoopSign = currentOffset;
    int samePlaceRepeatCount = 0;
    
    while (hasMorePages) {
        if (preventDeadLoopSign == currentOffset) {
            
            ++samePlaceRepeatCount;
            
        } else {
            
            samePlaceRepeatCount = 0;
        }
        
        if (samePlaceRepeatCount > 1) {
            // 退出循环前检查一下最后一页是否已经加上
//            if (_pages.size() == 0) {
//                
//                _pages.push_back(currentOffset);
//                
//            }
            if (_pageArray.count == 0) {
                [_pageArray addObject:@(currentOffset)];
            }
            else {
                
//                NSUInteger lastOffset = _pages.back();
                NSUInteger lastOffset = [[_pageArray lastObject] integerValue];
                
                if (lastOffset != currentOffset) {
                    
//                    _pages.push_back(currentOffset);
                    [_pageArray addObject:@(currentOffset)];
                }
            }
            break;
        }
        
//        _pages.push_back(currentOffset);
        [_pageArray addObject:@(currentOffset)];
        
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(currentInnerOffset, 0), path, NULL);
        CFRange range = CTFrameGetVisibleStringRange(frame);
        
        if ((range.location + range.length) != attrString.length) {
            
            currentOffset += range.length;
            currentInnerOffset += range.length;
            
        } else {
            // 已经分完，提示跳出循环
            hasMorePages = NO;
        }
        if (frame) CFRelease(frame);
    }
    
    CGPathRelease(path);
    CFRelease(frameSetter);
//    _pageCount = _pages.size();
    _pageCount = _pageArray.count;
}
-(NSString *)stringOfPage:(NSUInteger)index
{
//    NSUInteger local = _pages[index];
    NSUInteger local = [_pageArray[index] integerValue];
    NSUInteger length;
    if (index<self.pageCount-1) {
//        length = _pages[index+1] -_pages[index];
        length=  [_pageArray[index+1] integerValue] - [_pageArray[index] integerValue];
    }
    else{
//        length = _content.length-_pages[index];
        length = _content.length - [_pageArray[index] integerValue];
    }
    return [_content substringWithRange:NSMakeRange(local, length)];
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeInteger:self.pageCount forKey:@"pageCount"];
//    for(int i = 0; i < _pages.size(); i++){
//       [array addObject:[NSValue value:&_pages[i] withObjCType:@encode(int)]];
//    }
    [aCoder encodeObject:self.pageArray forKey:@"pageArray"];
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _content = [aDecoder decodeObjectForKey:@"content"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.pageCount = [aDecoder decodeIntegerForKey:@"pageCount"];
        self.pageArray = [aDecoder decodeObjectForKey:@"pageArray"];
    }
    return self;
}
@end
