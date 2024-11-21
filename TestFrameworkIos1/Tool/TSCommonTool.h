//
//  TSCommonTool.h
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/6/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TSCommonTool : NSObject
// 字符串是否包含emoji
+ (BOOL)stringContainsEmoji:(NSString *)string;

// 字符串截取
+ (NSString *)getStriingFromString:(NSString *) originalString rang:(NSRange)rang;
// 删除某一个rang的字符串
+ (NSString *)deleteStringFromString:(NSString *) originalString rang:(NSRange)rang;
// 处理@我的的输入框
+ (UITextView *)atMeTextViewEdit:(UITextView*) textView;

// 大文件的MD5加密
+ (NSString*)fileMD5:(NSString*)filePath;

// 获取文件大小
+ (NSInteger)getFileSize:(NSString*)filePath;

/// 向一个富文本中添加属性
/// orgString: 富文本/可变富文本
/// attrs: 添加的属性字典
/// strings: 需要顺次匹配的string集合
+ (NSMutableAttributedString*)string:(NSAttributedString *)orgString addpendAtrrs:(NSArray<NSDictionary*>*)attrs strings:(NSArray<NSString*>*)strings;

@end
