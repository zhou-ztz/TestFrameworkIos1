//
//  TSCommonTool.m
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/6/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import "TSCommonTool.h"
#import <mach/mach.h>
#import <CommonCrypto/CommonDigest.h>

@implementation TSCommonTool

+ (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f9de) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3 || ls == 0xfe0f || ls == 0xd83c) {
                 returnValue = YES;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    return returnValue;
}
// 字符串截取
+ (NSString *)getStriingFromString:(NSString *) originalString rang:(NSRange)rang {
    NSString *resultString = [originalString substringWithRange:rang];
    return resultString;
}
// 删除某一个rang的字符串
+ (NSString *)deleteStringFromString:(NSString *) originalString rang:(NSRange)rang {
    NSString *resultString;
    NSString *subStr = [originalString substringToIndex:rang.location];
    NSString *endStr = [originalString substringFromIndex:rang.location + rang.length];
    resultString = [NSString stringWithFormat:@"%@%@", subStr, endStr];
    return resultString;
}
+ (UITextView *)atMeTextViewEdit:(UITextView*) textView {
    NSRange selectedRange = textView.selectedRange;
    if (selectedRange.location > 0) {
        NSString *editLeftChar = [textView.text substringWithRange:NSMakeRange(selectedRange.location - 1, 1)];
        if ([editLeftChar isEqualToString:@"@"]) {
            textView.text = [TSCommonTool deleteStringFromString:textView.text rang:NSMakeRange(selectedRange.location - 1, 1)];
            textView.selectedRange = NSMakeRange(selectedRange.location - 1, 0);
        }
    }
    return textView;
}
// MARK: 大文件的MD5获取
+ (NSString*)fileMD5:(NSString*)filePath {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength:256];
        //        CHUNK_SIZE
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
        if( [fileData length] == 0 ) {
            done = YES;
        }
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}
// MARK: 获取文件大小
+ (NSInteger)getFileSize:(NSString*)filePath {
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:filePath]) {
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:filePath error:nil];
        NSNumber *theFileSize = [attributes objectForKey:NSFileSize];
        return [theFileSize integerValue];
    } else {
        return 0;
    }
}
// MARK: 向一个富文本中添加属性
+ (NSMutableAttributedString*)string:(NSAttributedString *)orgString addpendAtrrs:(NSArray<NSDictionary*>*)attrs strings:(NSArray<NSString*>*)strings {
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:orgString];
    if (attrs.count == 0 || attrs.count != strings.count) {
        return [[NSMutableAttributedString alloc] initWithAttributedString:orgString];
    }
    NSString *replaceString = @"œ";
    NSString *waitFixString = orgString.string;
    for (int i = 0; i < strings.count; i ++) {
        NSRange range = [waitFixString rangeOfString:strings[i]];
        if (range.length == 0) {
            continue;
        }
        /// 替换第一个匹配到的文本之前的所有内容，避免strings中内容没有顺序被匹配
        for (int j = 0; j < range.location; j ++) {
            waitFixString = [waitFixString stringByReplacingCharactersInRange:NSMakeRange(j, 1) withString:replaceString];
        }
        /// 替换第一个匹配到的文本内容，避免strings中有多个相同的内容而导致只能设置第一个匹配到的属性
        for (int j = 0; j < range.length; j ++) {
            waitFixString = [waitFixString stringByReplacingCharactersInRange:NSMakeRange(range.location + j, 1) withString:replaceString];
            
        }
        [mutableAttributedString setAttributes:attrs[i] range:range];
    }
    return mutableAttributedString;
}
@end
