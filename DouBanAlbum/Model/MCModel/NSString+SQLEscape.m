//
//  NSString+SQLEscape.m
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/2.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "NSString+SQLEscape.h"

@implementation NSString(SQLEscape)

- (NSString *)stringBySQLEscape
{
    __block NSString *result = [NSString stringWithString:self];
    
    static NSArray* targetArray = nil;
    if (!targetArray){
        //        targetArray = @[@"/",@"'",@"[",@"]",@"%",@"&",@"_",@"(",@")"];
        targetArray = @[@"'"];
    }
    static NSArray* replaceArray = nil;
    if (!replaceArray){
        //        replaceArray = @[@"//",@"''",@"/[",@"/]",@"/%",@"/&",@"/_",@"/(",@"/)"];
        replaceArray = @[@"''"];
    }
    
    for (NSString *target in targetArray){
        if ([result rangeOfString:target].location!= NSNotFound){
            result = [result stringByReplacingOccurrencesOfString:target
                                                       withString:[replaceArray objectAtIndex:[targetArray indexOfObject:target]]];
            
        }
    }
    
    return result;
}

@end
