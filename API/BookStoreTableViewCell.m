//
//  BookStoreTableViewCell.m
//  LSYReader
//
//  Created by hongli on 16/7/29.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "BookStoreTableViewCell.h"
#define WIDTH  [UIScreen mainScreen].applicationFrame.size.width
#define HEIGHT [UIScreen mainScreen].applicationFrame.size.height

@implementation BookStoreTableViewCell

-(void)cellBindingwithBookModel:(BookModel*) model withIndexPath:(NSIndexPath *)indexPath{
    self.model = model;
    self.indexPath = indexPath;
    
    _bookTitle.text = model.bookName;
    _authorName.text = model.authorName;
    
    BOOL down = [DBManager isBookDown:self.model.bookID];
    if (down) {
        [_downloadBtn setTitle:@"开始阅读" forState:UIControlStateNormal];
    }else{
        [_downloadBtn setTitle:@"下载" forState:UIControlStateNormal];

    }
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _bookTitle = [[UILabel alloc]init];
        _authorName = [[UILabel alloc]init];
       _downloadBtn = [[UIButton alloc]init];
        _progressBar = [[UIProgressView alloc]init];
        _progressBar.progress = 0;
        _progressBar.hidden = YES;
        [_bookTitle setText:@"书名灌灌灌灌灌灌灌灌灌灌"];
        [_authorName setText:@"作者名"];
        [_downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        [_downloadBtn setBackgroundColor:[UIColor grayColor]];
        [_downloadBtn addTarget:self action:@selector(downloadBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        
        [self addSubview:_bookTitle];
        [self addSubview:_authorName];
        [self addSubview:_downloadBtn];
        [self addSubview:_progressBar];
    }
    return self;
}

- (void)layoutSubviews
{
    int height = self.frame.size.height/2;
    _bookTitle.frame = CGRectMake(10, 20, (WIDTH-10*4)/3, height);
    _authorName.frame = CGRectMake(_bookTitle.frame.size.width+20, 20, (WIDTH-10*4)/3, height);
    _downloadBtn.frame = CGRectMake(_bookTitle.frame.size.width+_authorName.frame.size.width+30, 20, (WIDTH-10*4)/3, height);
    //自适应高度
    //自动折行设置
    _bookTitle.lineBreakMode = NSLineBreakByWordWrapping;
    _bookTitle.numberOfLines = 0;
    CGRect txtFrame = _bookTitle.frame;
    
    _bookTitle.frame = CGRectMake(10, 20, (WIDTH-10*4)/3,
                                  txtFrame.size.height =[_bookTitle.text boundingRectWithSize:
                                                         CGSizeMake(txtFrame.size.width, CGFLOAT_MAX)
                                                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                   attributes:[NSDictionary dictionaryWithObjectsAndKeys:_bookTitle.font,NSFontAttributeName,  nil] context:nil].size.height);
    _bookTitle.frame = CGRectMake(10, 20, (WIDTH-10*4)/3, txtFrame.size.height);
    _progressBar.frame = CGRectMake(10, self.frame.size.height-10, WIDTH-20, 10);

    
}

//第二步：
//在自定义的UITableViewCell里重写drawRect：方法
#pragma mark - 绘制Cell分割线
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线，
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:198/255.0 green:198/255.0 blue:198/255.0 alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(10, 0, rect.size.width-20, 0.01));
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:198/255.0 green:198/255.0 blue:198/255.0 alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(10, rect.size.height+50, rect.size.width-20, 0.01));
}


-(void)downloadBtnPressed:(UIButton*)btn{
    //实现按钮不同状态的切换
    btn.selected=!btn.selected;
    if(![[btn currentTitle]isEqualToString:@"开始阅读"]){
        [self.progressBar setHidden:NO];
       
        [self.delegate statDownBookWithBookModel:self.model withIndexPath:self.indexPath];
    }else{//开始阅读
        BookModel* model = [DBManager fetchBookByID:[NSString stringWithFormat:@"%@",_model.bookID]];
        [_delegate StartReadingWithBookModel:model];
    }
    
}


// 新加代码

- (TWRDownloadProgressBlock)progressBlock {
    __weak typeof(self)weakSelf = self;
    return ^void(CGFloat progress){
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            // do something with the progress on the cell!
            strongSelf.progressBar.hidden = NO;
            strongSelf.progressBar.progress = progress;
            NSLog(@"--->%f",progress);

        });
    };
}

- (TWRDownloadCompletionBlock)completionBlock {//下载完成的回调
    __weak typeof(self)weakSelf = self;
    return ^void(BOOL completed){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^(void) {//异步执行的
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            // do something
            NSString *documentsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"/files"];
            
            strongSelf.model.filePath =[documentsPath stringByAppendingString:[NSString stringWithFormat:@"/%@.dat",strongSelf.model.bookName]];
            NSInteger type = [LSYReadModel judgeTheFileType:[NSURL URLWithString:[strongSelf.model.filePath
                                                                                                                                                                            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];//TXT不这样处理会返回nil];
            strongSelf.model.bookType = type;
            if([DBManager insertBookToDB:strongSelf.model]){//如果插入数据成功
                dispatch_async(dispatch_get_main_queue(), ^(void) {//更新UI
                    [strongSelf.downloadBtn setTitle:@"开始阅读" forState:UIControlStateNormal];
                    strongSelf.progressBar.hidden = YES;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewBookDownloaded" object:@"success"];
                });
            };
            
       });
    };
}

-(void)prepareForReuse {
    self.progressBlock = nil;
}

@end
