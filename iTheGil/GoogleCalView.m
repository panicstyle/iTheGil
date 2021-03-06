//
//
//  GoogleCalView.m
//  iGongdong
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "GoogleCalView.h"
#import "env.h"
#import "Utils.h"

@interface GoogleCalView () {
	NSMutableData *m_receiveData;
	NSURLConnection *m_connection;
}
@end

@implementation GoogleCalView
@synthesize webView;
@synthesize m_strCommId;
@synthesize m_strBoardId;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Replace this ad unit ID with your own ad unit ID.
	self.bannerView.adUnitID = kSampleAdUnitID;
	self.bannerView.rootViewController = self;
	
	GADRequest *request = [GADRequest request];
	// Requests test ads on devices you specify. Your test device ID is printed to the console when
	// an ad request is made. GADBannerView automatically returns test ads when running on a
	// simulator.
	request.testDevices = @[
							@"2077ef9a63d2b398840261c8221a0c9a"  // Eric's iPod Touch
							];
	[self.bannerView loadRequest:request];
	
	webView.delegate = self;
	webView.scrollView.scrollEnabled = YES;
	[self fetchItems];
}

- (void)fetchItems
{
	// http://cafe.gongdong.or.kr/cafe.php?p1=menbal&sort=cal43
	NSString *url = [NSString stringWithFormat:@"%@/cafe.php?p1=%@&sort=%@", WWW_SERVER, m_strCommId, m_strBoardId];
	
	m_receiveData = [[NSMutableData alloc] init];
	m_connection = [[NSURLConnection alloc]
					initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[m_receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *str = [[NSString alloc] initWithData:m_receiveData
									  encoding:NSUTF8StringEncoding];
	
	NSString *strContent = [Utils findStringWith:str from:@"<!-- 풍선 도움말 끝 -->" to:@"<!-- content 끝 -->"];
	
	[webView loadHTMLString:strContent baseURL:[NSURL URLWithString:WWW_SERVER]];
}
@end
