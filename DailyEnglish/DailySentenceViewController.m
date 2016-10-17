//
//  DailySentenceViewController.m
//  DailyEnglish
//
//  Created by min-mac on 16/10/12.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

#import "DailySentenceViewController.h"
#import "DailySentence.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking.h>

#define BaseURL "http://open.iciba.com/dsapi/?date="
#define SECONDS_PER_DAY (24 * 60 * 60)

@interface DailySentenceViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *englishLabel;
@property (weak, nonatomic) IBOutlet UILabel *chineseLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarButtomConstraint;

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic) int colorFlag;

@property (nonatomic, strong) DailySentence *sentence;
@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation DailySentenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentDate = [[NSDate alloc] init];
    self.colorFlag = 1;
    self.toolBarButtomConstraint.constant = -44;
    
}

- (NSString *)convertDateToString: (NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    NSString *dateString = [formatter stringFromDate:date];
    
    NSLog(@"hello ege %@", dateString);
    
    return dateString;
}

- (void)loadDailySentence: (NSDate *)currentDate {
    
    NSString *date = [self convertDateToString:currentDate];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"%s%@", BaseURL, date];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data == nil) {
            NSLog(@"There is no data");
            return;
        }
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        //NSLog(@"%@", result);
        
        self.sentence = [[DailySentence alloc] initWithDictionary:result];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.englishLabel.text = self.sentence.englishText;
            self.chineseLabel.text = self.sentence.chineseText;
            [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:self.sentence.pictureUrl]];
        });
        
    }];
    
    [task resume];
    
}

- (void)setCurrentDate:(NSDate *)currentDate {
    _currentDate = currentDate;
    
    [self loadDailySentence:currentDate];
}

#pragma mark - Action
- (IBAction)loadPreviousSentence:(UISwipeGestureRecognizer *)sender {
    self.currentDate = [NSDate dateWithTimeInterval:-SECONDS_PER_DAY sinceDate:self.currentDate];
}

- (IBAction)loadNextSentence:(UISwipeGestureRecognizer *)sender {
    self.currentDate = [NSDate dateWithTimeInterval:SECONDS_PER_DAY sinceDate:self.currentDate];
}

- (IBAction)playAudio:(UIBarButtonItem *)sender {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *documentsDirectoryURL = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-day.mp3", [self convertDateToString:self.currentDate]]];
    NSString *filePath = fileURL.path;
    
    if ([fileManager fileExistsAtPath:filePath]) {
        NSData *ttsData = [[NSData alloc] initWithContentsOfURL:fileURL];
        self.player = [[AVAudioPlayer alloc] initWithData:ttsData error:nil];
        self.player.volume = 1.0;
        [self.player prepareToPlay];
        [self.player play];
        
        return;
    }
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:self.sentence.ttsUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *ttsData = [[NSData alloc] initWithContentsOfURL:filePath];
            self.player = [[AVAudioPlayer alloc] initWithData:ttsData error:nil];
            self.player.volume = 1.0;
            [self.player prepareToPlay];
            [self.player play];
        });
        
    }];
    
    [downloadTask resume];
}


- (IBAction)changeTextColor:(UIButton *)sender {
    
    if (self.colorFlag == 1) {
        self.colorFlag = 0;
    }
    else {
        self.colorFlag = 1;
    }
    
    UIColor *textColor = [UIColor colorWithRed:self.colorFlag green:self.colorFlag blue:self.colorFlag alpha:1.0];
    
    self.englishLabel.textColor = textColor;
    self.chineseLabel.textColor = textColor;
}

- (IBAction)showToolBar:(UISwipeGestureRecognizer *)sender {
    
    self.toolBarButtomConstraint.constant = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)hideToolBar:(UISwipeGestureRecognizer *)sender {
    
    self.toolBarButtomConstraint.constant = -44;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)savePicture:(UIBarButtonItem *)sender {
    
    CGSize containerSize = self.containerView.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(containerSize, NO, 1.0);
    
    [self.containerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    UIGraphicsEndImageContext();
}

@end
