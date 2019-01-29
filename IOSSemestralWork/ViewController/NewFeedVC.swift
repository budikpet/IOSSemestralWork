//
//  NewFeedViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift

protocol NewFeedDelegate {
    
    /**
     Validates the given RSS feed link address. The feed is then persisted in Realm.
     */
    func feedCreated(feed myRssFeed: MyRSSFeed)
    
//    func feedUpdated()
}

/**
 Displays the View used for creating new feeds.
 */
class NewFeedVC: UITableViewController {
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var pickerTableViewCell: UITableViewCell!
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var feedNameLabel: UITextField!
    @IBOutlet weak var feedLinkLabel: UITextField!
    
    let realm = try! Realm()
    let dbHandler = DBHandler()
    var delegate: NewFeedDelegate!
    
    /**
     If it's nil then new feed is created. If it isn't nil then this feed is updated.
     */
    var feedForUpdate: MyRSSFeed?
    var folders: Results<Folder>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        // Loads all folders from Realm, updates on changes.
        folders = realm.objects(Folder.self)
        
        if let feed = feedForUpdate {
            // Prepopulate all components of the screen
            feedNameLabel.text = feed.title
            feedLinkLabel.text = feed.link
            selectPickerRow(at: feed.folder!)
        } else {
            // There is always at least 1 folder
            folderNameLabel.text = folders!.first?.title
        }
    }
    
    func selectPickerRow(at folder: Folder) {
        folderNameLabel.text = folder.title
        picker.selectRow(folders!.index(of: folder) ?? 0, inComponent: 0, animated: false)
    }
    
    // MARK: NavBar items

    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {        
        var link = feedLinkLabel.text!
        
        if !link.starts(with: "http://") && !link.starts(with: "https://") {
            link = "http://" + link
        }
        
        var title = feedNameLabel.text!
        if title == "" {
            title = link
        }
        let selectedFolder = folders![picker.selectedRow(inComponent: 0)]
        
        var myRssFeed = feedForUpdate
        
        if myRssFeed != nil {
            // Update the feed
            do {
                let oldFolder: Folder = myRssFeed!.folder!
                let index: Int = oldFolder.myRssFeeds.index(of: myRssFeed!)!
                
                try realm.write {
                    myRssFeed?.title = title
                    myRssFeed?.link = link
                    
                    // Change folders
                    oldFolder.myRssFeeds.remove(at: index)
                    myRssFeed?.folder = selectedFolder
                    selectedFolder.myRssFeeds.append(myRssFeed!)
                }
            } catch {
                print("Error occured when updating the RSSFeed: \(error)")
            }
        } else {
            // Save the new feed
            myRssFeed = MyRSSFeed(with: title, link: link, folder: selectedFolder)
            dbHandler.create(myRssFeed!)
        }
        
        delegate.feedCreated(feed: myRssFeed!)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: TableView methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 && indexPath.section == 1 {
            // Show/ Hide picker view
            pickerTableViewCell.isHidden = !pickerTableViewCell.isHidden
            folderNameLabel.textColor = pickerTableViewCell.isHidden == true ? UIColor.black : UIColor.red
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: UIPickerView methods

extension NewFeedVC: UIPickerViewDelegate, UIPickerViewDataSource {
    /**
     Number of columns.
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     Number of rows.
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return folders?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return folders?[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let selectedFolder = folders?[row] {
            folderNameLabel.text = selectedFolder.title
        }
    }
}

// MARK: NewFolderDelegate

extension NewFeedVC: NewFolderDelegate {
    func folderCreated(_ folder: Folder) {
        picker.reloadAllComponents()
        selectPickerRow(at: folder)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCreateNewFolder" {
            let destinationVC = segue.destination as! NewFolderVC
            destinationVC.delegate = self
        }
    }
}
