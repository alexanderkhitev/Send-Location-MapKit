//
//  SendLocation.swift
//  Location
//
//  Created by Alexsander  on 11/2/15.
//  Copyright © 2015 Alexsander Khitev. All rights reserved.
//

import Contacts
import MapKit

class SendLocation: NSObject {
    let fileManager = NSFileManager.defaultManager()
    
    var sendURL: NSURL!
    
    func sendLocation(annotationView: MKAnnotationView, receivedDictionary: [String : AnyObject]) -> NSURL {
        
        let directory = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let contact = CNMutableContact()
        let postalAddress = CNMutablePostalAddress()
        let annotation = annotationView.annotation!

        if receivedDictionary.keys.contains("Ocean") {
            // this sending for Ocean and Sea
            let nameOcean = receivedDictionary["Name"] as! String
            
            let urlAddress = CNLabeledValue(label: "map url", value: "http://maps.apple.com/maps?address=\(nameOcean),\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)")

            contact.contactType = .Person
            contact.urlAddresses = [urlAddress]
            contact.givenName = "Dropped Pin"
    
            do {
                let path = directory.last!.path!.stringByAppendingString("/\(nameOcean).loc.vcf")
                print(path)
                let contactData = try CNContactVCardSerialization.dataWithContacts([contact])
                contactData.writeToFile(path, atomically: true)
                sendURL = NSURL(fileURLWithPath: path)
                
            } catch {
                print("contact data 192 have error")
            }
        } else {
//            print(receivedDictionary)
            let streetName = receivedDictionary["Name"] as? String
            let city = receivedDictionary["City"] as? String
            let state = receivedDictionary["State"] as? String
            let postalCode = receivedDictionary["ZIP"] as? String
            let country =  receivedDictionary["Country"] as? String
            let isoCountryCode = receivedDictionary["CountryCode"] as? String
            
            if streetName != nil {
                postalAddress.street = streetName!
            }
            if city != nil {
                postalAddress.city = city!
            }
            if state != nil {
                postalAddress.state = state!
            }
            if postalCode != nil {
                postalAddress.postalCode = postalCode!
            }
            if country != nil {
                postalAddress.country = country!
            }
            if isoCountryCode != nil {
                postalAddress.ISOCountryCode = isoCountryCode!
            }

            let formattedAddressLine = receivedDictionary["FormattedAddressLines"] as! [String]
            
            let addressSave = CNLabeledValue(label: streetName!, value: postalAddress)
            let urlAddressSave = CNLabeledValue(label: "map url", value: "http://maps.apple.com/maps?address=\(formattedAddressLine.description),\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)")
            
            contact.contactType = .Organization
            contact.organizationName = streetName!
            contact.departmentName = streetName!
            contact.postalAddresses = [addressSave]
            contact.urlAddresses = [urlAddressSave]
            
            let path = directory.last!.path!.stringByAppendingString("/\(streetName!).loc.vcf")

            do {
                let contactData = try CNContactVCardSerialization.dataWithContacts([contact])
                contactData.writeToFile(path, atomically: true)
                sendURL = NSURL(fileURLWithPath: path)

            } catch {
                
            }
            print("This is ground")
        }
        return sendURL 
    }
}
