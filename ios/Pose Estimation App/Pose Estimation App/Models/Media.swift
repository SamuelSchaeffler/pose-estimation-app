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

    @NSManaged public var duration: Int64
    @NSManaged public var name: String?
    @NSManaged public var photo: UIImage?
    @NSManaged public var resotuion: String?
    @NSManaged public var video: NSObject?
    @NSManaged public var url: String?

}

extension Media : Identifiable {

}
