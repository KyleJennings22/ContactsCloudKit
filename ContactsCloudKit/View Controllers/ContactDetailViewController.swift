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
  @IBAction func saveContactButtonTapped(_ sender: UIBarButtonItem) {
    guard let name = nameTextField.text,
      let phoneNumber = phoneNumberTextField.text,
      let emailAddress = emailTextField.text,
      !name.isEmpty
      else {return}
    
    if contactLanding == nil {
      ContactController.shared.createContact(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress) { (success) in
        if success {
          self.popViewController()
        }
      }
    } else {
      guard let contact = contactLanding else {return}
      contact.name = name
      contact.phoneNumber = phoneNumber
      contact.emailAddress = emailAddress
      ContactController.shared.updateContact(contact: contact) { (success) in
        if success {
          self.popViewController()
        }
      }
    }
  }
  
  func updateViews() {
    guard let contact = contactLanding else {return}
    DispatchQueue.main.async {
      self.nameTextField.text = contact.name
      self.phoneNumberTextField.text = contact.phoneNumber
      self.emailTextField.text = contact.emailAddress
    }
  }
  
  func popViewController() {
    DispatchQueue.main.async {
      self.navigationController?.popViewController(animated: true)
    }
  }
}
