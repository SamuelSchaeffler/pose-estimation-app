//class MediaModel: ObservableObject {
//    
//    private var context = CoreDataManager.shared.persistentContainer.viewContext
//    
//    func saveMedia(url: URL, array: [String]) {
//        let media = Media(context: self.context)
//        media.url = url.absoluteString
//        if array[0] != "" {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd.MM.yyyy"
//            let date = dateFormatter.date(from: array[0])
//            media.aufnahmedatum = date!
//        }
//        media.zeit = array[1]
//        media.aufloesung = array[2]
//        media.kamerahersteller = array[3]
//        media.bpm = 0
//        media.rudiment = ""
//        media.interpret = ""
//        media.hand = ""
//        media.grip = ""
//        media.grip_matched = ""
//        media.dauer = array[4]
//        media.bildwiederholrate = array[5]
//        media.isPhoto = array[6]
//        try! self.context.save()
//    }
//    
//    func getMedia() -> [URL] {
//        var urlArray: [URL] = []
//        let filter = filterSettings
//        let dateFilter = dateFilterSettings
//        let bpmFilter = bpmFilterSettings
//        let fetchRequest = Media.fetchRequest()
//        var mediaPredicate = NSPredicate(value: true)
//        var datePredicate = NSPredicate(value: true)
//        var bpmPredicate = NSPredicate(value: true)
//        var interpretPredicate = NSPredicate(value: true)
//        let gripPredicate = NSPredicate(value: true)
//        var gripMatchedPredicate = NSPredicate(value: true)
//        var handPredicate = NSPredicate(value: true)
//        if filter[0] == "2" {
//            mediaPredicate = NSPredicate(format: "isPhoto == %@", argumentArray: ["true"])
//        } else if filter[0] == "1" {
//            mediaPredicate = NSPredicate(format: "isPhoto == %@", argumentArray: ["false"])
//        }
//        if dateFilter[0] == "true" {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd.MM.yyyy"
//            let startDate = dateFormatter.date(from: dateFilter[1])
//            let endDate = dateFormatter.date(from: dateFilter[2])
//            datePredicate = NSPredicate(format: "aufnahmedatum >= %@ AND aufnahmedatum <= %@", startDate as! NSDate, endDate as! NSDate)
//        }
//        if bpmFilter[0] == "true" {
//                let minBPM = Int64(bpmFilter[1])
//                let maxBPM = Int64(bpmFilter[2])
//            bpmPredicate = NSPredicate(format: "bpm >= %@ AND bpm <= %@", NSNumber(value: minBPM!), NSNumber(value: maxBPM!))
//        }
//        if filter[4] != "" {
//            interpretPredicate = NSPredicate(format: "interpret == %@", argumentArray: [String(filter[4])])
//        }
//        if filter[5] != "" {
//            interpretPredicate = NSPredicate(format: "grip == %@", argumentArray: [String(filter[5])])
//        }
//        if filter[6] == "2" {
//            gripMatchedPredicate = NSPredicate(format: "grip_matched == %@", argumentArray: ["Nein"])
//        } else if filter[6] == "1" {
//            gripMatchedPredicate = NSPredicate(format: "grip_matched == %@", argumentArray: ["Ja"])
//        }
//        if filter[7] == "2" {
//            handPredicate = NSPredicate(format: "hand == %@", argumentArray: ["Rechts"])
//        } else if filter[7] == "1" {
//            handPredicate = NSPredicate(format: "hand == %@", argumentArray: ["Links"])
//        }
//        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [mediaPredicate, datePredicate, bpmPredicate, interpretPredicate, gripPredicate, gripMatchedPredicate, handPredicate])
//        fetchRequest.predicate = combinedPredicate
//        do {
//            let media = try context.fetch(fetchRequest)
//            for media in media {
//                    if let url = media.url {
//                        urlArray.append(URL(string: url)!)
//                    }
//                }
//        }
//        catch {
//        }
//        return urlArray
//    }
//    
//    func getObjectIDs() -> [NSManagedObjectID] {
//        let filter = filterSettings
//        let dateFilter = dateFilterSettings
//        let bpmFilter = bpmFilterSettings
//        let entityName = "Media"
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
//        var mediaPredicate = NSPredicate(value: true)
//        var datePredicate = NSPredicate(value: true)
//        var bpmPredicate = NSPredicate(value: true)
//        var interpretPredicate = NSPredicate(value: true)
//        let gripPredicate = NSPredicate(value: true)
//        var gripMatchedPredicate = NSPredicate(value: true)
//        var handPredicate = NSPredicate(value: true)
//        if filter[0] == "2" {
//            mediaPredicate = NSPredicate(format: "isPhoto == %@", argumentArray: ["true"])
//        } else if filter[0] == "1" {
//            mediaPredicate = NSPredicate(format: "isPhoto == %@", argumentArray: ["false"])
//        }
//        if dateFilter[0] == "true" {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd.MM.yyyy"
//            let startDate = dateFormatter.date(from: dateFilter[1])
//            let endDate = dateFormatter.date(from: dateFilter[2])
//            datePredicate = NSPredicate(format: "aufnahmedatum >= %@ AND aufnahmedatum <= %@", startDate as! NSDate, endDate as! NSDate)
//        }
//        if bpmFilter[0] == "true" {
//                let minBPM = Int64(bpmFilter[1])
//                let maxBPM = Int64(bpmFilter[2])
//            bpmPredicate = NSPredicate(format: "bpm >= %@ AND bpm <= %@", NSNumber(value: minBPM!), NSNumber(value: maxBPM!))
//        }
//        if filter[4] != "" {
//            interpretPredicate = NSPredicate(format: "interpret == %@", argumentArray: [String(filter[4])])
//        }
//        if filter[5] != "" {
//            interpretPredicate = NSPredicate(format: "grip == %@", argumentArray: [String(filter[5])])
//        }
//        if filter[6] == "2" {
//            gripMatchedPredicate = NSPredicate(format: "grip_matched == %@", argumentArray: ["Nein"])
//        } else if filter[6] == "1" {
//            gripMatchedPredicate = NSPredicate(format: "grip_matched == %@", argumentArray: ["Ja"])
//        }
//        if filter[7] == "2" {
//            handPredicate = NSPredicate(format: "hand == %@", argumentArray: ["Rechts"])
//        } else if filter[7] == "1" {
//            handPredicate = NSPredicate(format: "hand == %@", argumentArray: ["Links"])
//        }
//        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [mediaPredicate, datePredicate, bpmPredicate, interpretPredicate, gripPredicate, gripMatchedPredicate, handPredicate])
//        fetchRequest.predicate = combinedPredicate
//        do {
//            let results = try context.fetch(fetchRequest)
//            return results.compactMap { ($0 as? NSManagedObject)?.objectID }
//        } catch {
//            print("Fehler beim Abrufen der ObjectIDs: \(error.localizedDescription)")
//            return []
//        }
//    }
//    
//    func getPhotoMetadata(objectID: NSManagedObjectID) -> [String] {
//        var array: [String] = []
//        let mediaObject = try? context.existingObject(with: objectID) as? Media
//        if mediaObject?.aufnahmedatum == nil {
//            array.append("")
//        } else {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd.MM.yyyy"
//            let dateString = dateFormatter.string(from: (mediaObject?.aufnahmedatum)!)
//            array.append(dateString)
//        }
//        array.append((mediaObject?.zeit)!)
//        array.append((mediaObject?.aufloesung)!)
//        array.append((mediaObject?.kamerahersteller)!)
//        if mediaObject?.bpm != 0 {
//            array.append(String(mediaObject!.bpm))
//        } else {
//            array.append("")
//        }
//        array.append((mediaObject?.rudiment)!)
//        array.append((mediaObject?.interpret)!)
//        array.append((mediaObject?.hand)!)
//        array.append((mediaObject?.grip)!)
//        array.append((mediaObject?.grip_matched)!)
//        return array
//    }
//    
//    func getVideoMetadata(objectID: NSManagedObjectID) -> [String] {
//        var array: [String] = []
//        let mediaObject = try? context.existingObject(with: objectID) as? Media
//        if mediaObject?.aufnahmedatum == nil {
//            array.append("")
//        } else {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd.MM.yyyy"
//            let dateString = dateFormatter.string(from: (mediaObject?.aufnahmedatum)!)
//            array.append(dateString)
//        }
//        array.append((mediaObject?.zeit)!)
//        array.append((mediaObject?.aufloesung)!)
//        array.append((mediaObject?.dauer)!)
//        array.append((mediaObject?.bildwiederholrate)!)
//        array.append((mediaObject?.kamerahersteller)!)
//        if mediaObject?.bpm != 0 {
//            array.append(String(mediaObject!.bpm))
//        } else {
//            array.append("")
//        }
//        array.append((mediaObject?.rudiment)!)
//        array.append((mediaObject?.interpret)!)
//        array.append((mediaObject?.hand)!)
//        array.append((mediaObject?.grip)!)
//        array.append((mediaObject?.grip_matched)!)
//        return array
//    }
//    
//    func savePhotoMetadata(objectID: NSManagedObjectID, array: [String]) {
//        let mediaObject = try? context.existingObject(with: objectID) as? Media
//        if array[0] != "" {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd.MM.yyyy"
//            let date = dateFormatter.date(from: array[0])
//            mediaObject!.aufnahmedatum = date!
//        } else {
//            mediaObject!.aufnahmedatum = nil
//        }
//        mediaObject!.zeit = array[1]
//        mediaObject!.aufloesung = array[2]
//        mediaObject!.kamerahersteller = array[3]
//        if array[4] != "" {
//            mediaObject!.bpm = Int64(array[4])!
//        }
//        mediaObject!.rudiment = array[5]
//        mediaObject!.interpret = array[6]
//        mediaObject!.hand = array[7]
//        mediaObject!.grip = array[8]
//        mediaObject!.grip_matched = array[9]
//        try! self.context.save()
//    }
//    
//    func saveVideoMetadata(objectID: NSManagedObjectID, array: [String]) {
//        let mediaObject = try? context.existingObject(with: objectID) as? Media
//        if array[0] != "" {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd.MM.yyyy"
//            let date = dateFormatter.date(from: array[0])
//            mediaObject!.aufnahmedatum = date!
//        } else {
//            mediaObject!.aufnahmedatum = nil
//        }
//        mediaObject!.zeit = array[1]
//        mediaObject!.aufloesung = array[2]
//        mediaObject!.dauer = array[3]
//        mediaObject!.bildwiederholrate = array[4]
//        mediaObject!.kamerahersteller = array[5]
//        if array[6] != "" {
//            mediaObject!.bpm = Int64(array[6])!
//        }
//        mediaObject!.rudiment = array[7]
//        mediaObject!.interpret = array[8]
//        mediaObject!.hand = array[9]
//        mediaObject!.grip = array[10]
//        mediaObject!.grip_matched = array[11]
//        try! self.context.save()
//    }
//    
//    func getVideoURL(objectID: NSManagedObjectID) -> [String] {
//        var array: [String] = []
//        let mediaObject = try? context.existingObject(with: objectID) as? Media
//        array.append((mediaObject?.url)!)
//        return array
//    }
//    
//    func checkVideoLandmarks(objectID: NSManagedObjectID) -> Bool {
//        let mediaObject = try? context.existingObject(with: objectID) as? Media
//        if mediaObject?.videoLandmarks == nil {
//            return false
//        } else {
//            return true
//        }
//    }
//    
//    func saveVideoLandmarks(objectID: NSManagedObjectID, data: String) {
//        let mediaObject = try? context.existingObject(with: objectID) as? Media
//        mediaObject!.videoLandmarks = data
//        try! self.context.save()
//    }
//    
//    func getVideoLandmarks(objectID: NSManagedObjectID) -> String {
//        let mediaObject = try? context.existingObject(with: objectID) as? Media
//        return (mediaObject?.videoLandmarks)!
//    }
//    
//    func checkMediaType(objectID: NSManagedObjectID) -> String {
//        let mediaObject = try? context.existingObject(with: objectID) as? Media
//        let isPhoto = mediaObject!.isPhoto
//        return isPhoto!
//    }
//}
//
//class TrashModel: ObservableObject {
//    
//    private var context = CoreDataManager.shared.persistentContainer.viewContext
//    
//    func moveObjectFromMediaToTrash(objectID: NSManagedObjectID) {
//        let managedObjectContext = context
//        guard let mediaObject = try? managedObjectContext.existingObject(with: objectID) as? Media else {
//            print("Das Objekt konnte nicht gefunden werden oder ist nicht vom Typ 'Media'.")
//            return
//        }
//        guard let trashObject = NSEntityDescription.insertNewObject(forEntityName: "Trash", into: managedObjectContext) as? Trash else {
//            print("Fehler beim Erstellen des Zielsobjekts in der 'Trash'-Entity.")
//            return
//        }
//        trashObject.url = mediaObject.url
//        trashObject.aufnahmedatum = mediaObject.aufnahmedatum
//        trashObject.zeit = mediaObject.zeit
//        trashObject.aufloesung = mediaObject.aufloesung
//        trashObject.kamerahersteller = mediaObject.kamerahersteller
//        trashObject.bpm = mediaObject.bpm
//        trashObject.rudiment = mediaObject.rudiment
//        trashObject.interpret = mediaObject.interpret
//        trashObject.hand = mediaObject.hand
//        trashObject.grip = mediaObject.grip
//        trashObject.grip_matched = mediaObject.grip_matched
//        trashObject.dauer = mediaObject.dauer
//        trashObject.bildwiederholrate = mediaObject.bildwiederholrate
//        trashObject.isPhoto = mediaObject.isPhoto
//        trashObject.videoLandmarks = mediaObject.videoLandmarks
//        do {
//            try managedObjectContext.save()
//            managedObjectContext.delete(mediaObject)
//            try managedObjectContext.save()
//        } catch {
//            print("Fehler beim Speichern des Core Data-Kontexts: \(error.localizedDescription)")
//        }
//    }
//    
//    func moveObjectFromTrashToMedia(objectID: NSManagedObjectID) {
//        let managedObjectContext = context
//        guard let trashObject = try? managedObjectContext.existingObject(with: objectID) as? Trash else {
//            print("Das Objekt konnte nicht gefunden werden oder ist nicht vom Typ 'Trash'.")
//            return
//        }
//        guard let mediaObject = NSEntityDescription.insertNewObject(forEntityName: "Media", into: managedObjectContext) as? Media else {
//            print("Fehler beim Erstellen des Zielsobjekts in der 'Media'-Entity.")
//            return
//        }
//        mediaObject.url = trashObject.url
//        mediaObject.aufnahmedatum = trashObject.aufnahmedatum
//        mediaObject.zeit = trashObject.zeit
//        mediaObject.aufloesung = trashObject.aufloesung
//        mediaObject.kamerahersteller = trashObject.kamerahersteller
//        mediaObject.bpm = trashObject.bpm
//        mediaObject.rudiment = trashObject.rudiment
//        mediaObject.interpret = trashObject.interpret
//        mediaObject.hand = trashObject.hand
//        mediaObject.grip = trashObject.grip
//        mediaObject.grip_matched = trashObject.grip_matched
//        mediaObject.dauer = trashObject.dauer
//        mediaObject.bildwiederholrate = trashObject.bildwiederholrate
//        mediaObject.isPhoto = trashObject.isPhoto
//        mediaObject.videoLandmarks = trashObject.videoLandmarks
//        do {
//            try managedObjectContext.save()
//            managedObjectContext.delete(trashObject)
//            try managedObjectContext.save()
//        } catch {
//            print("Fehler beim Speichern des Core Data-Kontexts: \(error.localizedDescription)")
//        }
//    }
//    
//    func getTrash() -> [URL] {
//        var urlArray: [URL] = []
//        do {
//            let media = try context.fetch(Trash.fetchRequest())
//            for media in media {
//                    if let url = media.url {
//                        urlArray.append(URL(string: url)!)
//                    }
//                }
//        }
//        catch {
//        }
//        return urlArray
//    }
//    
//    func emptyTrash() {
//        let entityName = "Trash"
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
//        do {
//            if let objects = try context.fetch(fetchRequest) as? [NSManagedObject] {
//                for object in objects {
//                    context.delete(object)
//                }
//                try context.save()
//            }
//        } catch {
//            print("Fehler beim Löschen der Objekte: \(error.localizedDescription)")
//        }
//    }
//    
//    func getObjectIDs() -> [NSManagedObjectID] {
//        let entityName = "Trash"
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
//        do {
//            let results = try context.fetch(fetchRequest)
//            return results.compactMap { ($0 as? NSManagedObject)?.objectID }
//        } catch {
//            print("Fehler beim Abrufen der ObjectIDs: \(error.localizedDescription)")
//            return []
//        }
//    }
//}
//class MediaPipeHandLandmarker {
//    
//    private var handLandmarker: HandLandmarker?
//    private var options: HandLandmarkerOptions
//    var uiImage: UIImage?
//    var result: HandLandmarkerResult?
//    
//    init() {
//        options = HandLandmarkerOptions()
//        options.runningMode = .image
//        options.numHands = 2
//        options.minHandDetectionConfidence = 0.5
//        options.minHandPresenceConfidence = 0.5
//        options.minTrackingConfidence = 0.5
//        if let modelPath = Bundle.main.path(forResource: "hand_landmarker", ofType: "task") {
//            options.baseOptions.modelAssetPath = modelPath
//        }
//        do {
//            handLandmarker = try HandLandmarker(options: options)
//        } catch {
//            print(error)
//        }
//    }
//    
//    func detectHands(image: UIImage) -> HandLandmarkerResult? {
//        uiImage = image
//        let mpImage = try! MPImage(uiImage: image)
//        do {
//            result = try handLandmarker?.detect(image: mpImage)
//            print()
//            return result
//        } catch {
//            print(error)
//            return nil
//        }
//    }
//    
//    func drawBoundingBoxes() -> UIImage? {
//        var index = -1
//        let image = uiImage!
//        let imageSize = image.size
//        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
//        for hand in result!.landmarks {
//            index = index + 1
//            let coordinates = hand
//            let rectColor: UIColor
//            if  result!.handedness[index][0].categoryName! == "Right" {
//                rectColor = UIColor.systemRed
//            } else {
//                rectColor = UIColor.systemBlue
//            }
//            var minX = CGFloat.greatestFiniteMagnitude
//            var maxX = -CGFloat.greatestFiniteMagnitude
//            var minY = CGFloat.greatestFiniteMagnitude
//            var maxY = -CGFloat.greatestFiniteMagnitude
//            if imageSize.height > imageSize.width {
//                for coordinate in coordinates {
//                    minX = min(minX, CGFloat(coordinate.y))
//                    maxX = max(maxX, CGFloat(coordinate.y))
//                    minY = min(minY, CGFloat(coordinate.x))
//                    maxY = max(maxY, CGFloat(coordinate.x))
//                }
//                minX = imageSize.width - (minX * imageSize.width)
//                maxX = imageSize.width - (maxX * imageSize.width)
//                minY = minY * imageSize.height
//                maxY = maxY * imageSize.height
//            } else {
//                for coordinate in coordinates {
//                    minX = min(minX, CGFloat(coordinate.x))
//                    maxX = max(maxX, CGFloat(coordinate.x))
//                    minY = min(minY, CGFloat(coordinate.y))
//                    maxY = max(maxY, CGFloat(coordinate.y))
//                }
//                minX = minX * imageSize.width
//                maxX = maxX * imageSize.width
//                minY = minY * imageSize.height
//                maxY = maxY * imageSize.height
//            }
//            let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
//            let path = UIBezierPath(rect: rect)
//            rectColor.setStroke()
//            path.lineWidth = imageSize.width / 95
//            path.stroke()
//        }
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return newImage
//    }
//    
//    func drawLandmarks() -> UIImage? {
//        var index = -1
//        let image = uiImage!
//        let imageSize = image.size
//        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
//        for hand in result!.landmarks {
//            index = index + 1
//            let coordinates = hand
//            let lineColor = UIColor.gray
//            let path = UIBezierPath()
//            path.lineWidth = imageSize.width / 90
//            lineColor.setStroke()
//            var points: [CGPoint] = []
//            if imageSize.height > imageSize.width {
//                for i in 0..<21 {
//                    points.append(CGPoint(x: imageSize.width - (Double((coordinates[i].y)) * imageSize.width), y: Double(coordinates[i].x) * imageSize.height))
//                }
//            } else {
//                for i in 0..<21 {
//                    points.append(CGPoint(x: Double((coordinates[i].x)) * imageSize.width, y: Double(coordinates[i].y) * imageSize.height))
//                }
//            }
//            path.move(to: points[0])
//            path.addLine(to: points[1])
//            path.addLine(to: points[2])
//            path.addLine(to: points[3])
//            path.addLine(to: points[4])
//            path.move(to: points[0])
//            path.addLine(to: points[5])
//            path.addLine(to: points[6])
//            path.addLine(to: points[7])
//            path.addLine(to: points[8])
//            path.move(to: points[0])
//            path.addLine(to: points[9])
//            path.addLine(to: points[10])
//            path.addLine(to: points[11])
//            path.addLine(to: points[12])
//            path.move(to: points[0])
//            path.addLine(to: points[13])
//            path.addLine(to: points[14])
//            path.addLine(to: points[15])
//            path.addLine(to: points[16])
//            path.move(to: points[0])
//            path.addLine(to: points[17])
//            path.addLine(to: points[18])
//            path.addLine(to: points[19])
//            path.addLine(to: points[20])
//            path.stroke()
//            let pointColor: UIColor
//            if  result!.handedness[index][0].categoryName! == "Right" {
//                pointColor = UIColor.systemRed
//            } else {
//                pointColor = UIColor.systemBlue
//            }
//            let pointRadius: CGFloat = imageSize.width / 50
//            if imageSize.height > imageSize.width {
//                for point in coordinates {
//                    let x = imageSize.width - (CGFloat(point.y) * imageSize.width)
//                    let y = CGFloat(point.x) * imageSize.height
//                    let pointRect = CGRect(x: x - pointRadius / 2.0, y: y - pointRadius / 2.0, width: pointRadius, height: pointRadius)
//                    let path = UIBezierPath(ovalIn: pointRect)
//                    pointColor.setFill()
//                    path.fill()
//                }
//            } else {
//                for point in coordinates {
//                    let x = CGFloat(point.x) * imageSize.width
//                    let y = CGFloat(point.y) * imageSize.height
//                    let pointRect = CGRect(x: x - pointRadius / 2.0, y: y - pointRadius / 2.0, width: pointRadius, height: pointRadius)
//                    let path = UIBezierPath(ovalIn: pointRect)
//                    pointColor.setFill()
//                    path.fill()
//                }
//            }
//        }
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return newImage
//    }
//    
//    func getWorldLandmarks(result: HandLandmarkerResult, image: UIImage) -> [SCNVector3] {
//        let imageSize = image.size
//        let coordinates = result.worldLandmarks[0]
//        var points: [SCNVector3] = []
//        let factor: CGFloat = 7000
//        if imageSize.height > imageSize.width {
//            for i in 0..<21 {
//                let xPoint = factor - CGFloat(coordinates[i].y) * factor
//                let yPoint = CGFloat(coordinates[i].x) * factor
//                let zPoint = CGFloat(coordinates[i].z) * factor
//                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
//            }
//        } else {
//            for i in 0..<21 {
//                let xPoint = CGFloat(coordinates[i].x) * factor
//                let yPoint = CGFloat(coordinates[i].y) * factor
//                let zPoint = CGFloat(coordinates[i].z) * factor
//                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
//            }
//        }
//        return points
//    }
//}
//
//class MediaPipeHandLandmarkerVideo {
//    
//    var mediaModel = MediaModel()
//    private var handLandmarker: HandLandmarker?
//    private var options: HandLandmarkerOptions
//    var videoURL: URL?
//    var result: HandLandmarkerResult?
//    var tempTimestamp: Int = 0
//    var videoLandmarks: [[SCNVector3]] = []
//    var videoWorldLandmarks: [[SCNVector3]] = []
//    var videoTimestamps: [Int] = []
//    var videoAngle: CGFloat = 0
//    let vectorFunctions = VectorFunctions()
//    
//    init() {
//        options = HandLandmarkerOptions()
//        options.runningMode = .video
//        options.numHands = 2
//        options.minHandDetectionConfidence = 0.4
//        options.minHandPresenceConfidence = 0.4
//        options.minTrackingConfidence = 0.9
//        if let modelPath = Bundle.main.path(forResource: "hand_landmarker", ofType: "task") {
//            options.baseOptions.modelAssetPath = modelPath
//        }
//        do {
//            handLandmarker = try HandLandmarker(options: options)
//        } catch {
//            print(error)
//        }
//    }
//    
//    func generateLandmarks(objectID: NSManagedObjectID) {
//        let videoURL = URL(string: mediaModel.getVideoURL(objectID: objectID)[0])
//        autoreleasepool {
//            let asset = AVAsset(url: videoURL!)
//            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
//                print("Fehler beim Abrufen des Video-Tracks")
//                return
//            }
//            let naturalSize = videoTrack.naturalSize
//            let transform = videoTrack.preferredTransform
//            videoAngle = atan2(transform.b, transform.a) * (180 / .pi)
//            let duration = CMTimeGetSeconds(asset.duration) * 1000
//            guard let reader = try? AVAssetReader(asset: asset) else {
//                print("Fehler beim Erstellen des AVAssetReaders")
//                return
//            }
//            let readerOutputSettings: [String: Any] = [
//                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
//            ]
//            let readerOutput = AVAssetReaderTrackOutput(track: asset.tracks(withMediaType: .video)[0], outputSettings: readerOutputSettings)
//            reader.add(readerOutput)
//            reader.startReading()
//            let videoSettings: [String: Any] = [
//                AVVideoCodecKey: AVVideoCodecType.h264.rawValue,
//                AVVideoWidthKey: naturalSize.width,
//                AVVideoHeightKey: naturalSize.height
//            ]
//            let context = CIContext()
//            while reader.status == .reading {
//                if let sampleBuffer = readerOutput.copyNextSampleBuffer() {
//                    autoreleasepool {
//                        var timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
//                        let orginalImage = self.convertSampleBufferToUIImage(sampleBuffer, context: context)
//                        let progress = Float((CMTimeGetSeconds(timestamp) * 1000) / duration)
//                        NotificationCenter.default.post(name: Notification.Name("updateProgress"), object: progress)
//                        processFrameWithMediaPipe(orginalImage: orginalImage!, image: orginalImage!, timestamp: timestamp)
//                    }
//                } else {
//                    reader.cancelReading()
//                    NotificationCenter.default.post(name: Notification.Name("updateProgress"), object: 0)
//                    let videoLandmarksString = vectorFunctions.videoLandmarksToString(landmarks: videoLandmarks, worldLandmarks: videoWorldLandmarks, timestamps: videoTimestamps)
//                    mediaModel.saveVideoLandmarks(objectID: objectID, data: videoLandmarksString!)
//                    videoLandmarks = []
//                    videoWorldLandmarks = []
//                    videoTimestamps = []
//                    break
//                }
//            }
//        }
//    }
//    
//    func convertSampleBufferToUIImage(_ sampleBuffer: CMSampleBuffer, context: CIContext) -> UIImage? {
//        autoreleasepool {
//            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//            let ciImage = CIImage(cvPixelBuffer: pixelBuffer!)
//            let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
//            let uiImage = (UIImage(cgImage: cgImage!))
//            return uiImage
//        }
//    }
//    
//    func processFrameWithMediaPipe(orginalImage: UIImage, image: UIImage, timestamp: CMTime) {
//        let mpImage = try! MPImage(uiImage: image)
//        var timestampInMilliseconds = Int(CMTimeGetSeconds(timestamp) * 1000)
//        if timestampInMilliseconds == tempTimestamp {
//            timestampInMilliseconds += 1
//        }
//        tempTimestamp = timestampInMilliseconds
//        let result = try! self.handLandmarker?.detect(videoFrame: mpImage, timestampInMilliseconds: timestampInMilliseconds)
//        if result!.worldLandmarks.count > 0 {
//            let landmarks = getLandmarks(result: result!, image: image)
//            let worldLandmarks = getWorldLandmarks(result: result!, image: image)
//            videoLandmarks.append(landmarks)
//            videoWorldLandmarks.append(worldLandmarks)
//            videoTimestamps.append(timestampInMilliseconds)
//        }
//    }
//    
//    func getWorldLandmarks(result: HandLandmarkerResult, image: UIImage) -> [SCNVector3] {
//        let imageSize = image.size
//        let coordinates = result.worldLandmarks[0]
//        var points: [SCNVector3] = []
//        let factor = CGFloat(1000)
//        if videoAngle == 90 {
//            for i in 0..<21 {
//                let xPoint = CGFloat(coordinates[i].y) * factor * (-1)
//                let yPoint = CGFloat(coordinates[i].x) * factor
//                let zPoint = CGFloat(coordinates[i].z) * factor
//                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
//            }
//        } else if videoAngle == 180 {
//            for i in 0..<21 {
//                let xPoint = CGFloat(coordinates[i].x) * factor * (-1)
//                let yPoint = CGFloat(coordinates[i].y) * factor * (-1)
//                let zPoint = CGFloat(coordinates[i].z) * factor
//                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
//            }
//        } else {
//            for i in 0..<21 {
//                let xPoint = CGFloat(coordinates[i].x) * factor
//                let yPoint = CGFloat(coordinates[i].y) * factor
//                let zPoint = CGFloat(coordinates[i].z) * factor
//                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
//            }
//        }
//        return points
//    }
//    
//    func getLandmarks(result: HandLandmarkerResult, image: UIImage) -> [SCNVector3] {
//        var imageSize = image.size
//        let targetSize = CGSize(width: 1920, height: 1080)
//        let widthRatio  = targetSize.width  / imageSize.width
//        let heightRatio = targetSize.height / imageSize.height
//        var newSize: CGSize
//        if(widthRatio > heightRatio) {
//            newSize = CGSize(width: imageSize.width * heightRatio, height: imageSize.height * heightRatio)
//        } else {
//            newSize = CGSize(width: imageSize.width * widthRatio,  height: imageSize.height * widthRatio)
//        }
//        imageSize = newSize
//        let coordinates = result.landmarks[0]
//        var points: [SCNVector3] = []
//        if imageSize.height < imageSize.width {
//            for i in 0..<21 {
//                let xPoint = imageSize.height - CGFloat(coordinates[i].y) * imageSize.height
//                let yPoint = CGFloat(coordinates[i].x) * imageSize.width
//                let zPoint = CGFloat(coordinates[i].z) * imageSize.width
//                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
//            }
//        } else {
//            for i in 0..<21 {
//                let xPoint = CGFloat(coordinates[i].x) * imageSize.width
//                let yPoint = CGFloat(coordinates[i].y) * imageSize.height
//                let zPoint = CGFloat(coordinates[i].z) * imageSize.width
//                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
//            }
//        }
//        return points
//    }
//}
//
//class Filter {
//    
//    static let shared = Filter()
//    
//    var landmarkFilterStates = [false, false, false, false]
//    var windowSizeMA: Int = 0
//    var omegaCPT1: Float = 0
//    var sampleTimePT1: Float = (1 / 10)
//    var useFPSSampleTimePT1 = false
//    var qKalman: Float = 0
//    var rKalman: Float = 0
//    var initialPKalman: Float = 0
//    var landmarkShiftAmount: Int = 0
//
//    func movingAverage(landmarks: [[SCNVector3]]) -> [[SCNVector3]] {
//        let windowSize = windowSizeMA
//        let vectorFunctions = VectorFunctions()
//        print("Fenstergröße: \(windowSize)")
//        var smoothedLandmarks = [[SCNVector3]]()
//        for i in 0..<landmarks.count {
//            var smoothedFrame = [SCNVector3]()
//            for j in 0..<landmarks[i].count {
//                var sum = SCNVector3(0, 0, 0)
//                var count = 0
//                for k in max(0, i - windowSize / 2)...min(landmarks.count - 1, i + windowSize / 2) {
//                    sum = vectorFunctions.addVector(sum, landmarks[k][j])
//                    count += 1
//                }
//                smoothedFrame.append(SCNVector3(sum.x / Float(count), sum.y / Float(count), sum.z / Float(count)))
//            }
//            smoothedLandmarks.append(smoothedFrame)
//        }
//        return smoothedLandmarks
//    }
//
//    func applyPT1Filter(landmarks: [[SCNVector3]]) -> [[SCNVector3]] {
//        let omegaC = omegaCPT1
//        let sampleTime = sampleTimePT1
//        print("Gremzfrequenz: \(omegaC)")
//        print("Abtastzeit: \(sampleTime)")
//        var filteredLandmarks = landmarks
//        let alpha = (2 - sampleTime * omegaC) / (2 + sampleTime * omegaC)
//        let beta = sampleTime * omegaC / (2 + sampleTime * omegaC)
//        for timeIndex in 1..<landmarks.count {
//            for pointIndex in 0..<landmarks[timeIndex].count {
//                let previous = filteredLandmarks[timeIndex - 1][pointIndex]
//                let current = landmarks[timeIndex][pointIndex]
//                let filteredX = alpha * previous.x + beta * (current.x + previous.x)
//                let filteredY = alpha * previous.y + beta * (current.y + previous.y)
//                let filteredZ = alpha * previous.z + beta * (current.z + previous.z)
//                filteredLandmarks[timeIndex][pointIndex] = SCNVector3(x: filteredX, y: filteredY, z: filteredZ)
//            }
//        }
//        return filteredLandmarks
//    }
//
//    struct KalmanFilter {
//        var q: Float // Prozessrauschen
//        var r: Float // Messrauschen
//        var x: Float // Geschätzter Wert
//        var p: Float // Schätzfehler
//        var k: Float // Kalman Gain
//
//        init(q: Float, r: Float, initialP: Float, initialValue: Float) {
//            self.q = q
//            self.r = r
//            self.x = initialValue
//            self.p = initialP
//            self.k = 0.0
//        }
//
//        mutating func update(measurement z: Float) {
//            // Vorhersage-Update
//            p = p + q
//
//            // Mess-Update
//            k = p / (p + r)
//            x = x + k * (z - x)
//            p = (1 - k) * p
//        }
//    }
//
//    func applyKalmanFilter(landmarks: [[SCNVector3]]) -> [[SCNVector3]] {
//        let q = qKalman
//        let r = rKalman
//        let initialP = initialPKalman
//        print("Prozessrauschen: \(q)")
//        print("Messrauschen: \(r)")
//        print("anfänglicher Schätzfehler: \(initialP)")
//        guard !landmarks.isEmpty, let firstLandmark = landmarks.first, !firstLandmark.isEmpty else {
//            return landmarks
//        }
//        var filteredLandmarks = landmarks
//        var xFilters = firstLandmark.map { KalmanFilter(q: q, r: r, initialP: initialP, initialValue: $0.x) }
//        var yFilters = firstLandmark.map { KalmanFilter(q: q, r: r, initialP: initialP, initialValue: $0.y) }
//        var zFilters = firstLandmark.map { KalmanFilter(q: q, r: r, initialP: initialP, initialValue: $0.z) }
//        for i in 0..<landmarks.count {
//            for j in 0..<landmarks[i].count {
//                xFilters[j].update(measurement: landmarks[i][j].x)
//                let filteredX = xFilters[j].x
//                yFilters[j].update(measurement: landmarks[i][j].y)
//                let filteredY = yFilters[j].x
//                zFilters[j].update(measurement: landmarks[i][j].z)
//                let filteredZ = zFilters[j].x
//                filteredLandmarks[i][j] = SCNVector3(x: filteredX, y: filteredY, z: filteredZ)
//            }
//        }
//        return filteredLandmarks
//    }
//
//    func shiftLandmarks(landmarks: [[SCNVector3]]) -> [[SCNVector3]] {
//        var shiftAmount = landmarkShiftAmount
//        print("Verschiebungswert: \(shiftAmount)")
//        var shiftedLandmarks = landmarks
//        if shiftAmount > 0 {
//            for timeIndex in stride(from: landmarks.count - 1, through: 0, by: -1) {
//                let shiftedIndex = max(timeIndex - shiftAmount, 0)
//                shiftedLandmarks[timeIndex] = landmarks[shiftedIndex]
//            }
//        } else if shiftAmount < 0 {
//            for timeIndex in 0..<landmarks.count {
//                let shiftedIndex = min(timeIndex - shiftAmount, landmarks.count - 1)
//                shiftedLandmarks[timeIndex] = landmarks[shiftedIndex]
//            }
//        }
//        return shiftedLandmarks
//    }
//}
//class VectorFunctions {
//    
//    func vector3ToDict(_ vector: SCNVector3) -> [String: Float] {
//        return ["x": vector.x, "y": vector.y, "z": vector.z]
//    }
//
//    func dictToVector3(_ dict: [String: Float]) -> SCNVector3? {
//        guard let x = dict["x"], let y = dict["y"], let z = dict["z"] else {
//            return nil
//        }
//        return SCNVector3(x, y, z)
//    }
//
//    class videoLandmarksJSON {
//        var landmarks: [[SCNVector3]]?
//        var timestamps: [Int]?
//    }
//
//    func videoLandmarksToString(landmarks: [[SCNVector3]], worldLandmarks: [[SCNVector3]], timestamps: [Int]) -> String? {
//        let landmarksDicts = landmarks.map { $0.map(vector3ToDict) }
//        let worldLandmarksDicts = worldLandmarks.map { $0.map(vector3ToDict) }
//        let object: [String: Any] = ["landmarks": landmarksDicts as Any, "worldLandmarks": worldLandmarksDicts as Any, "timestamps": timestamps as Any]
//        if let jsonData = try? JSONSerialization.data(withJSONObject: object, options: []),
//           let jsonString = String(data: jsonData, encoding: .utf8) {
//            return jsonString
//        }
//        print("fehler beim schreiben des JSON-Strings!")
//        return nil
//    }
//
//    func stringToVideoLandmarks(_ jsonString: String) -> ([[SCNVector3]], [[SCNVector3]], [Int])? {
//        do {
//            if let jsonData = jsonString.data(using: .utf8) {
//                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
//                if let landmarksAny = jsonObject?["landmarks"] as? [[[String: AnyObject]]],
//                   let worldLandmarksAny = jsonObject?["worldLandmarks"] as? [[[String: AnyObject]]],
//                   let timestampsAny = jsonObject?["timestamps"] as? [Int] {
//                    let landmarks = landmarksAny.map { landmarkArray in
//                        return landmarkArray.compactMap { landmarkDict in
//                            if let x = landmarkDict["x"] as? Float ?? landmarkDict["y"] as? Float ?? landmarkDict["z"] as? Float,
//                               let y = landmarkDict["y"] as? Float ?? landmarkDict["x"] as? Float ?? landmarkDict["z"] as? Float,
//                               let z = landmarkDict["z"] as? Float ?? landmarkDict["x"] as? Float ?? landmarkDict["y"] as? Float {
//                                return SCNVector3(x, y, z)
//                            } else {
//                                print("Ungültiger Landmarkeintrag: \(landmarkDict)")
//                                return nil
//                            }
//                        }
//                    }
//                    let worldLandmarks = worldLandmarksAny.map { worldLandmarkArray in
//                        return worldLandmarkArray.compactMap { worldLandmarkDict in
//                            if let x = worldLandmarkDict["x"] as? Float ?? worldLandmarkDict["y"] as? Float ?? worldLandmarkDict["z"] as? Float,
//                               let y = worldLandmarkDict["y"] as? Float ?? worldLandmarkDict["x"] as? Float ?? worldLandmarkDict["z"] as? Float,
//                               let z = worldLandmarkDict["z"] as? Float ?? worldLandmarkDict["x"] as? Float ?? worldLandmarkDict["y"] as? Float {
//                                return SCNVector3(x, y, z)
//                            } else {
//                                print("Ungültiger World Landmarkeintrag: \(worldLandmarkDict)")
//                                return nil
//                            }
//                        }
//                    }
//                    return (landmarks, worldLandmarks, timestampsAny)
//                } else {
//                    print("Fehler bei der Typumwandlung!")
//                }
//            }
//        } catch let error {
//            print("Fehler beim Lesen des JSON-Strings: \(error)")
//        }
//        return nil
//    }
//
//    func scnVector3ArrayToCGPointArray(_ vectors: [[SCNVector3]]) -> [[CGPoint]] {
//        return vectors.map { innerArray in
//            innerArray.map { vector in
//                CGPoint(x: CGFloat(vector.x), y: CGFloat(vector.y))
//            }
//        }
//    }
//
//    func addVector(_ vector1: SCNVector3, _ vector2: SCNVector3) -> SCNVector3 {
//        return SCNVector3(vector1.x + vector2.x, vector1.y + vector2.y, vector1.z + vector2.z)
//    }
//
//    func angleBetweenVectors(_ a: SCNVector3, _ b: SCNVector3, _ c: SCNVector3) -> CGFloat {
//        let ab = SCNVector3(b.x - a.x, b.y - a.y, b.z - a.z)
//        let bc = SCNVector3(c.x - b.x, c.y - b.y, c.z - b.z)
//        let dot = ab.x * bc.x + ab.y * bc.y + ab.z * bc.z
//        let magnitudeAB = sqrt(ab.x * ab.x + ab.y * ab.y + ab.z * ab.z)
//        let magnitudeBC = sqrt(bc.x * bc.x + bc.y * bc.y + bc.z * bc.z)
//        let magnitudeProduct = magnitudeAB * magnitudeBC
//        let angle = acos(dot / magnitudeProduct)
//        return CGFloat((angle * (180 / .pi)))
//    }
//}
//
//extension SCNVector3 {
//    
//    var normalized: SCNVector3 {
//        let len = sqrt(x * x + y * y + z * z)
//        return SCNVector3(x: x / len, y: y / len, z: z / len)
//    }
//    
//    func transformed(by matrix: SCNMatrix4) -> SCNVector3 {
//        let x = self.x * matrix.m11 + self.y * matrix.m21 + self.z * matrix.m31 + matrix.m41
//        let y = self.x * matrix.m12 + self.y * matrix.m22 + self.z * matrix.m32 + matrix.m42
//        let z = self.x * matrix.m13 + self.y * matrix.m23 + self.z * matrix.m33 + matrix.m43
//        return SCNVector3(x: x, y: y, z: z)
//    }
//}
