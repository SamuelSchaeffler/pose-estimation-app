//
//  TrashModel.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 26.09.23.
//

import Foundation
import UIKit
import CoreData

class TrashModel: ObservableObject {
    
    var image: UIImage?
    var video: UIImage?
    var url: String?
    private var context = CoreDataManager.shared.persistentContainer.viewContext
    
    func moveObjectFromMediaToTrash(objectID: NSManagedObjectID) {
        
        let managedObjectContext = context
        
        guard let mediaObject = try? managedObjectContext.existingObject(with: objectID) as? Media else {
            print("Das Objekt konnte nicht gefunden werden oder ist nicht vom Typ 'Media'.")
            return
        }
        guard let trashObject = NSEntityDescription.insertNewObject(forEntityName: "Trash", into: managedObjectContext) as? Trash else {
            print("Fehler beim Erstellen des Zielsobjekts in der 'Trash'-Entity.")
            return
        }

        trashObject.url = mediaObject.url
        trashObject.aufnahmedatum = mediaObject.aufnahmedatum
        trashObject.zeit = mediaObject.zeit
        trashObject.aufloesung = mediaObject.aufloesung
        trashObject.kamerahersteller = mediaObject.kamerahersteller
        trashObject.bpm = mediaObject.bpm
        trashObject.rudiment = mediaObject.rudiment
        trashObject.interpret = mediaObject.interpret
        trashObject.hand = mediaObject.hand
        trashObject.grip = mediaObject.grip
        trashObject.grip_matched = mediaObject.grip_matched
        trashObject.dauer = mediaObject.dauer
        trashObject.bildwiederholrate = mediaObject.bildwiederholrate
        trashObject.isPhoto = mediaObject.isPhoto
        trashObject.videoLandmarks = mediaObject.videoLandmarks

        do {
            try managedObjectContext.save()

            managedObjectContext.delete(mediaObject)

            try managedObjectContext.save()
        } catch {
            print("Fehler beim Speichern des Core Data-Kontexts: \(error.localizedDescription)")
        }
    }
    
    func moveObjectFromTrashToMedia(objectID: NSManagedObjectID) {
        
        let managedObjectContext = context
        
        guard let trashObject = try? managedObjectContext.existingObject(with: objectID) as? Trash else {
            print("Das Objekt konnte nicht gefunden werden oder ist nicht vom Typ 'Trash'.")
            return
        }
        guard let mediaObject = NSEntityDescription.insertNewObject(forEntityName: "Media", into: managedObjectContext) as? Media else {
            print("Fehler beim Erstellen des Zielsobjekts in der 'Media'-Entity.")
            return
        }

        mediaObject.url = trashObject.url
        mediaObject.aufnahmedatum = trashObject.aufnahmedatum
        mediaObject.zeit = trashObject.zeit
        mediaObject.aufloesung = trashObject.aufloesung
        mediaObject.kamerahersteller = trashObject.kamerahersteller
        mediaObject.bpm = trashObject.bpm
        mediaObject.rudiment = trashObject.rudiment
        mediaObject.interpret = trashObject.interpret
        mediaObject.hand = trashObject.hand
        mediaObject.grip = trashObject.grip
        mediaObject.grip_matched = trashObject.grip_matched
        mediaObject.dauer = trashObject.dauer
        mediaObject.bildwiederholrate = trashObject.bildwiederholrate
        mediaObject.isPhoto = trashObject.isPhoto
        mediaObject.videoLandmarks = trashObject.videoLandmarks

        
        do {
            try managedObjectContext.save()

            managedObjectContext.delete(trashObject)

            try managedObjectContext.save()
        } catch {
            print("Fehler beim Speichern des Core Data-Kontexts: \(error.localizedDescription)")
        }
    }
    
    func getTrash() -> [URL] {
        var urlArray: [URL] = []
        do {
            let media = try context.fetch(Trash.fetchRequest())
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
    
    func emptyTrash() {
        let entityName = "Trash"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            if let objects = try context.fetch(fetchRequest) as? [NSManagedObject] {
                for object in objects {
                    context.delete(object)
                }
                try context.save()
            }
        } catch {
            print("Fehler beim Löschen der Objekte: \(error.localizedDescription)")
        }
    }
    
    func getObjectIDs() -> [NSManagedObjectID] {
        
        let entityName = "Trash"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { ($0 as? NSManagedObject)?.objectID }
        } catch {
            print("Fehler beim Abrufen der ObjectIDs: \(error.localizedDescription)")
            return []
        }
    }
}
