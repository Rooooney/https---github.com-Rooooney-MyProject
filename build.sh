#!/bin/sh

#  build.sh
#  LiteReader
#
#  Created by wentaowang on 16/8/23.
#  Copyright © 2016年 okwei. All rights reserved.

# Init
SDK=$compileEnv
XCODE_PATH=$XCODE_PATH$compileEnv

scheme=${scheme:-LiteReader}
configuration=${configuration:-Distribution}

# LocalBuild=1
#scheme=LiteReader

if [ $WORKSPACE ] ;then
	echo "CI envoriment"
else
	WORKSPACE=$(pwd)
fi

#mail notify before compile
if [ "$BeforeCompileNotify" = "1" ] ;then

sed -i '' "s/<!--FullBundleVersion-->.*<!---->/<!--FullBundleVersion-->$NumberVersion<!---->/g" build_mail.html
python sendmail.py $NumberVersion

fi

cd $WORKSPACE

# Prepare
if [ -e  result ] ;then
rm -r result;
fi
mkdir result

#compile target

if [ -e buildTemp ] ;then
rm -r buildTemp;
fi

if [ -e build ] ;then
rm -r build
fi


mkdir -pv buildTemp/Payload
mkdir -pv build/DailyBuild-iphoneos

if [ -e ~/Library/Developer/Xcode/Archives/`date +%Y-%m-%d`/LiteReader\ *.xcarchive ];then
    rm -r ~/Library/Developer/Xcode/Archives/`date +%Y-%m-%d`/LiteReader\ *.xcarchive
    echo "exist"
fi

if [ "$LocalBuild" = "1" ] ;then
    xcodebuild -workspace LSYReader.xcworkspace -scheme $scheme -configuration Release archive -sdk iphoneos
else
    $XCODE_PATH -workspace LSYReader.xcworkspace -scheme $scheme -configuration $configuration -sdk $SDK archive
fi

cd buildTemp
rm * -rf

cp -r ~/Library/Developer/Xcode/Archives/`date +%Y-%m-%d`/$scheme\ *.xcarchive  $WORKSPACE/buildTemp/

zip xcarchive.zip -r $scheme\ *.xcarchive
cp -r $scheme\ *.xcarchive/Products/Applications/*.app Payload/
cp -r $scheme\ *.xcarchive/dSYMs/LiteReader.app.dSYM LiteReader.app.dSYM

/usr/bin/xcrun -sdk iphoneos PackageApplication -v Payload/LiteReader.app -o $WORKSPACE/buildTemp/result.ipa

zip symbol.zip -r LiteReader.app.dSYM

cp result.ipa $WORKSPACE/result/${BaseLine}.ipa
cp xcarchive.zip $WORKSPACE/result/${BaseLine}"(SVN_"$SVN_REVISION")".zip
cp symbol.zip $WORKSPACE/result/${UniqueID}.zip
 
sleep 1

cd $WORKSPACE

# Check
if ! [ $? = 0 ] ;then
exit 1
fi