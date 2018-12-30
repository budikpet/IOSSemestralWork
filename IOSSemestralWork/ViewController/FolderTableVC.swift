//
//  FolderTableViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit

class FolderTableVC: ItemTableVC {
    
    var selectedFolder: Folder?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Data loading
    
    override func loadData() {
        super.loadData()
        
        if let currRssFeeds = selectedFolder?.myRssFeeds {
            for item in currRssFeeds {
                myItems.append(item)
            }
        }
    }

}