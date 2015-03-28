//
//  MasterViewController.swift
//  PHNewsApp
//
//  Created by Pinuno Fuentes on 3/27/15.
//  Copyright (c) 2015 UNO IT Solutions. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, MWFeedParserDelegate {

    var detailViewController: DetailViewController? = nil
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext


    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation item
//        self.navigationItem.leftBarButtonItem = self.editButtonItem()
//        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
//        self.navigationItem.rightBarButtonItem = addButton
        
        // split view controller
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        // init feed
        var URL = NSURL(string: "http://newsinfo.inquirer.net/feed")
        var feedParser = MWFeedParser(feedURL: URL);
        feedParser.delegate = self
        feedParser.parse()
        
        URL = NSURL(string: "http://feeds.feedburner.com/rappler/news")
        feedParser = MWFeedParser(feedURL: URL);
        feedParser.delegate = self
        feedParser.parse()
        
        URL = NSURL(string: "http://www.gmanetwork.com/news/rss/news")
        feedParser = MWFeedParser(feedURL: URL);
        feedParser.delegate = self
        feedParser.parse()
        
        URL = NSURL(string: "http://www.philstar.com/rss/headlines")
        feedParser = MWFeedParser(feedURL: URL);
        feedParser.delegate = self
        feedParser.parse()
        
        URL = NSURL(string: "http://www.abs-cbnnews.com/nation/feed")
        feedParser = MWFeedParser(feedURL: URL);
        feedParser.delegate = self
        feedParser.parse()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject)
                
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let feedItem = self.fetchedResultsController.objectAtIndexPath(indexPath) as FeedItem
        cell.textLabel!.text = feedItem.title
        cell.detailTextLabel!.text = feedItem.source
    }
    
    // MARK: - MWFeedParser
    
    func feedParserDidStart(parser: MWFeedParser!) {
        
    }
    
    func feedParserDidFinish(parser: MWFeedParser!) {
        appDelegate.saveContext()
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
        
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(FeedItemEntity.entityName, inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", item.identifier)
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [FeedItem] {
            if(fetchResults.count > 0) { return }
        }
        
        println("\(item.title)")
        println("\(item.content)")
        
        let feedItem = NSEntityDescription.insertNewObjectForEntityForName(FeedItemEntity.entityName, inManagedObjectContext: self.managedObjectContext!) as FeedItem
        feedItem.source = (parser.url().absoluteString! == "http://newsinfo.inquirer.net/feed" ? "Inquirer.net" : (parser.url().absoluteString! == "http://feeds.feedburner.com/rappler/news" ? "Rappler" :
            (parser.url().absoluteString! == "http://www.gmanetwork.com/news/rss/news" ? "GMA News" :
            (parser.url().absoluteString! == "http://www.philstar.com/rss/headlines" ? "PhilStar" :
            (parser.url().absoluteString! == "http://www.abs-cbnnews.com/nation/feed" ? "ABS-CBN News" :
                parser.url().absoluteString!)))))
        feedItem.identifier = item.identifier
        feedItem.title = item.title.stringByConvertingHTMLToPlainText()
        feedItem.link = item.link
        if let author = item.author {
            feedItem.author = author
        }
        feedItem.date = item.date
        feedItem.summary = item.summary
        if let content = item.content {
            feedItem.content = content
        }
        if let updated = item.updated {
            feedItem.updatedDate = item.updated
        }
        if let enclosures = item.enclosures {
        }
        //        feedItem.enclosures = item.enclosures
    }
    
    func feedParser(parser: MWFeedParser!, didFailWithError error: NSError!) {
        
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName(FeedItemEntity.entityName, inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	var error: NSError? = nil
    	if !_fetchedResultsController!.performFetch(&error) {
    	     // Replace this implementation with code to handle the error appropriately.
    	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //println("Unresolved error \(error), \(error.userInfo)")
    	     abort()
    	}
        
        
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

