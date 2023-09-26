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

    @NSManaged public var duration: Int64
    @NSManaged public var name: String?
    @NSManaged public var photo: UIImage?
    @NSManaged public var resotuion: String?
    @NSManaged public var video: NSObject?
    @NSManaged public var url: String?

}

extension Trash : Identifiable {

}
