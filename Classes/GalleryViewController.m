#import "GalleryViewController.h"
#import "Asset.h"
#import "IminentAppDelegate.h"
#import "Section.h"
#import "Category.h"
#import "LocalStorage.h"
#import "AssetView.h"

@implementation GalleryViewController

@synthesize assets;

- (void)dealloc {
	ZoozzLog(@"GalleryViewController - dealloc - section: %u, category: %u",sectionNumber,categoryNumber );
    
   [super dealloc];
}

- (id)initWithSectionNumber:(int)sec withCategoryNumber:(int)cat{
    if (self = [super initWithNibName:@"GalleryViewController" bundle:nil]) {
        sectionNumber = sec;
		categoryNumber = cat;
		
		IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
		Section * sec = [appDelegate.localStorage.sections objectAtIndex:sectionNumber];
		Category * cat = [sec.categories objectAtIndex:categoryNumber];
		
		
		NSInteger numberCells = [cat.assets count];
		numberRows = (numberCells-1) /4 + 1;
		columnsRemainder = (numberCells-1) % 4 + 1;
		
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
	
    // The table row height is not the standard value. Since all the rows have the same height, it is more efficient to
    // set this property on the table, rather than using the delegate method -tableView:heightForRowAtIndexPath:.
    //self.tableView.rowHeight = 79.0;
	self.tableView.rowHeight = 104.0;
	
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background galery -  simple.png"]];
	
	self.assets = [NSMutableArray array];
}

- (void)loadAssets {
	for (AssetView *assetView in assets ) {
		[assetView loadResources];
	}
}

- (void)cancelLoadAssets {
	for (AssetView *assetView in assets) {
		[assetView cancelLoad];
	}
}


- (void)viewDidUnload {
	ZoozzLog(@"GallertViewController - viewDidUnload - section: %u, category: %u",sectionNumber,categoryNumber );
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	/*
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	Section * sec = [appDelegate.localStorage.sections objectAtIndex:sectionNumber];
	Category * cat = [sec.categories objectAtIndex:categoryNumber];
	for(int i=0;i<[cat.assets count];i++) {
		Asset * asset = (Asset*)[cat.assets objectAtIndex:i];
		//asset.galleryView = nil;
	}
	*/
	[assets removeAllObjects];
	self.assets = nil;
	 
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// There is only one section.
	return 1;
}

// The number of rows is equal to the number of earthquakes in the array.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
		
    return numberRows;
}

// The cell uses a custom layout, but otherwise has standard behavior for UITableViewCell. In these cases,
// it's preferable to modify the view hierarchy of the cell's content view, rather than subclassing. Instead,
// view "tags" are used to identify specific controls, such as labels, image views, etc.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
	
	//static NSString *kAssetCellID = @"AssetCellID";    
	NSUInteger row = indexPath.row;
	NSString * assetCellID = [NSString stringWithFormat:@"%u",row];
  	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:assetCellID];
	if (cell == nil) {
		//cell = [cells objectAtIndex:row];
		NSString * assetCellID = [NSString stringWithFormat:@"%u",row]; 
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:assetCellID] autorelease];
	
		IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
		Section * sec = [appDelegate.localStorage.sections objectAtIndex:sectionNumber];
		Category * cat = [sec.categories objectAtIndex:categoryNumber];
		
		for (int i=0;i<4;i++) {
			
			int j = row*4+i;
			if (j>=[cat.assets count])
				break;
			
			Asset *asset = [cat.assets objectAtIndex:j];
			
			AssetView * assetView = [[AssetView alloc] initWithAsset:asset];
			assetView.frame = CGRectMake(i*80, 0 , 80, 104);
			[cell addSubview:assetView];
			[assets addObject:assetView];
			[assetView release];
			
						
		}
	} 
	
	return cell;
}





			
	

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.localStorage.backgroundLoad = NO;
}

/*
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.localStorage loadAssetsWithSection:sectionNumber withCategory:categoryNumber];
}
 */



@end

