//
//  SYNAutocompleteViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 05/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNSearchAutocompleteTableViewCell.h"
#import "SYNAutocompleteSuggestionsController.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"

#define kDataCutOffPoint 8

@interface SYNAutocompleteSuggestionsController ()

@end


@implementation SYNAutocompleteSuggestionsController

- (id) initWithStyle: (UITableViewStyle) style
{
    
    if ((self = [super initWithStyle:style]))
    {
        wordsArray = [[NSMutableArray alloc] init];
        rockpackFont = IS_IPAD ? [UIFont rockpackFontOfSize: 26.0] : [UIFont rockpackFontOfSize: 14.0];
        
        textColor = [UIColor colorWithRed: (187.0f/255.0f)
                                    green: (187.0f/255.0f)
                                     blue: (187.0f/255.0f)
                                    alpha: (1.0f)];
        
        
        tableBGColor = [UIColor rockpacLedColor];
        
        self.title = @"Suggestions";
    }
    
    return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor rockpacLedColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
    self.tableView.scrollsToTop = NO;
}


#pragma mark - Add Words

- (void) clearWords
{
    [wordsArray removeAllObjects];
    [self.tableView reloadData];
}


- (void) addWords: (NSArray*) words
{
    
    [wordsArray removeAllObjects];
    
    [wordsArray addObjectsFromArray: words];
    
    [self.tableView reloadData];
    
    
}


#pragma mark - Table view data source

- (CGFloat) tableHeight
{
    [self.tableView layoutIfNeeded];
    return [self.tableView contentSize].height;
}



- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return (wordsArray.count < kDataCutOffPoint) ? wordsArray.count : kDataCutOffPoint;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    if (!(cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier]))
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];

    if (IS_IPAD)
    {
        
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.backgroundColor = [UIColor clearColor];
        
        // Text
        cell.textLabel.font = rockpackFont;
        cell.textLabel.textColor = textColor;
        
        
        cell.textLabel.text = [((NSString*)wordsArray[indexPath.row]) capitalizedString];
    }
    else
    {
        cell = [[SYNSearchAutocompleteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        //Text
        cell.textLabel.font = rockpackFont;
        cell.textLabel.textColor = textColor;
        
        
        cell.textLabel.text = [((NSString*)wordsArray[indexPath.row]) capitalizedString];
    }

    return cell;
}


- (NSString*) getWordAtIndex: (NSInteger) index
{
    return (NSString*)wordsArray[index];
}


@end
