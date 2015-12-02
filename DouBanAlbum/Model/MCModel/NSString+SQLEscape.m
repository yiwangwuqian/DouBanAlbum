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
    NSString *result = nil;
    
    if ([self rangeOfString:@"\""].location!= NSNotFound){
        
        //
        result = [NSString stringWithString:self];
        
    }else if ([self rangeOfString:@"'"].location!= NSNotFound){
        result = [self stringByReplacingOccurrencesOfString:@"'"
                                                 withString:@"''"];
        
    }else{
        result = [NSString stringWithString:self];
    }
    
    return result;
}

@end
