//
//  NSString+Util.m
//  DemoKhipu
//
//  Created by Iván on 12/5/13.
//  Copyright (c) 2013 khipu. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)
-(BOOL)containsString:(NSString *)substring
              atRange:(NSRange *)range{

    NSRange r = [self rangeOfString : substring];
    BOOL found = ( r.location != NSNotFound );
    if (range != NULL) *range = r;
    return found;
}


-(BOOL)containsString:(NSString *)substring
{
    return [self containsString:substring
                        atRange:NULL];
}
@end
