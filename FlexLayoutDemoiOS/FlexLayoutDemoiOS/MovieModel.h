//
//  MovieModel.h
//  FlexLayoutDemoiOS
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import <Foundation/Foundation.h>

#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

@interface MovieModel : NSObject

@property (copy, nonatomic, readonly) NSString *title;
@property (copy, nonatomic, readonly) NSString *plot;

+ (instancetype)movieWithDictionary:(NSDictionary *)dictionary;

- (void)fetchPoster:(void (^)(id image))completion;
- (void)cancelFetchPoster;
@end
