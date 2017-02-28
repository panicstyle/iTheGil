//
//  CommentWriteView.m
//  iGongdong
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//


#import "CommentWriteView.h"
#import "env.h"
#import "utils.h"

@interface CommentWriteView () {
	NSString *m_strErrorMsg;
	long m_lContentHeight;
	UIAlertView *alertWait;
}
@end

@implementation CommentWriteView
@synthesize m_nMode;
@synthesize m_textView;
@synthesize m_strBoardId;
@synthesize m_strBoardNo;
@synthesize m_strCommentNo;
@synthesize m_strComment;
@synthesize target;
@synthesize selector;

- (CommentWriteView *) initWithBoard:(NSString *)strBoardId Article:(NSString *)strBoardNo Comment:(NSString *)strCommentNo
{
	////NSLog(@"WriteArticleViewController start");
	m_strBoardId = strBoardId;
	m_strBoardNo = strBoardNo;
	m_strCommentNo = strCommentNo;
	
	return self;
}

- (void)setDelegate:(id)aTarget selector:(SEL)aSelector
{
	// 데이터 수신이 완료된 이후에 호출될 메서드의 정보를 담고 있는 셀렉터 설정
	self.target = aTarget;
	self.selector = aSelector;
}

- (void)viewDidLoad
{
	m_strErrorMsg = @"";
	
	CGRect rectScreen = [self getScreenFrameForCurrentOrientation];
	m_lContentHeight = rectScreen.size.height;
	
	if ([m_nMode intValue] == CommentWrite) {
		[(UILabel *)self.navigationItem.titleView setText:@"댓글쓰기"];
	} else if ([m_nMode intValue] == CommentModify) {
		[(UILabel *)self.navigationItem.titleView setText:@"댓글수정"];
		m_textView.text = m_strComment;
	} else {
		[(UILabel *)self.navigationItem.titleView setText:@"댓글답변쓰기"];
	}
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithTitle:@"완료"
											   style:UIBarButtonItemStyleDone
											   target:self
											   action:@selector(doneEditing:)];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
											  initWithTitle:@"취소"
											  style:UIBarButtonItemStylePlain
											  target:self
											  action:@selector(cancelEditing:)];
	
	// Listen for keyboard appearances and disappearances
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification
											   object:nil];


	// Prepare the Navigation Item
	[(UILabel *)self.navigationItem.titleView setBackgroundColor:[UIColor clearColor]];
	[(UILabel *)self.navigationItem.titleView setTextColor:[UIColor whiteColor]];
	[(UILabel *)self.navigationItem.titleView setTextAlignment:NSTextAlignmentCenter];
	[(UILabel *)self.navigationItem.titleView setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
}

- (void)keyboardDidShow: (NSNotification *) notif{
	// Do something here
	[self animateTextView:notif up:YES];
}

- (void)keyboardDidHide: (NSNotification *) notif{
	// Do something here
	[self animateTextView:notif up:NO];
}

-(void)animateTextView:(NSNotification *)notif up:(BOOL)up
{
	NSDictionary* keyboardInfo = [notif userInfo];
	NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
	CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
	
	const int movementDistance = keyboardFrameBeginRect.size.height; // tweak as needed
	const float movementDuration = 0.3f; // tweak as needed
	
	int movement = (up ? -movementDistance : movementDistance);
	
	[UIView beginAnimations: @"animateTextView" context: nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationDuration: movementDuration];
	
	CGRect viewRect = self.view.frame;
	viewRect.size.height = viewRect.size.height + movement;
	self.view.frame = viewRect;
	
	//	CGRect tableRect = self.tbView.frame;
	//	tableRect.size.height = tableRect.size.height + movement;
	//	self.tbView.frame = tableRect;
	
	CGRect contentRect = m_textView.frame;
	contentRect.size.height = contentRect.size.height + movement;
	m_textView.frame = contentRect;
	
	//	CGRect textRect = m_contentView.frame;
	//	textRect.size.height = textRect.size.height + movement;
	//	m_contentView.frame = textRect;
	
	//	CGRect imageRect = m_imageCell.frame;
	//	imageRect.size.height = imageRect.size.height;
	//	m_imageCell.frame = imageRect;
	
	[UIView commitAnimations];
}

- (CGRect)getScreenFrameForCurrentOrientation {
	return [self getScreenFrameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGRect)getScreenFrameForOrientation:(UIInterfaceOrientation)orientation {
	
	CGRect fullScreenRect = [[UIScreen mainScreen] bounds];
	
	// implicitly in Portrait orientation.
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		CGRect temp = CGRectZero;
		temp.size.width = fullScreenRect.size.height;
		temp.size.height = fullScreenRect.size.width;
		fullScreenRect = temp;
	}
	
	CGFloat statusBarHeight = 20; // Needs a better solution, FYI statusBarFrame reports wrong in some cases..
	fullScreenRect.size.height -= statusBarHeight;
	fullScreenRect.size.height -= self.navigationController.navigationBar.frame.size.height;
	fullScreenRect.size.height -= 40 + 40;
	
	return fullScreenRect;
}

- (void) cancelEditing:(id)sender
{
	//	[contentView resignFirstResponder];
	[[self navigationController] popViewControllerAnimated:YES];
}	

- (void)doneEditing:(id)sender
{
	BOOL result = [self writeComment];
	
	if (result) {
		[target performSelector:selector withObject:nil afterDelay:0];
		[[self navigationController] popViewControllerAnimated:YES];
	} else {
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"댓글 쓰기 오류"
																	   message:m_strErrorMsg
																preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[alert addAction:defaultAction];
	}
}

- (BOOL)writeComment
{
	NSString *url;
	
	url = [NSString stringWithFormat:@"%@/2014/bbs/write_comment_update.php", WWW_SERVER];
	
	NSLog(@"url = [%@]", url);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	
	NSMutableData *body = [NSMutableData data];
	
	NSString *strWmode = @"";
	if ([m_nMode intValue] == CommentWrite) {
		strWmode = @"c";
		m_strCommentNo = @"";
	} else if ([m_nMode intValue] == CommentModify) {
		strWmode = @"cu";
	} else {	// CommentReply
		strWmode = @"c";
	}
	[body appendData:[[NSString stringWithFormat:@"w=%@&bo_table=%@&wr_id=%@&comment_id=%@&sca=&sfl=&stx=&spt=&page=&is_good=0&wr_content=%@", strWmode, m_strBoardId, m_strBoardNo, m_strCommentNo, m_textView.text] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:body];
	
	NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	NSString *str = [[NSString alloc] initWithData:respData
										  encoding:NSUTF8StringEncoding];
	NSLog(@"str = [%@]", str);

	if ([Utils numberOfMatches:str regex:@"history.back"] > 0) {
		NSString *errmsg;
		errmsg = [Utils findStringRegex:str regex:@"(<p class=\\\"cbg\\\">).*?(</p>)"];
		errmsg = [Utils replaceStringHtmlTag:errmsg];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"글 작성 오류"
														message:errmsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
		[alert show];
		
		return false;
	} else {
		NSLog(@"delete comment success");
		return true;
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
@end
