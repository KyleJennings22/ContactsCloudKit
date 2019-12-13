//
//  ContactTableViewController.swift
//  ContactsCloudKit
//
//  Created by Kyle Jennings on 12/13/19.
//  Copyright © 2019 Kyle Jennings. All rights reserved.
//

import UIKit

class ContactTableViewController: UITableViewController {
  
  // MARK: - Lifecycle Functions
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchContacts()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateViews()
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return ContactController.shared.contacts.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
    
    let contact = ContactController.shared.contacts[indexPath.row]
    cell.textLabel?.text = contact.name
    
    return cell
  }
  
  
  
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let contact = ContactController.shared.contacts[indexPath.row]
      ContactController.shared.deleteContact(contact: contact) { (success) in
        DispatchQueue.main.async {
          tableView.deleteRows(at: [indexPath], with: .fade)
        }
      }
    }
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toDetailVC" {
      guard let destinationVC = segue.destination as? ContactDetailViewController,
        let indexPath = tableView.indexPathForSelectedRow
        else {return}
      destinationVC.contactLanding = ContactController.shared.contacts[indexPath.row]
    }
  }
  
  // MARK: - Custom Functions
  func fetchContacts() {
    ContactController.shared.fetchContacts { (success) in
      if success {
        self.updateViews()
      }
    }
  }
  
  func updateViews() {
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
}// end of class
