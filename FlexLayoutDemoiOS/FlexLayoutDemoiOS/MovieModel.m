//
//  MovieModel.m
//  FlexLayoutDemoiOS
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import "MovieModel.h"

#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

@interface MovieModel ()
@property (strong, nonatomic) id poster;
@property (copy, nonatomic) NSDictionary *movieDictionary;
@property (strong, nonatomic) NSURLSessionDataTask *fetchPosterDataTask;
@end

@implementation MovieModel

#pragma mark - Class

+ (instancetype)movieWithDictionary:(NSDictionary *)dictionary
{
    MovieModel *movie = [MovieModel new];
    movie.movieDictionary = dictionary;
    return movie;
}

#pragma mark - Getter

- (NSString *)title
{
    return self.movieDictionary[@"Title"];
}

- (NSString *)plot
{
    return self.movieDictionary[@"Plot"];
}


#pragma mark - Poster

- (void)fetchPoster:(void (^)(id image))completion
{
    if (completion == nil) {
        return;
    }
    
    if (self.poster != nil) {
        completion(self.poster);
        return;
    }
    
    NSString *imageSrc = self.movieDictionary[@"Poster"];
    NSURL *url = [NSURL URLWithString:imageSrc];
    if (url == nil) {
        completion(nil);
        return;
    }
    
    NSURLSession *sharedURLSession = [NSURLSession sharedSession];
    self.fetchPosterDataTask = [sharedURLSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            if (error.code != NSURLErrorCancelled) {
                completion(nil);
            }
            return;
        }
        
        id image = nil;
#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
        image = [UIImage imageWithData:data];
#else
        image = [[NSImage alloc] initWithData:data];
#endif
        dispatch_async(dispatch_get_main_queue(), ^{
            self.poster = image;
            completion(image);
            
            self.fetchPosterDataTask = nil;
        });
    }];
    
    [self.fetchPosterDataTask resume];
}

- (void)cancelFetchPoster
{
    [self.fetchPosterDataTask cancel];
}

@end
