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
  static let shared = ContactController()
  var contacts: [Contact] = []
  let privateDB = CKContainer.default().privateCloudDatabase
  
  func createContact(name: String, phoneNumber: String?, emailAddress: String?, completion: @escaping (Bool) -> Void) {
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
      self.contacts.append(newContact)
      let sortedContacts = self.contacts.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
      self.contacts = sortedContacts
      return completion(true)
    }
  }
  
  func fetchContacts(completion: @escaping (Bool) -> Void) {
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: ContactKeys.recordTypeKey, predicate: predicate)
    privateDB.perform(query, inZoneWith: nil) { (records, error) in
      if let error = error {
        print("Error fetching contacts from iCloud:", error.localizedDescription)
      }
      guard let records = records else {return completion(false)}
      let contacts = records.compactMap {Contact(ckRecord: $0)}
      self.contacts = contacts.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
      return completion(true)
    }
  }
  
  // FINISH THIS
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
      self.contacts.remove(at: index)
      self.contacts.append(updatedContact)
      let sortedContacts = self.contacts.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
      self.contacts = sortedContacts
      return completion(true)
    }
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
      
      self.contacts.remove(at: index)
      let sortedContacts = self.contacts.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
      self.contacts = sortedContacts
      return completion(true)
    }
  }
}
