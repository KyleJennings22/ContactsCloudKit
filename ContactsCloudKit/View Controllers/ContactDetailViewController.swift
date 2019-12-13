//
//  ContactDetailViewController.swift
//  ContactsCloudKit
//
//  Created by Kyle Jennings on 12/13/19.
//  Copyright © 2019 Kyle Jennings. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
  
  // MARK: - Outlets
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var phoneNumberTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  
  // MARK: - Properties
  var contactLanding: Contact? {
    didSet {
      updateViews()
    }
  }
  
  // MARK: - Lifecycle Functions
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Actions
  @IBAction func saveContactButtonTapped(_ sender: UIBarButtonItem) {
    // Unwrapping our text fields, not guarding against phonenumber and email being empty because they can be nil
    guard let name = nameTextField.text,
      let phoneNumber = phoneNumberTextField.text,
      let emailAddress = emailTextField.text,
      !name.isEmpty
      else {return}
    
    // If contact landing is empty we will create a contact
    if contactLanding == nil {
      ContactController.shared.createContact(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress) { (success) in
        if success {
          // Used a custom function to pop view controllers on main thread
          self.popViewController()
        }
      }
    } else {
      // Contact landing is not empty so we need to update our contact
      guard let contact = contactLanding else {return}
      // Assigning the variables to the contact. Again, phone number and email address can be nil so we don't need to guard against them being empty
      contact.name = name
      contact.phoneNumber = phoneNumber
      contact.emailAddress = emailAddress
      // Passing in the contact to update
      ContactController.shared.updateContact(contact: contact) { (success) in
        if success {
          self.popViewController()
        }
      }
    }
  }
  
  // Custom funciton to update views on main thread
  func updateViews() {
    guard let contact = contactLanding else {return}
    DispatchQueue.main.async {
      self.nameTextField.text = contact.name
      self.phoneNumberTextField.text = contact.phoneNumber
      self.emailTextField.text = contact.emailAddress
    }
  }
  
  // Custom function to pop view controller on main thread
  func popViewController() {
    DispatchQueue.main.async {
      self.navigationController?.popViewController(animated: true)
    }
  }
}
