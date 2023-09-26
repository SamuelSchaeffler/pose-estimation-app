//
//  CoreDataManager.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 24.09.23.
//

import Foundation
import CoreData


class CoreDataManager {
    
    let persistentContainer: NSPersistentContainer
    static let shared: CoreDataManager = CoreDataManager()
    
    private init() {
        
        ValueTransformer.setValueTransformer(UIImageTransformer(), forName: NSValueTransformerName("UIImageTransformer"))
        
        persistentContainer = NSPersistentContainer(name: "DataModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("unable to initialize Core Data \(error)")
            }
        }
    }
    
    
}