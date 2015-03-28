//
//  DetailViewController.swift
//  PHNewsApp
//
//  Created by Pinuno Fuentes on 3/27/15.
//  Copyright (c) 2015 UNO IT Solutions. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let feedItem: FeedItem = self.detailItem as? FeedItem {
            if let label = self.titleLabel {
                label.text = feedItem.title
            }
            if let label = self.summaryLabel {
                label.text = feedItem.summary.stringByConvertingHTMLToPlainText()
            }
        }
    }
    
    func titleLabelTapped(label:UILabel) {
        if let feedItem: FeedItem = self.detailItem as? FeedItem {
            var webVC = SVWebViewController(address: feedItem.link)
            self.showViewController(webVC, sender: self)
            webVC.title = feedItem.source
//            SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:@"http://google.com"];
//            [self.navigationController pushViewController:webViewController animated:YES];
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        var titleLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "titleLabelTapped:");
        titleLabel.addGestureRecognizer(titleLabelTapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

