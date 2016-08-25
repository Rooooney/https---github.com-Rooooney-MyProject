//
//  LSYReadUtilites.m
//  LSYReader
//
//  Created by Labanotation on 16/5/31.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "LSYReadUtilites.h"
//#import "LSYChapterModel.h"
#import "ZipArchive.h"
#import "TouchXML.h"
#import "PDFDocumentOutline.h"
#import "PDFDocumentOutlineItem.h"
@implementation LSYReadUtilites

//纠正时间
+(NSDate*)getCurrentDate

{
    
    NSDate *date = [NSDate date];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: date];
    
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    NSLog(@"%@", localeDate);
    return localeDate;
    
}

//删除文件夹下的文件
// 删除沙盒里的文件
+(void)deleteFileWithFilePath:(NSString*)filePath {
    //    NSString *resourcePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"/files"];
    //    _model.filePath = [resourcePath stringByAppendingString:[@"/" stringByAppendingString:[_model.downloadURL lastPathComponent]]];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //文件名
    //NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!blHave) {
        NSLog(@"no  have");
        return ;
    }else {
        NSLog(@" have");
        BOOL blDele= [fileManager removeItemAtPath:filePath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
    }
}

//获取本地的PDF文件
+(CGPDFDocumentRef)pdfRefByFilePath:(NSString *)aFilePath
{
//     CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (__bridge CFStringRef)[aFilePath lastPathComponent], NULL, (__bridge CFStringRef)@"files");
//    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
//    CFRelease(pdfURL);
    
    
    
    
    NSString* filePath = [aFilePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    filePath = [[filePath stringByDeletingPathExtension]stringByAppendingString:@".pdf"];
    path = CFStringCreateWithCString(NULL, [filePath UTF8String], kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, NO);
    document = CGPDFDocumentCreateWithURL(url);
    
    CFRelease(path);
    CFRelease(url);
    
    return document;
}
+(NSString*)getBookIDDone{
    if(bookIDDones ==nil){
        bookIDDones = [[NSUserDefaults standardUserDefaults] stringForKey:@"BookIDDone"];
    }
    return bookIDDones;
}

+(NSString*)getBookIDContinue{
    if(bookIDContinues ==nil){
        bookIDContinues = [[NSUserDefaults standardUserDefaults] stringForKey:@"BookIDContinue"];
    }
    return bookIDContinues;
}

+(void)separateChapter:(NSMutableArray **)chapters content:(NSString *)content
{
    [*chapters removeAllObjects];
    NSString *parten = @"第[0-9一二三四五六七八九十百千]*[章回].*";
    NSError* error = NULL;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray* match = [reg matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, [content length])];
    
    if (match.count != 0)
    {
        __block NSRange lastRange = NSMakeRange(0, 0);
        [match enumerateObjectsUsingBlock:^(NSTextCheckingResult *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [obj range];
            NSInteger local = range.location;
            if (idx == 0) {
                LSYChapterModel *model = [[LSYChapterModel alloc] init];
                model.title = @"开始";
                NSUInteger len = local;
                model.content = [content substringWithRange:NSMakeRange(0, len)];
                [*chapters addObject:model];
                
            }
            if (idx > 0 ) {
                LSYChapterModel *model = [[LSYChapterModel alloc] init];
                model.title = [content substringWithRange:lastRange];
                NSUInteger len = local-lastRange.location;
                model.content = [content substringWithRange:NSMakeRange(lastRange.location, len)];
                [*chapters addObject:model];
                
            }
            if (idx == match.count-1) {
                LSYChapterModel *model = [[LSYChapterModel alloc] init];
                model.title = [content substringWithRange:range];
                model.content = [content substringWithRange:NSMakeRange(local, content.length-local)];
                [*chapters addObject:model];
            }
            lastRange = range;
        }];
    }
    else{
        LSYChapterModel *model = [[LSYChapterModel alloc] init];
        model.content = content;
        [*chapters addObject:model];
    }
    
}
+(NSString *)encodeWithURL:(NSURL *)url//pdf 格式的不会走这个方法
{
    if (!url) {
        return @"";
    }
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    if (!content) {
        content = [NSString stringWithContentsOfURL:url encoding:0x80000632 error:nil];
    }
    if (!content) {
        content = [NSString stringWithContentsOfURL:url encoding:0x80000631 error:nil];
    }
    if(!content){//对于汉字编码的 用gb18030编码
        //unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSError *err;
        NSString *str=[NSString stringWithContentsOfFile:[url absoluteString] encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000) error:&err];
        
        content = str;
        
    }
    if (!content) {
        return @"txt";//说明TXT解码错误，不是TXT
    }
    return content;
    
}
+(UIButton *)commonButtonSEL:(SEL)sel target:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [button setTintColor:[UIColor whiteColor]];
    [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
}
+(UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
+(void)showAlertTitle:(NSString *)title content:(NSString *)string
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:string delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
#pragma clang diagnostic pop
    
}
#pragma mark - ePub处理
+(NSMutableArray *)ePubFileHandle:(NSString *)path;
{
    NSString *ePubPath = [self unZip:path];
    if (!ePubPath) {
        return nil;
    }
    NSString *OPFPath = [self OPFPath:ePubPath];
    return [self parseOPF:OPFPath];
    
}
#pragma mark - pdf处理
//+(NSMutableArray*)pdfFileHandle:(NSString *)path;
//{
//
//    return [[PDFDocumentOutline alloc]outlineItemsForDocument:pdfDoc];
//    _chapters = [self getChapters:_items];
//
//
//}
//-(id) initWithPDFDocument:(CGPDFDocumentRef) pdfDoc {
//    self = [super init];
//    if (self) {
//        pdfDocument = pdfDoc;
//        //获取目录字典
//        _items = [[PDFDocumentOutline alloc]outlineItemsForDocument:pdfDocument];
//        _chapters = [self getChapters:_items];
//        _notes = [NSMutableArray array];
//        _marks = [NSMutableArray array];
//        _record = [[LSYRecordModel alloc] init];
//        _record.chapterModel = _chapters.firstObject;
//        _record.chapterCount = _chapters.count;
//
//    }
//    return self;
//}

-(NSMutableArray*)getChapters:(NSArray*)chapterArray{
    NSMutableArray* chapters = [[NSMutableArray alloc]init];
    for (PDFDocumentOutlineItem* element in chapterArray){
        LSYChapterModel *model = [LSYChapterModel chapterWithPdf:element.title WithPageCount:element.pageNumber];
        [chapters addObject:model];
        
    }
    
    return chapters;
}




#pragma mark - 解压文件路径
+(NSString *)unZip:(NSString *)path
{
    ZipArchive *zip = [[ZipArchive alloc] init];
    NSString *zipFile = [[path stringByDeletingPathExtension] lastPathComponent];
   
    ///////////////解压过了 直接返回
    NSString *zipPath = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject,zipFile];
    NSFileManager *filemanager=[[NSFileManager alloc] init];
    if ([filemanager fileExistsAtPath:zipPath]) {
        return zipPath;//如果已经存在这个文件，直接返回

    }else{
            if ([zip UnzipOpenFile:path]) {
                NSString *zipPath = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject,zipFile];
                NSFileManager *filemanager=[[NSFileManager alloc] init];
                if ([filemanager fileExistsAtPath:zipPath]) {
                    //NSError *error;
                    return zipPath;//如果已经存在这个文件，直接返回
                    //[filemanager removeItemAtPath:zipPath error:&error];
                }
                if ([zip UnzipFileTo:[NSString stringWithFormat:@"%@/",zipPath] overWrite:YES]) {
                    return zipPath;
                }
            }
        
        
    }
    return nil;
    
//    if ([zip UnzipOpenFile:path]) {
//        NSString *zipPath = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject,zipFile];
//        NSFileManager *filemanager=[[NSFileManager alloc] init];
//        if ([filemanager fileExistsAtPath:zipPath]) {
//            NSError *error;
//            return zipPath;//如果已经存在这个文件，直接返回
//            //[filemanager removeItemAtPath:zipPath error:&error];
//        }
//        if ([zip UnzipFileTo:[NSString stringWithFormat:@"%@/",zipPath] overWrite:YES]) {
//            return zipPath;
//        }
//    }
//    return nil;
}
#pragma mark - OPF文件路径
+(NSString *)OPFPath:(NSString *)epubPath
{
    NSString *containerPath = [NSString stringWithFormat:@"%@/META-INF/container.xml",epubPath];
    //container.xml文件路径 通过container.xml获取到opf文件的路径
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:containerPath]) {
        CXMLDocument* document = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:containerPath] options:0 error:nil];
        CXMLNode* opfPath = [document nodeForXPath:@"//@full-path" error:nil];
        // xml文件中获取full-path属性的节点  full-path的属性值就是opf文件的绝对路径
        return [NSString stringWithFormat:@"%@/%@",epubPath,[opfPath stringValue]];
    } else {
        NSLog(@"ERROR: ePub not Valid");
        return nil;
    }
    
}
//#pragma mark - 解析OPF文件
//+(NSMutableArray *)parseOPF:(NSString *)opfPath
//{    NSMutableArray *chapters = [NSMutableArray array];
//
//    NSString *coverImgPathStr = nil;
//    CXMLDocument* document = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:opfPath] options:0 error:nil];
//    NSArray* itemsArray = [document nodesForXPath:@"//opf:item" namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"] error:nil];
//    //opf文件的命名空间 xmlns="http://www.idpf.org/2007/opf" 需要取到某个节点设置命名空间的键为opf 用opf:节点来获取节点
//    NSString *ncxFile;
//    NSMutableDictionary* itemDictionary = [[NSMutableDictionary alloc] init];
//    for (CXMLElement* element in itemsArray){
//        [itemDictionary setValue:[[element attributeForName:@"href"] stringValue] forKey:[[element attributeForName:@"id"] stringValue]];
//        //获取ncx文件名称 根据ncx获取书的目录
//        if([[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"application/x-dtbncx+xml"]){
//            ncxFile = [[element attributeForName:@"href"] stringValue];
//        }
//        //获取封面文件的相对路径 存到coverImgPathStr
//        if([[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"image/jpeg"]
//           &&[[[element attributeForName:@"id"]stringValue]containsString:@"cover"]){
//            coverImgPathStr = [[element attributeForName:@"href"]stringValue];
//        }
//    }
//    //////存封面
//    NSString *absolutePath = [opfPath stringByDeletingLastPathComponent];
//    //epub文件的封面路径：coverImgPathStr
//    coverImgPathStr = [@"/" stringByAppendingString:coverImgPathStr];
//    coverImgPathStr = [absolutePath stringByAppendingString:coverImgPathStr];
//    // NSString* coverImgName = [[absolutePath stringByDeletingLastPathComponent]lastPathComponent];
//    NSString* coverImgName = [absolutePath lastPathComponent];
//    //拼接封面图片的绝对路径，得到封面图片：coverImg
//    UIImage *coverImg = [UIImage imageWithContentsOfFile:coverImgPathStr];
//    //存储图片到本地
//    [self storeImgLocal:coverImg withImageName:coverImgName];
//    //////存封面
//    
//    
//    
//    CXMLDocument *ncxDoc = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", absolutePath,ncxFile]] options:0 error:nil];
//    NSMutableDictionary* titleDictionary = [[NSMutableDictionary alloc] init];
//    for (CXMLElement* element in itemsArray) {
//        NSString* href = [[element attributeForName:@"href"] stringValue];
//        NSString* xpath = [NSString stringWithFormat:@"//ncx:content[@src='%@']/../ncx:navLabel/ncx:text", href];
//        //根据opf文件的href获取到ncx文件中的中对应的目录名称
//        NSArray* navPoints = [ncxDoc nodesForXPath:xpath namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.daisy.org/z3986/2005/ncx/" forKey:@"ncx"] error:nil];
//        if([navPoints count]!=0){
//            CXMLElement* titleElement = navPoints.firstObject;
//            [titleDictionary setValue:[titleElement stringValue] forKey:href];
//        }
//
//       
//    }
//    NSArray* itemRefsArray = [document nodesForXPath:@"//opf:itemref" namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"] error:nil];
//    
//    for (CXMLElement* element in itemRefsArray){
//        NSString* chapHref = [itemDictionary valueForKey:[[element attributeForName:@"idref"] stringValue]];
//        LSYChapterModel *model = [LSYChapterModel chapterWithEpub:[NSString stringWithFormat:@"%@/%@",absolutePath,chapHref] title:[titleDictionary valueForKey:chapHref]];
//        [chapters addObject:model];
//        
//    }
//    return chapters;
//}




+(NSMutableArray *)parseOPF:(NSString *)opfPath
{   NSString*bookBasePath,*ncxPath;
    //章节集合数目
    //NSArray* spineArray ;
    //判断是否解析成功
    //BOOL   parseSucceed;
    NSString *coverImgPathStr = nil;

    NSURL *opfPathUrl = [NSURL fileURLWithPath:opfPath];
    CXMLDocument *opfFile = [[CXMLDocument alloc] initWithContentsOfURL:opfPathUrl options:0 error:nil];
    NSDictionary *opfNamespaceMapings = [NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"];
    NSArray *itemsArray = [opfFile nodesForXPath:@"//opf:item" namespaceMappings:opfNamespaceMapings error:nil];
    
    NSString *ncxFileName;
    NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] init];
    for (CXMLElement *element in itemsArray)
    {
        [itemDictionary setValue:[[element attributeForName:@"href"] stringValue] forKey:[[element attributeForName:@"id"] stringValue]];
        NSString *mediaType = [[element attributeForName:@"media-type"] stringValue];
        if([mediaType isEqualToString:@"application/x-dtbncx+xml"])
        {
            ncxFileName = [[element attributeForName:@"href"] stringValue];
        }
        
        if([mediaType isEqualToString:@"application/xhtml+xml"])
        {
            ncxFileName = [[element attributeForName:@"href"] stringValue];
        }
        
        //获取封面文件的相对路径 存到coverImgPathStr
        if([[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"image/jpeg"]
           &&[[[element attributeForName:@"id"]stringValue]containsString:@"cover"]){
            coverImgPathStr = [[element attributeForName:@"href"]stringValue];
        }
        if(coverImgPathStr==nil&&[[[element attributeForName:@"id"]stringValue]containsString:@"cover"]){//bmp格式
            coverImgPathStr = [[element attributeForName:@"href"]stringValue];
        }
    }
    
    //////存封面
    NSString *absolutePath = [opfPath stringByDeletingLastPathComponent];
    //epub文件的封面路径：coverImgPathStr
    coverImgPathStr = [@"/" stringByAppendingString:coverImgPathStr];
    coverImgPathStr = [absolutePath stringByAppendingString:coverImgPathStr];
    // NSString* coverImgName = [[absolutePath stringByDeletingLastPathComponent]lastPathComponent];
    NSString* coverImgName = [absolutePath lastPathComponent];
    //拼接封面图片的绝对路径，得到封面图片：coverImg
    UIImage *coverImg = [UIImage imageWithContentsOfFile:coverImgPathStr];
    //如果封面不存在，存储图片到本地
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"cover_%@.png",coverImgName]];

    if(![fileManager fileExistsAtPath:imagePath]) { //如果不存在
        [self storeImgLocal:coverImg withImageName:coverImgName];
        //////存封面
    }
    
    
    unsigned long lastSlash = [opfPath rangeOfString:@"/" options:NSBackwardsSearch].location;
    bookBasePath = [opfPath substringToIndex:(lastSlash + 1)];
    ncxPath = [NSString stringWithFormat:@"%@%@", bookBasePath, ncxFileName];
    NSURL *ncxPathUrl = [NSURL fileURLWithPath:ncxPath];
    CXMLDocument *ncxToc = [[CXMLDocument alloc] initWithContentsOfURL:ncxPathUrl options:0 error:nil];
    NSMutableDictionary *titleDictionary = [[NSMutableDictionary alloc] init];
    for (CXMLElement *element in itemsArray)
    {
        NSString *href = [[element attributeForName:@"href"] stringValue];
        NSString *xpath = [NSString stringWithFormat:@"//ncx:content[@src='%@']/../ncx:navLabel/ncx:text", href];
        NSDictionary *ncxNamespaceMappings = [NSDictionary dictionaryWithObject:@"http://www.daisy.org/z3986/2005/ncx/" forKey:@"ncx"];
        NSArray *navPoints = [ncxToc nodesForXPath:xpath namespaceMappings:ncxNamespaceMappings error:nil];
        if([navPoints count] != 0)
        {
            CXMLElement *titleElement = [navPoints objectAtIndex:0];
            [titleDictionary setValue:[titleElement stringValue] forKey:href];
        }
    }
    
    NSArray *itemRefsArray = [opfFile nodesForXPath:@"//opf:itemref" namespaceMappings:opfNamespaceMapings error:nil];
    //NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    //int count = 0;
    NSMutableArray *chapters = [NSMutableArray array];

    for (CXMLElement *element in itemRefsArray)
    {
        NSString *chapHref   = [itemDictionary valueForKey:[[element attributeForName:@"idref"] stringValue]];
        NSString *spinePath  = [NSString stringWithFormat:@"%@%@", bookBasePath, chapHref];
       // NSString *spineTitle = [titleDictionary valueForKey:chapHref];
        
//        EPubChapter *chapter = [[EPubChapter alloc] init];
//        [chapter setSpineIndex:count];
//        [chapter setSpinePath:spinePath];
//        [chapter setTitle:spineTitle];
//        count++;
//        [tmpArray addObject:chapter];
        // NSString *absolutePath = [opfPath stringByDeletingLastPathComponent];
        
       LSYChapterModel *model = [LSYChapterModel chapterWithEpub:spinePath title:[titleDictionary valueForKey:chapHref]];//实例化每一个chaptermodel
       // LSYChapterModel *model = [LSYChapterModel chapterWithEpub:spinePath title:[titleDictionary valueForKey:chapHref]];
        [chapters addObject:model];
        
        
    }
    
    
    
    return chapters;
    
//    spineArray = [NSArray arrayWithArray:tmpArray];
//    parseSucceed = self.spineArray.count > 0;
}




+(bool)storeImgLocal:(UIImage*)imgToStore withImageName:(NSString*)imageName{
    //NSData *imageData = UIImagePNGRepresentation(imgToStore);
    NSData *pngData = UIImagePNGRepresentation(imgToStore); // Convert it in to PNG data
    //UIImage *pngImage = [UIImage imageWithData:pngData]; // Result image
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"cover_%@.png",imageName]];
    //NSString *imagePath =[NSString stringWithFormat:@"cover_%@.png",imageName];
    
    NSLog((@"存封面：pre writing to file"));
    if (![pngData writeToFile:imagePath atomically:NO])
    {
        NSLog(@"存封面：Failed to cache image data to disk");
        return NO;
    }
    else
    {
        NSLog(@"存封面：the cachedImagedPath is %@", imagePath);
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"LSYCoverNotification" object:@"Success"];
        
        return YES;
    }
    
}

//-(void)dealloc{
// [[NSNotificationCenter defaultCenter] removeObserver:self];
//}







@end
