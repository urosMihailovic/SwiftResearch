//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Uroš Mihailović on 5/26/15.
//  Copyright (c) 2015 pstech. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {

    var tweets = [[Tweet]] ()
    var searchText : String? = "#stanford" {
        didSet {
            lastSuccessfulRequest = nil
            searchTextField?.text = searchText
            tweets.removeAll(keepCapacity: false)
            tableView.reloadData()
            refresh()
        }
    }
    
    func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        didRefresh(refreshControl!)
    }
    
    var lastSuccessfulRequest: TwitterRequest?
    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText  != nil {
                return TwitterRequest(search: self.searchText!, count: 100)
            } else {
                return nil
            }
        } else {
            return self.lastSuccessfulRequest!.requestForNewer
        }
    }
    
    @IBAction func didRefresh(sender: UIRefreshControl) {
        if searchText != nil {
            if let request = nextRequestToAttempt {
                let request = TwitterRequest(search: searchText!, count: 100)
                request.fetchTweets { (newTweets) -> Void in
                    self.lastSuccessfulRequest = request
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if newTweets.count > 0 {
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            sender.endRefreshing()
                        }
                    }
                    
                }
            }
        } else {
            sender.endRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        refresh()
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    
    private struct Storyboard {
        static let CellReuseID = "Tweet"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseID, forIndexPath: indexPath) as! TweetTableViewCell

         //Configure the cell...
        cell.tweet = tweets[indexPath.section][indexPath.row]

        return cell
    }
    

}
