//
//  NSString+Util.h
//  DemoKhipu
//
//  Created by Iván on 12/5/13.
//  Copyright (c) 2013 khipu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)
-(BOOL)containsString: (NSString*)substring
              atRange:(NSRange*)range;

-(BOOL)containsString:(NSString *)substring;
@end
