//
//  MediaModel.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 24.09.23.
//

import Foundation
import UIKit
import CoreData

class MediaModel: ObservableObject {
    
    var image: UIImage?
    var video: UIImage?
    var url: String?
    private var context = CoreDataManager.shared.persistentContainer.viewContext
    
    func saveMedia(url: URL) {
        
        let media = Media(context: self.context)
        
        media.url = url.absoluteString
        
        try! self.context.save()
    }
    
    func getMedia() -> [URL] {
        var urlArray: [URL] = []
        do {
            let media = try context.fetch(Media.fetchRequest())
            for media in media {
                    if let url = media.url {
                        urlArray.append(URL(string: url)!)
                    }
                }
        }
        catch {
        }
        return urlArray
    }
}
