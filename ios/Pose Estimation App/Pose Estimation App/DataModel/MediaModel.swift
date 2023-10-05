//
//  MediaModel.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 24.09.23.
//

import Foundation
import UIKit
import CoreData
import MediaPipeTasksVision

class MediaModel: ObservableObject {
    
    var image: UIImage?
    var video: UIImage?
    var url: String?
    private var context = CoreDataManager.shared.persistentContainer.viewContext
    
    func saveMedia(url: URL, array: [String]) {
        
        let media = Media(context: self.context)
        
        media.url = url.absoluteString
        
        if array[0] != "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let date = dateFormatter.date(from: array[0])
            media.aufnahmedatum = date!
        }
        
        media.zeit = array[1]
        media.aufloesung = array[2]
        media.kamerahersteller = array[3]
        media.bpm = 0
        media.rudiment = ""
        media.interpret = ""
        media.hand = ""
        media.grip = ""
        media.grip_matched = ""
        media.dauer = array[4]
        media.bildwiederholrate = array[5]
        media.isPhoto = array[6]
        
        try! self.context.save()
    }
    
    func getMedia() -> [URL] {
        var urlArray: [URL] = []
        var filter = filterSettings
        var dateFilter = dateFilterSettings
        var bpmFilter = bpmFilterSettings
        
        let fetchRequest = Media.fetchRequest()
        
        var mediaPredicate = NSPredicate(value: true)
        var datePredicate = NSPredicate(value: true)
        var bpmPredicate = NSPredicate(value: true)
        var interpretPredicate = NSPredicate(value: true)
        var gripPredicate = NSPredicate(value: true)
        var gripMatchedPredicate = NSPredicate(value: true)
        var handPredicate = NSPredicate(value: true)
        
        if filter[0] == "2" {
            mediaPredicate = NSPredicate(format: "isPhoto == %@", argumentArray: ["true"])
        } else if filter[0] == "1" {
            mediaPredicate = NSPredicate(format: "isPhoto == %@", argumentArray: ["false"])
        }
        
        if dateFilter[0] == "true" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let startDate = dateFormatter.date(from: dateFilter[1])
            let endDate = dateFormatter.date(from: dateFilter[2])
            datePredicate = NSPredicate(format: "aufnahmedatum >= %@ AND aufnahmedatum <= %@", startDate as! NSDate, endDate as! NSDate)
        }
        
        if bpmFilter[0] == "true" {
                let minBPM = Int64(bpmFilter[1])
                let maxBPM = Int64(bpmFilter[2])
            bpmPredicate = NSPredicate(format: "bpm >= %@ AND bpm <= %@", NSNumber(value: minBPM!), NSNumber(value: maxBPM!))
        }
        
        if filter[4] != "" {
            interpretPredicate = NSPredicate(format: "interpret == %@", argumentArray: [String(filter[4])])
        }
        
        if filter[5] != "" {
            interpretPredicate = NSPredicate(format: "grip == %@", argumentArray: [String(filter[5])])
        }
        
        if filter[6] == "2" {
            gripMatchedPredicate = NSPredicate(format: "grip_matched == %@", argumentArray: ["Nein"])
        } else if filter[6] == "1" {
            gripMatchedPredicate = NSPredicate(format: "grip_matched == %@", argumentArray: ["Ja"])
        }
        
        if filter[7] == "2" {
            handPredicate = NSPredicate(format: "hand == %@", argumentArray: ["Rechts"])
        } else if filter[7] == "1" {
            handPredicate = NSPredicate(format: "hand == %@", argumentArray: ["Links"])
        }

        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [mediaPredicate, datePredicate, bpmPredicate, interpretPredicate, gripPredicate, gripMatchedPredicate, handPredicate])
        fetchRequest.predicate = combinedPredicate
        
        do {
            let media = try context.fetch(fetchRequest)
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
    
    func getObjectIDs() -> [NSManagedObjectID] {
        
        let entityName = "Media"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { ($0 as? NSManagedObject)?.objectID }
        } catch {
            print("Fehler beim Abrufen der ObjectIDs: \(error.localizedDescription)")
            return []
        }
    }
    
    func getPhotoMetadata(objectID: NSManagedObjectID) -> [String] {
        var array: [String] = []
        
        let mediaObject = try? context.existingObject(with: objectID) as? Media
        
        
        if mediaObject?.aufnahmedatum == nil {
            array.append("")
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let dateString = dateFormatter.string(from: (mediaObject?.aufnahmedatum)!)
            array.append(dateString)
        }
        array.append((mediaObject?.zeit)!)
        array.append((mediaObject?.aufloesung)!)
        array.append((mediaObject?.kamerahersteller)!)
        
        if mediaObject?.bpm != 0 {
            array.append(String(mediaObject!.bpm))
        } else {
            array.append("")
        }
        
        array.append((mediaObject?.rudiment)!)
        array.append((mediaObject?.interpret)!)
        array.append((mediaObject?.hand)!)
        array.append((mediaObject?.grip)!)
        array.append((mediaObject?.grip_matched)!)
        
        return array
    }
    
    func getVideoMetadata(objectID: NSManagedObjectID) -> [String] {
        var array: [String] = []
        
        let mediaObject = try? context.existingObject(with: objectID) as? Media
        
        if mediaObject?.aufnahmedatum == nil {
            array.append("")
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let dateString = dateFormatter.string(from: (mediaObject?.aufnahmedatum)!)
            array.append(dateString)
        }
        array.append((mediaObject?.zeit)!)
        array.append((mediaObject?.aufloesung)!)
        array.append((mediaObject?.dauer)!)
        array.append((mediaObject?.bildwiederholrate)!)
        array.append((mediaObject?.kamerahersteller)!)

        if mediaObject?.bpm != 0 {
            array.append(String(mediaObject!.bpm))
        } else {
            array.append("")
        }
        
        array.append((mediaObject?.rudiment)!)
        array.append((mediaObject?.interpret)!)
        array.append((mediaObject?.hand)!)
        array.append((mediaObject?.grip)!)
        array.append((mediaObject?.grip_matched)!)
        
        return array
    }
    
    func savePhotoMetadata(objectID: NSManagedObjectID, array: [String]) {
        
        let mediaObject = try? context.existingObject(with: objectID) as? Media
        
        
        if array[0] != "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let date = dateFormatter.date(from: array[0])
            mediaObject!.aufnahmedatum = date!
        } else {
            mediaObject!.aufnahmedatum = nil
        }
        
        mediaObject!.zeit = array[1]
        mediaObject!.aufloesung = array[2]
        mediaObject!.kamerahersteller = array[3]
        
        if array[4] != "" {
            mediaObject!.bpm = Int64(array[4])!
        }
        
        mediaObject!.rudiment = array[5]
        mediaObject!.interpret = array[6]
        mediaObject!.hand = array[7]
        mediaObject!.grip = array[8]
        mediaObject!.grip_matched = array[9]
        
        try! self.context.save()
    }
    
    func saveVideoMetadata(objectID: NSManagedObjectID, array: [String]) {
        
        let mediaObject = try? context.existingObject(with: objectID) as? Media
        
        if array[0] != "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let date = dateFormatter.date(from: array[0])
            mediaObject!.aufnahmedatum = date!
        } else {
            mediaObject!.aufnahmedatum = nil
        }

        mediaObject!.zeit = array[1]
        mediaObject!.aufloesung = array[2]
        mediaObject!.dauer = array[3]
        mediaObject!.bildwiederholrate = array[4]
        mediaObject!.kamerahersteller = array[5]
        
        if array[6] != "" {
            mediaObject!.bpm = Int64(array[6])!
        }
                                           
        mediaObject!.rudiment = array[7]
        mediaObject!.interpret = array[8]
        mediaObject!.hand = array[9]
        mediaObject!.grip = array[10]
        mediaObject!.grip_matched = array[11]
        
        try! self.context.save()
    }
    
    

    
}
