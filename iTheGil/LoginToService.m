//
//  LoginToService.m
//  iGongdong
//
//  Created by Panicstyle on 10. 10. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginToService.h"
#import "env.h"
#import "SetStorage.h"
#import "AppDelegate.h"
#import "Utils.h"
//#import "HTTPRequest.h"

@implementation LoginToService

@synthesize m_strError;
//@synthesize target;
//@synthesize selector;


- (BOOL)LoginToService
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *myPath = [documentsDirectory stringByAppendingPathComponent:@"set.dat"];
	
	SetStorage *storage = (SetStorage *)[NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
	
    userid = storage.userid;
    userpwd = storage.userpwd;
	
	NSLog(@"LoginToService...");
	NSLog(@"id = %@", userid);
	NSLog(@"pwd = %@", userpwd);
	
	if (userid == nil || [userid isEqualToString:@""] || userpwd == nil) {
        return FALSE;
	}
    	
	NSString *url;
	url = [NSString stringWithFormat:@"%@/2014/bbs/login_check.php", WWW_SERVER];
	////NSLog(@"url = [%@]", url);
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *strReferer = [NSString stringWithFormat:@"%@/index.php", WWW_SERVER];
	
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request addValue:strReferer forHTTPHeaderField:@"Referer"];
 
	NSString *uid = [userid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    NSString *upwd = [userpwd stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"url=http%%3A%%2F%%2Fthegil.org%%2F2014&mb_id=%@&mb_password=%@", uid, upwd]  dataUsingEncoding:NSUTF8StringEncoding]];
 
    [request setHTTPBody:body];
 
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"returnString = [%@]", returnString);
    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if ([Utils numberOfMatches:returnString regex:@"<title>오류안내 페이지"] > 0) {
		m_strError = [Utils findStringRegex:returnString regex:@"(?<=alert\\(\\\").*?(?=\\\"\\);)"];
		return FALSE;
    } else {
		return TRUE;
    }
}

@end
