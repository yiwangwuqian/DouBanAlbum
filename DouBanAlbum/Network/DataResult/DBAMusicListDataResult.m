//
//  DBAMusicListDataResult.m
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/2.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "DBAMusicListDataResult.h"
#import "DBAAlbumBriefModel.h"
#import "MCModelDBManger.h"

@implementation DBAMusicListDataResult

- (id)validateResult:(id)result withError:(NSError *__autoreleasing *)error
{
    NSDictionary *resultDictionary = result;
    NSArray *musicArray = resultDictionary[@"musics"];
    if (!musicArray){
        return nil;
    }
    
    NSString *total = resultDictionary[@"total"];
    if (total && [total integerValue]){
        self.total = [total integerValue];
    }
    
//    NSString *start = resultDictionary[@"start"];
//    if (start && [start integerValue]){
//        self.start = [start integerValue];
//    }
    
    NSMutableArray *albums = [[NSMutableArray alloc] init];
    for (NSDictionary *albumDictionary in musicArray){
        
        @autoreleasepool {
        NSMutableDictionary *albumBriefDictionary = [[NSMutableDictionary alloc] init];
        NSString *ID = [albumDictionary objectForKey:@"id"];
        if (ID){
            [albumBriefDictionary setObject:ID
                                     forKey:@"id"];
        }
        NSString *title = [albumDictionary objectForKey:@"title"];
        if (title){
            [albumBriefDictionary setObject:title
                                     forKey:@"title"];
        }
        NSArray *author = [albumDictionary objectForKey:@"author"];
        if (author && author.count){
            NSString *authorNames = @"";
            for (NSDictionary *authorInfo in author){
                NSString *name = [authorInfo objectForKey:@"name"];
                if (name){
                    authorNames = [authorNames stringByAppendingString:name];
                }
            }
            [albumBriefDictionary setObject:authorNames
                                     forKey:@"author"];
        }
        
        NSArray *pubdate = [[albumDictionary objectForKey:@"attrs"] objectForKey:@"pubdate"];
        if (pubdate && pubdate.count){
            [albumBriefDictionary setObject:pubdate.firstObject
                                     forKey:@"pubdate"];
        }
        NSString *image = [albumDictionary objectForKey:@"image"];
        if (image){
            [albumBriefDictionary setObject:image
                                     forKey:@"image"];
        }
        NSString *mobile_link = [albumDictionary objectForKey:@"mobile_link"];
        if (image){
            [albumBriefDictionary setObject:mobile_link
                                     forKey:@"mobile_link"];
        }
        
        DBAAlbumBriefModel *briefModel = [[DBAAlbumBriefModel alloc] initWithDictionary:albumBriefDictionary error:error];
        if (!briefModel){
            return nil;
            break;
        }
        
        [albums addObject:briefModel];
        }
    }
    
    return albums;
}

- (void)storeResult:(id)result withError:(NSError *__autoreleasing *)error
{
    if (![result isKindOfClass:[NSArray class]]){
        return;
    }
    
    [[MCModelDBManger defaultManager] saveArray:result];
}

- (void)loadBufferDataWithCompletion:(DBADataResultLoadedBufferBlock)completion
{
    
}

@end
