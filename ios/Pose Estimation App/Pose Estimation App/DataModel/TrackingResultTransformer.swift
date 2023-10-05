//
//  TrackingResultTransformer.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 04.10.23.
//

import CoreData
import MediaPipeTasksVision

class TrackingResultTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: "TrackingResultTransformer")

    override static var allowedTopLevelClasses: [AnyClass] {
            return [NSDictionary.self, NSArray.self]
    }
    public override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    public override class func allowsReverseTransformation() -> Bool {
        return true
    }
}
