#import <UIKit/UIKit.h>

@interface GalleryViewController : UITableViewController {
    // This array is passed to the controller by the application delegate.
	NSInteger numberRows;
	NSInteger columnsRemainder;
	int sectionNumber;
	int categoryNumber;
	
	NSMutableArray *assets;
}

@property (nonatomic, retain) NSMutableArray *assets;

- (id)initWithSectionNumber:(int)sec withCategoryNumber:(int)cat;
- (void)loadAssets;
@end
