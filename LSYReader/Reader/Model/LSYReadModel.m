//
//  LSYReadModel.m
//  LSYReader
//
//  Created by Labanotation on 16/5/31.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "LSYReadModel.h"
#import"ZPDFPageModel.h"
#import "PDFDocumentOutlineItem.h"
#import"PDFDocumentOutline.h"
#import "LSYReadUtilites.h"
@implementation LSYReadModel

#pragma mark - 初始化TXT
-(instancetype)initWithContent:(NSString *)content
{
    self = [super init];
    if (self) {
        _content = content;
        NSMutableArray *charpter = [NSMutableArray array];
        [LSYReadUtilites separateChapter:&charpter content:content];//TXT文件可以直接提取章节
        _chapters = charpter;
        _notes = [NSMutableArray array];
        _marks = [NSMutableArray array];
        _record = [[LSYRecordModel alloc] init];
        _record.chapterModel = charpter.firstObject;
        _record.chapterCount = _chapters.count;
        _marksRecord = [NSMutableDictionary dictionary];
    }
    return self;
}
#pragma mark - 初始化epub
-(instancetype)initWithePub:(NSString *)ePubPath;
{
    self = [super init];
    if (self) {
        _chapters = [LSYReadUtilites ePubFileHandle:ePubPath];;
        _notes = [NSMutableArray array];
        _marks = [NSMutableArray array];
        _record = [[LSYRecordModel alloc] init];
        _record.chapterModel = _chapters.firstObject;
        _record.chapterCount = _chapters.count;
        _marksRecord = [NSMutableDictionary dictionary];
    }
    return self;
}
#pragma mark - 初始化pdf
-(instancetype)initWithPDF:(NSURL*)pdfPath{
    self = [super init];
    if (self) {
        //        CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (__bridge CFStringRef)[pdfPath lastPathComponent], NULL, (__bridge CFStringRef)@"files");
        //NSURL *url = [NSURL URLWithString:pdfPath];
        //CFURLRef pdfURL = (__bridge CFURLRef)pdfPath;
        CGPDFDocumentRef pdfDocument = [LSYReadUtilites pdfRefByFilePath:[pdfPath absoluteString]];
        //CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
        // CFRelease(pdfURL);
        //获取目录字典
        NSArray *items = [[PDFDocumentOutline alloc]outlineItemsForDocument:pdfDocument];
        _chapters = [self getChapters:items];
        _notes = [NSMutableArray array];
        _marks = [NSMutableArray array];
        _record = [[LSYRecordModel alloc] init];
        _record.chapterModel = _chapters.firstObject;
        _record.chapterCount = _chapters.count;
        _marksRecord = [NSMutableDictionary dictionary];
        _content = @"pdf";
    }
    return self;
}

-(NSMutableArray*)getChapters:(NSArray*)chapterArray{
    NSMutableArray* chapters = [[NSMutableArray alloc]init];
    for (PDFDocumentOutlineItem* element in chapterArray){
        LSYChapterModel *model = [LSYChapterModel chapterWithPdf:element.title WithPageCount:element.pageNumber];
        [chapters addObject:model];
        
    }
    
    return chapters;
}


#pragma mark -
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.marks forKey:@"marks"];
    [aCoder encodeObject:self.notes forKey:@"notes"];
    [aCoder encodeObject:self.chapters forKey:@"chapters"];
    [aCoder encodeObject:self.record forKey:@"record"];
    [aCoder encodeObject:self.resource forKey:@"resource"];
    [aCoder encodeObject:self.marksRecord forKey:@"marksRecord"];
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.marks = [aDecoder decodeObjectForKey:@"marks"];
        self.notes = [aDecoder decodeObjectForKey:@"notes"];
        self.chapters = [aDecoder decodeObjectForKey:@"chapters"];
        self.record = [aDecoder decodeObjectForKey:@"record"];
        self.resource = [aDecoder decodeObjectForKey:@"resource"];
        self.marksRecord = [aDecoder decodeObjectForKey:@"marksRecord"];
    }
    return self;
}
+(void)updateLocalModel:(LSYReadModel *)readModel url:(NSURL *)url
{
    
    NSString *key = [url.path lastPathComponent];
    NSMutableData *data=[[NSMutableData alloc]init];
    NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:readModel forKey:key];
    [archiver finishEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
}

+(NSInteger)judgeTheFileType:(NSURL*)url{
    if([LSYReadUtilites pdfRefByFilePath:[url absoluteString]]==nil){//说明不是pdf
        NSString* txtResult =[LSYReadUtilites encodeWithURL:url];
        if(![txtResult isEqualToString:@"txt"]){//说明是TXT
            return BookTypeTXT;
        }else {//否则直接返回BookTypeEPUB，下面包含解压步骤
            LSYReadModel *model = [[LSYReadModel alloc] initWithePub:url.path];
            if((model.record.chapterModel.title!=nil&& ![model.record.chapterModel.title isEqualToString:@""])||model.chapters.count>0){//说明是epub
                return BookTypeEPUB;
            }else {//文件格式错误
//                @throw [NSException exceptionWithName:@"FileException" reason:@"文件格式错误" userInfo:nil];
                return -1;
            }
            
        }
    }else{
        return BookTypePDF;
    }
    
    return -1;
}


+(id)getLocalModelWithURL:(NSURL *)url
{
    NSString *key = [url.path lastPathComponent];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!data) {
        NSInteger type = [LSYReadModel judgeTheFileType:url];//TXT不这样处理会返
        if(type==BookTypeEPUB){
            NSLog(@"this is epub");
            LSYReadModel *model = [[LSYReadModel alloc] initWithePub:url.path];
            model.resource = url;
            [LSYReadModel updateLocalModel:model url:url];
            return model;
        }else if(type==BookTypeTXT){
            LSYReadModel *model = [[LSYReadModel alloc] initWithContent:[LSYReadUtilites encodeWithURL:url]];
            model.resource = url;
            [LSYReadModel updateLocalModel:model url:url];
            return model;
            
        }else if(type==BookTypePDF){
            NSLog(@"this is pdf");
            LSYReadModel *model = [[LSYReadModel alloc] initWithPDF:url];
            model.resource = url;
            [LSYReadModel updateLocalModel:model url:url];
            return model;
            
        }else {
            @throw [NSException exceptionWithName:@"FileException" reason:@"文件格式错误" userInfo:nil];
        }
        
        //        if([LSYReadUtilites pdfRefByFilePath:[url absoluteString]]==nil){//说明不是pdf
        //            LSYReadModel *model = [[LSYReadModel alloc] initWithePub:url.path];
        //            if(model.record.chapterModel.title!=nil&& ![model.record.chapterModel.title isEqualToString:@""]){//说明是epub
        //                model.resource = url;
        //                [LSYReadModel updateLocalModel:model url:url];
        //                return model;
        //
        //            }else {
        //
        //                LSYReadModel *model = [[LSYReadModel alloc] initWithContent:[LSYReadUtilites encodeWithURL:url]];
        //                if(![model.record.chapterModel.content isEqualToString:@""]){//说明是txt
        //                    model.resource = url;
        //                    [LSYReadModel updateLocalModel:model url:url];
        //                    return model;
        //
        //                }else {
        //                    @throw [NSException exceptionWithName:@"FileException" reason:@"文件格式错误" userInfo:nil];
        //
        //                }
        //
        //            }
        //        }else{//pdf 处理
        //
        //            LSYReadModel *model = [[LSYReadModel alloc] initWithPDF:url];
        //            // ZPDFPageModel *model = [[ZPDFPageModel alloc] initWithPDFDocument:pdfDocument];
        //            model.resource = url;
        //            [LSYReadModel updateLocalModel:model url:url];
        //            return model;
        //        }
        
        //        if ([[key pathExtension] isEqualToString:@"txt"]) {
        //            LSYReadModel *model = [[LSYReadModel alloc] initWithContent:[LSYReadUtilites encodeWithURL:url]];
        //            model.resource = url;
        //            [LSYReadModel updateLocalModel:model url:url];
        //            return model;
        //        }
        //        else if ([[key pathExtension] isEqualToString:@"epub"]){
        //            NSLog(@"this is epub");
        //            LSYReadModel *model = [[LSYReadModel alloc] initWithePub:url.path];
        //            model.resource = url;
        //            [LSYReadModel updateLocalModel:model url:url];
        //            return model;
        //        }
        //        else if([[key pathExtension]
        //                 isEqualToString:@"pdf"]){
        //            NSLog(@"this is pdf");
        //            LSYReadModel *model = [[LSYReadModel alloc] initWithPDF:url];
        //           // ZPDFPageModel *model = [[ZPDFPageModel alloc] initWithPDFDocument:pdfDocument];
        //            model.resource = url;
        //            [LSYReadModel updateLocalModel:model url:url];
        //            return model;
        //        }
        //        else{
        //            @throw [NSException exceptionWithName:@"FileException" reason:@"文件格式错误" userInfo:nil];
        //        }
        
    }
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    LSYReadModel *model = [unarchive decodeObjectForKey:key];
    return model;
}

+(id)getLocalModelWithBookModel:(BookModel *)_model
{
    NSURL* url = [NSURL URLWithString:[_model.filePath
                                                                 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];//TXT不这样处理会返回nil
    NSString *key = [url.path lastPathComponent];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!data) {
        NSInteger type = _model.bookType;
        if(type==BookTypeEPUB){
            NSLog(@"this is epub");
            LSYReadModel *model = [[LSYReadModel alloc] initWithePub:url.path];
            model.resource = url;
            [LSYReadModel updateLocalModel:model url:url];
            return model;
        }else if(type==BookTypeTXT){
            LSYReadModel *model = [[LSYReadModel alloc] initWithContent:[LSYReadUtilites encodeWithURL:url]];
            model.resource = url;
            [LSYReadModel updateLocalModel:model url:url];
            return model;
            
        }else if(type==BookTypePDF){
            NSLog(@"this is pdf");
            LSYReadModel *model = [[LSYReadModel alloc] initWithPDF:url];
            model.resource = url;
            [LSYReadModel updateLocalModel:model url:url];
            return model;
            
        }else {
            @throw [NSException exceptionWithName:@"FileException" reason:@"文件格式错误" userInfo:nil];
        }
        
    }
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    LSYReadModel *model = [unarchive decodeObjectForKey:key];
    return model;
}
@end
