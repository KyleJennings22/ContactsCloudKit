//
//  ContactController.swift
//  ContactsCloudKit
//
//  Created by Kyle Jennings on 12/13/19.
//  Copyright © 2019 Kyle Jennings. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
  // Decided to use a singleton
  static let shared = ContactController()
  var contacts: [Contact] = []
  // Contacts are private, so using a private cloud database
  let privateDB = CKContainer.default().privateCloudDatabase
  
  
  func createContact(name: String, phoneNumber: String?, emailAddress: String?, completion: @escaping (Bool) -> Void) {
    // Creating our contact and record
    let contact = Contact(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress)
    let record = CKRecord(contact: contact)
    
    privateDB.save(record) { (record, error) in
      if let error = error {
        print("Error saving contact:", error.localizedDescription)
        return completion(false)
      }
      guard let record = record,
        let newContact = Contact(ckRecord: record)
        else {return completion(false)}
      // Creating our newContact from the record we got back and appending it to the array
      self.contacts.append(newContact)
      
      // Did this to sort the contacts in alphabetical order
      let sortedContacts = self.contacts.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
      self.contacts = sortedContacts
      return completion(true)
    }
  }
  
  func fetchContacts(completion: @escaping (Bool) -> Void) {
    // Creating our predicate, query, and performing a search with them
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: ContactKeys.recordTypeKey, predicate: predicate)
    privateDB.perform(query, inZoneWith: nil) { (records, error) in
      if let error = error {
        print("Error fetching contacts from iCloud:", error.localizedDescription)
      }
      guard let records = records else {return completion(false)}
      let contacts = records.compactMap {Contact(ckRecord: $0)}
      // Again, creting contacts based off returned records and sorting them
      self.contacts = contacts.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
      return completion(true)
    }
  }
  
  
  func updateContact(contact: Contact, completion: @escaping (Bool) -> Void) {
    let record = CKRecord(contact: contact)
    let operation = CKModifyRecordsOperation(recordsToSave: [record])
    operation.savePolicy = .changedKeys
    operation.qualityOfService = .userInteractive
    operation.modifyRecordsCompletionBlock = { (records,_, error) in
      if let error = error {
        print("Error updating contact in iCloud:", error.localizedDescription)
      }
      guard let record = records?.first,
        let updatedContact = Contact(ckRecord: record),
        let index = self.contacts.firstIndex(of: contact)
        else {return completion(false)}
      // Remove the old contact
      self.contacts.remove(at: index)
      // Add the updated contact
      self.contacts.append(updatedContact)
      // Sorting
      let sortedContacts = self.contacts.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
      self.contacts = sortedContacts
      return completion(true)
    }
    // Almost always forget to do this
    privateDB.add(operation)
  }
  
  func deleteContact(contact: Contact, completion: @escaping (Bool) -> Void) {
    privateDB.delete(withRecordID: contact.recordID) { (recordID, error) in
      if let error = error {
        print("Error deleting contact in iCloud:", error.localizedDescription)
        return completion(false)
      }
      guard recordID != nil,
        let index = self.contacts.firstIndex(of: contact)
        else {return completion(false)}
      // Removing the deleted contact
      self.contacts.remove(at: index)
      
      // Sorting the updated array of contacts
      let sortedContacts = self.contacts.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
      self.contacts = sortedContacts
      return completion(true)
    }
  }
}
