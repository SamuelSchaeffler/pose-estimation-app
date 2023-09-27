//
//  Trash.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 26.09.23.
//

import Foundation
import CoreData
import UIKit

@objc(Trash)
class Trash: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trash> {
        return NSFetchRequest<Trash>(entityName: "Trash")
    }

    @NSManaged public var zeit: String?
    @NSManaged public var url: String?
    @NSManaged public var rudiment: String?
    @NSManaged public var kamerahersteller: String?
    @NSManaged public var interpret: String?
    @NSManaged public var hand: String?
    @NSManaged public var grip: String?
    @NSManaged public var bpm: String?
    @NSManaged public var aufnahmedatum: String?
    @NSManaged public var aufloesung: String?
    @NSManaged public var grip_matched: String?
    @NSManaged public var dauer: String?
    @NSManaged public var bildwiederholrate: String?

}

extension Trash : Identifiable {

}
