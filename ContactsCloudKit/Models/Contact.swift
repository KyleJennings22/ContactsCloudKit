//
//  Contact.swift
//  ContactsCloudKit
//
//  Created by Kyle Jennings on 12/13/19.
//  Copyright © 2019 Kyle Jennings. All rights reserved.
//

import Foundation
import CloudKit

class Contact {
  var name: String
  var phoneNumber: String?
  var emailAddress: String?
  
  let recordID: CKRecord.ID
  
  init(name: String, phoneNumber: String?, emailAddress: String?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
    self.name = name
    self.phoneNumber = phoneNumber
    self.emailAddress = emailAddress
    self.recordID = recordID
  }
}

extension Contact {
  convenience init?(ckRecord: CKRecord) {
    guard let name = ckRecord[ContactKeys.nameKey] as? String
      else {return nil}
    let phoneNumber = ckRecord[ContactKeys.phoneNumberKey] as? String
    let emailAddress = ckRecord[ContactKeys.emailAddressKey] as? String
    
    self.init(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress, recordID: ckRecord.recordID)
  }
}

extension Contact: Equatable {
  static func == (lhs: Contact, rhs: Contact) -> Bool {
    return lhs.recordID == rhs.recordID
  }
}

extension CKRecord {
  convenience init(contact: Contact) {
    self.init(recordType: ContactKeys.recordTypeKey, recordID: contact.recordID)
    setValue(contact.name, forKey: ContactKeys.nameKey)
    setValue(contact.phoneNumber, forKey: ContactKeys.phoneNumberKey)
    setValue(contact.emailAddress, forKey: ContactKeys.emailAddressKey)
  }
}

struct ContactKeys {
  static let recordTypeKey = "Contact"
  fileprivate static let nameKey = "name"
  fileprivate static let phoneNumberKey = "phoneNumber"
  fileprivate static let emailAddressKey = "emailAddress"
}
