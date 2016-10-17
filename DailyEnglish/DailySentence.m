//
//  DailySentence.m
//  DailyEnglish
//
//  Created by min-mac on 16/10/12.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

#import "DailySentence.h"

@implementation DailySentence

- (instancetype)initWithDictionary: (NSDictionary *)dict {
    
    if (self = [super init]) {
        
        _englishText = dict[@"content"];
        _chineseText = dict[@"note"];
        _pictureUrl = dict[@"picture2"];
        _ttsUrl = dict[@"tts"];
    }
    
    return self;
}

@end
