//
//  ArticleView.h
//  iGongdong
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMobileAds;

@interface ArticleView : UIViewController <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonArticleModify;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonArticleDelete;
@property (strong, nonatomic) NSString *m_strBoardId;
@property (strong, nonatomic) NSString *m_strBoardNo;
@property id target;
@property SEL selector;
@property (nonatomic, retain) UIDocumentInteractionController *doic;
@end
