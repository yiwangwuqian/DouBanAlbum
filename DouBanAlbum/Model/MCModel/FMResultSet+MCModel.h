//
//  FMResultSet+MCModel.h
//  MCModel
//
//  Created by ~DD~ on 15/11/30.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "FMDB.h"

@protocol MCModelMap;
@interface FMResultSet(MCModel)

/** 
 MC version `kvcMagic:`.
 */
- (void)mc_kvcMagic:(NSObject<MCModelMap> *)object;

@end
