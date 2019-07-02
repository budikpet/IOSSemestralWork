//
//  RSSFeedTableVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift

/**
 Displays all RssFeedItems of the selected feed or feeds.
 */
class RSSFeedTableVC: UITableViewController {
    var myRssItems: Results<MyRSSItem>?
    
    let dbHandler = DBHandler()
    let defaults = UserDefaults.standard
    
    lazy var refresher = RefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RssItemCell", bundle: nil), forCellReuseIdentifier: "RssItemCell")
        
        // Initialize PullToRefresh
        tableView.refreshControl = refresher
        refresher.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myRssItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RssItemCell", for: indexPath) as! RssItemCell
        
        if let myRssItem = myRssItems?[indexPath.row] {
            cell.setData(using: myRssItem)
        }
        
        return cell
    }
    
    // MARK: Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowRssItem", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            fatalError("Unreacheable tableViewCell selected.")
        }
        
        if segue.identifier == "ShowRssItem" {
            let destinationVC = segue.destination as! RSSItemVC
            
            destinationVC.title = title
            destinationVC.myRssItems = myRssItems
            destinationVC.selectedItemIndex = indexPath.row
        }
    }
}

// MARK: RefreshControlDelegate methods

extension RSSFeedTableVC: RefreshControlDelegate {
    
    /**
     Checks beginning of the PullToRefresh and updates its label.
     */
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset: CGFloat = 0
        if let frame = self.navigationController?.navigationBar.frame {
            offset = frame.minY + frame.size.height
        }
        
        if (-scrollView.contentOffset.y >= offset ) {
            refresher.refreshView.updateLabelText()
        }
    }
    
    func update() {
        print("requesting data")
        
        let refreshView: PullToRefreshView! = refresher.refreshView
        
        refreshView.startUpdating()
        dbHandler.updateAll() { status in
            
            // Hiding of the RefreshView is delayed to at least 0.5 s so that the updateLabel is visible.
            let deadline = DispatchTime.now() + .milliseconds(500)
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                print("End refreshing")
                refreshView.stopUpdating()
                self.refresher.endRefreshing()
                
                self.checkStatus(status)
                
                self.tableView.reloadData()
            }
        }
    }
    
    /**
     Checks status of the update.
     */
    private func checkStatus(_ status: DownloadStatus) {
        if status == DownloadStatus.Unreachable {
            // Internet is unreachable
            print("Internet is unreachable")
            self.view.makeToast("Internet is unreachable. Please try updating later.")
            
        } else {
            self.defaults.set(NSDate(), forKey: UserDefaultsKeys.LastUpdate.rawValue)
        }
    }
}
