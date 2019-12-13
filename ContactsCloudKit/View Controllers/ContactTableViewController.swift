//
//  ContactTableViewController.swift
//  ContactsCloudKit
//
//  Created by Kyle Jennings on 12/13/19.
//  Copyright © 2019 Kyle Jennings. All rights reserved.
//

import UIKit

// Protocol to search for matching contact names
protocol SearchableContactDelegate: class {
  func matches(searchTerm: String) -> Bool
}

class ContactTableViewController: UITableViewController, UISearchBarDelegate {
  // MARK: - Outlets
  @IBOutlet weak var searchBar: UISearchBar!
  
  // MARK: - Properties
  // This will be an array of searched Contacts
  var resultsArray: [Contact] = []
  // Will be able to tell if a user is searching
  var isSearching = false
  // Computed property that returns an array of contacts to use for searching
  var dataSource: [Contact] {
    // Ternary operator that displays the results array if a user is searching, or all the contacts if a user is not searching
    return isSearching ? resultsArray : ContactController.shared.contacts
  }
  
  // Creating our delegate for protocol
  weak var delegate: SearchableContactDelegate?
  
  // MARK: - Lifecycle Functions
  override func viewDidLoad() {
    super.viewDidLoad()
    // Need to set ourselves as the searchbar delegate
    searchBar.delegate = self
    // Custom function to fetch all contacts
    fetchContacts()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // Custom function to update the views
    updateViews()
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Returning the datasource count, cant be searched, or not
    return dataSource.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
    
    // Creating the contact based off the datasource, again, can be searched or not
    let contact = dataSource[indexPath.row]
    cell.textLabel?.text = contact.name
    
    return cell
  }
  
  
  
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let contact = dataSource[indexPath.row]
      ContactController.shared.deleteContact(contact: contact) { (success) in
        // Need to be on main thread to delete row
        DispatchQueue.main.async {
          tableView.deleteRows(at: [indexPath], with: .fade)
        }
      }
    }
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Setting search bar text empty once a segue has been triggered
    searchBar.text = ""
    if segue.identifier == "toDetailVC" {
      guard let destinationVC = segue.destination as? ContactDetailViewController,
        let indexPath = tableView.indexPathForSelectedRow
        else {return}
      // Setting the detailVC's contact
      destinationVC.contactLanding = dataSource[indexPath.row]
    }
  }
  
  // MARK: - Search Bar Delegate Functions
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    // If the search text is not empty we want to filter our array based on matches of the search term
    if searchText != "" {
      isSearching = true
      resultsArray = ContactController.shared.contacts.filter {$0.matches(searchTerm: searchText)}
      self.tableView.reloadData()
    } else {
      isSearching = false
      self.tableView.reloadData()
    }
  }
  
  // MARK: - Custom Functions
  // Custom function to fetch contacts, keeps the code cleaner
  func fetchContacts() {
    ContactController.shared.fetchContacts { (success) in
      if success {
        self.updateViews()
      }
    }
  }
  
  // Custom function to update the views on the main thread
  func updateViews() {
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
}// end of class
