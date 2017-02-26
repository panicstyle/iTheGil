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

//@synthesize respData;
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
	switchPush = storage.switchPush;
    
	NSLog(@"LoginToService...");
	NSLog(@"id = %@", userid);
	NSLog(@"pwd = %@", userpwd);
	NSLog(@"push = %@", switchPush);
	
	if (userid == nil || [userid isEqualToString:@""] || userpwd == nil || [userpwd isEqualToString:@""]) {
        return FALSE;
	}
    
    NSLog(@"Before Logout");
   [self Logout];
    NSLog(@"After Logout");
//    [self GetMain];
	
	NSString *url;
	url = [NSString stringWithFormat:@"%@/login-process.do", WWW_SERVER];
	////NSLog(@"url = [%@]", url);
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *strReferer = [NSString stringWithFormat:@"%@/MLogin.do", WWW_SERVER];
	
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request addValue:strReferer forHTTPHeaderField:@"Referer"];
 
	NSString *uid = [userid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    NSString *upwd = [userpwd stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"userId=%@&userPw=%@&boardId=&boardNo=&page=1&categoryId=-1&returnURI=&returnBoardNo=&beforeCommand=&command=LOGIN", uid, upwd]  dataUsingEncoding:NSUTF8StringEncoding]];
 
    [request setHTTPBody:body];
 
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"returnString = [%@]", returnString);
    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
    if (returnString && [returnString rangeOfString:@"<script language=javascript>moveTop()</script>"].location != NSNotFound) {
        return TRUE;
    } else {
		if ([Utils numberOfMatches:returnString regex:@"<b>시스템 메세지입니다</b>"] > 0) {
			return FALSE;
		} else {
			return TRUE;
		}
    }

    return FALSE;
}

- (void)Logout
{
	NSString *url;
	url = [NSString stringWithFormat:@"%@/logout.do", WWW_SERVER];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSMutableData *body = [NSMutableData data];
    [request setHTTPBody:body];
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

- (void)GetMain
{
	NSString *url;
	url = [NSString stringWithFormat:@"%@/MLogin.do", WWW_SERVER];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSMutableData *body = [NSMutableData data];
    [request setHTTPBody:body];
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

@end
