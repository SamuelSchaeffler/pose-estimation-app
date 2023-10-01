//
//  Media.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 24.09.23.
//

import Foundation
import CoreData
import UIKit

@objc(Media)
class Media: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Media> {
        return NSFetchRequest<Media>(entityName: "Media")
    }

    @NSManaged public var zeit: String?
    @NSManaged public var url: String?
    @NSManaged public var rudiment: String?
    @NSManaged public var kamerahersteller: String?
    @NSManaged public var interpret: String?
    @NSManaged public var hand: String?
    @NSManaged public var grip: String?
    @NSManaged public var bpm: Int64
    @NSManaged public var aufnahmedatum: Date?
    @NSManaged public var aufloesung: String?
    @NSManaged public var grip_matched: String?
    @NSManaged public var dauer: String?
    @NSManaged public var bildwiederholrate: String?
    
    @NSManaged public var isPhoto: String?

}

extension Media : Identifiable {

}
