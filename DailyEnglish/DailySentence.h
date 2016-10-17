//
//  DailySentence.h
//  DailyEnglish
//
//  Created by min-mac on 16/10/12.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DailySentence : NSObject

@property (readonly) NSString *englishText;
@property (readonly) NSString *chineseText;
@property (readonly) NSString *pictureUrl;
@property (readonly) NSString *ttsUrl;

- (instancetype)initWithDictionary: (NSDictionary *)dict;

@end
