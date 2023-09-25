//
//  UIImageTransformer.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 24.09.23.
//

import Foundation
import UIKit

class UIImageTransformer: NSSecureUnarchiveFromDataTransformer {
    
    // The name you use here is what you'll set in the Core Data model's Value Transformer Name.
    static let name = NSValueTransformerName(rawValue: "UIImageTransformer")

    override class var allowedTopLevelClasses: [AnyClass] {
        return [UIImage.self]
    }
    
    static func register() {
        let transformer = UIImageTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
