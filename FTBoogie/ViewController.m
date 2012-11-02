#define FTBURL @"http://ftbpodcasts.libsyn.com/rss"
#import "ViewController.h"

@interface ViewController ()<NSXMLParserDelegate>
@property(strong,nonatomic)NSMutableString *innerContent;
@property(nonatomic)BOOL inItemTag;
@property(strong, nonatomic)NSMutableDictionary *firstPodcast;
@property (strong, nonatomic) IBOutlet UIImageView *podcastImageView;
@property (strong, nonatomic) IBOutlet UILabel *podcastTitleLabel;
@end

@implementation ViewController
-(void)grabXMLData
{
    self.inItemTag = NO;
    NSURL *url = [[NSURL alloc] initWithString:FTBURL];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [xmlParser setDelegate:self];
    BOOL success = [xmlParser parse];
    if (success) {
        self.podcastTitleLabel.text = self.firstPodcast[@"title"];
        self.podcastImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.firstPodcast[@"imageURL"]]];
    } else{
        
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)viewDidLoad
{
    self.firstPodcast = [[NSMutableDictionary alloc] init];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // Delay XML Parse so the indicators get set.  Parsing is synchronise, and will block indicators
    [self performSelector:@selector(grabXMLData) withObject:nil afterDelay:0.5];
}

#pragma mark - pragma NSXMLParser Delegate Methods
-(void)     parser:(NSXMLParser *)parser
   didStartElement:(NSString *)elementName
      namespaceURI:(NSString *)namespaceURI
     qualifiedName:(NSString *)qName
        attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"item"]) {
        self.inItemTag = YES;
    }
    if (self.inItemTag) {
        if ([elementName isEqualToString:@"title"]) {
            self.innerContent = [[NSMutableString alloc] init];
        }
        if ([elementName isEqualToString:@"media:thumbnail"]) {
            self.firstPodcast[@"imageURL"] = [NSURL URLWithString:[attributeDict objectForKey:@"url"]];
        }
    }
}
-(void)     parser:(NSXMLParser *)parser
   foundCharacters:(NSString *)string
{
    [self.innerContent appendString:string];
}
-(void)     parser:(NSXMLParser *)parser
     didEndElement:(NSString *)elementName
      namespaceURI:(NSString *)namespaceURI
     qualifiedName:(NSString *)qName
{
    if (self.inItemTag) {
        if ([elementName isEqualToString:@"title"]) {
            self.firstPodcast[@"title"] = self.innerContent;
            self.innerContent = nil;
        }
    }
    if ([elementName isEqualToString:@"item"]) {
        self.inItemTag = NO;
        [parser abortParsing];
    }
}

@end
