#!/usr/bin/env python
#-*-coding:utf-8-*-  

#
# 
#

import httplib,urllib,sys;  #加载模块

team = 'fatboyli;paulineli;raycchen;vectorliu;wentaowang;fionazheng;dansun;xuejiaowang;vitodai;isaaczhang;qwarkhe';

file = open('build_mail.html', 'r');

mailContent = file.read();

mailTitle = 'iPad小应用+ ' + sys.argv[1] + ' 开始构建';
     
#定义需要进行发送的数据     
rtxParams = urllib.urlencode({'from':'QQBrowser_iPad_Dev',
                              'to':team,
                              'subject':mailTitle,
                              'content':'开始构建iPad小应用'});
    
headers = {"Content-Type":"application/x-www-form-urlencoded",     
           "Referer":"http://notify.et.wsd.com/MailService/send/mailbytof2"};
   
conn = httplib.HTTPConnection("notify.et.wsd.com");     

conn.request(method="POST",url="/MailService/send/rtx",body=rtxParams,headers=headers);

response = conn.getresponse();

#判断是否提交成功
if response.status == 200:
    print "发布成功!^_^!";
else:
    print "发布失败\^0^/";


#关闭连接     
conn.close();
file.close();