//
//  PhotoPickerViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 23.09.23.
//

import UIKit
import PhotosUI
import ImageIO
import AVFoundation
import Foundation

class PhotoPickerViewController: UIViewController, PHPickerViewControllerDelegate {
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var importedVC = ImportedViewController()
    var mediaModel = MediaModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        activityIndicator.center = view.center
        activityIndicator.color = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentPhotoPicker()
    }
    
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 3
        
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self
        present(pickerViewController, animated: false)
        //pickerViewController.modalPresentationStyle = .fullScreen
    }
    
    func readMetadataFromPhotoAtPath(_ imagePath: String) -> [String] {
        var array: [String] = []
        if let imageURL = URL(string: imagePath), let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) {
            if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] {
                
                // Aufnahmedatum
                
                
                
                
                if let exifProperties = imageProperties[kCGImagePropertyExifDictionary as String] as? [String: Any],
                   let dateTimeOriginal = exifProperties[kCGImagePropertyExifDateTimeOriginal as String] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                    if let date = dateFormatter.date(from: dateTimeOriginal) {
                        dateFormatter.dateFormat = "dd.MM.yyyy"
                        let date1 = dateFormatter.string(from: date)
                        array.append(String(date1))
                        dateFormatter.dateFormat = "HH:mm"
                        let time = dateFormatter.string(from: date)
                        array.append("\(time) Uhr")
                    }
                } else {
                    array.append("")
                    array.append("")
                }

                // Auflösung
                if let pixelWidth = imageProperties[kCGImagePropertyPixelWidth as String] as? Int,
                   let pixelHeight = imageProperties[kCGImagePropertyPixelHeight as String] as? Int {
                    
                    array.append("\(pixelWidth) x \(pixelHeight)")
                } else {
                    array.append("")
                }

                // Kamerahersteller
                if let tiffProperties = imageProperties[kCGImagePropertyTIFFDictionary as String] as? [String: Any],
                   let make = tiffProperties[kCGImagePropertyTIFFMake as String] as? String {
                    array.append("\(make)")
                } else {
                    array.append("")
                }
            }
        }
        array.append("")
        array.append("")
        return array
    }
    
    func readMetadataFromVideoAtPath(_ videoPath: String) -> [String] {
        var array: [String] = ["","","","","",""]
        
        let asset = AVAsset(url: URL(string: videoPath)!)
        
        // Überprüfe, ob das Asset gültig ist
        guard asset.isPlayable else {
            print("nicht abspielbar")
            return array
        }
        
        // Durchlaufe die Metadaten, um das Aufnahmedatum zu finden
        for metadataItem in AVMetadataItem.metadataItems(from: asset.metadata, filteredByIdentifier: AVMetadataIdentifier.commonIdentifierCreationDate) {
            if let creationDate = metadataItem.dateValue {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                var dateString = dateFormatter.string(from: creationDate)
                array[0] = ("\(dateString)")
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let timeString = timeFormatter.string(from: creationDate)
                array[1] = ("\(timeString) Uhr")
                
            }
        }
        
        // Auflösung
        if let videoTrack = asset.tracks(withMediaType: .video).first {
            let size = videoTrack.naturalSize
            let resolution = "\(Int(size.width))x\(Int(size.height))"
            array[2] = ("\(resolution)")
        }
        
        // Hersteller
        for metadataItem in AVMetadataItem.metadataItems(from: asset.metadata, filteredByIdentifier: AVMetadataIdentifier.commonIdentifierMake) {
            if let manufacturer = metadataItem.value as? String {
                array[3] = ("\(manufacturer)")
            }
        }
        
        // Dauer
        let durationInSeconds = CMTimeGetSeconds(asset.duration)
        let durationFormatted = String(format: "%.2f", durationInSeconds)
        array[4] = ("\(durationFormatted) Sekunden")
        
        // Bildwiederholrate
        if let videoFrameRate = asset.tracks(withMediaType: .video).first?.nominalFrameRate {
            let frameRateFormatted = String(format: "%.2f", videoFrameRate)
            array[5] = ("\(frameRateFormatted) FPS")
        }
        return array
    }
        
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let group = DispatchGroup()
        
        
        for result in results {
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                group.enter()
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { (url, error) in
                    if let imageURL = url {
                        
                        let temporaryURL = imageURL
                        let fileManager = FileManager.default
                        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let destinationURL = documentsDirectory.appendingPathComponent(temporaryURL.lastPathComponent)
                            
                        do {
                            try fileManager.moveItem(at: temporaryURL, to: destinationURL)
                        } catch {
                            print("Fehler beim Speichern des Mediums: \(error.localizedDescription)")
                        }
                        self.mediaModel.saveMedia(url: destinationURL, array: self.readMetadataFromPhotoAtPath(destinationURL.absoluteString))

                        group.leave()
                    }
                }
                
            } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                group.enter()
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { (url, error) in
                    if let videoURL = url {
                        let temporaryURL = videoURL
                        let fileManager = FileManager.default
                        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let destinationURL = documentsDirectory.appendingPathComponent(temporaryURL.lastPathComponent)
                        
                        do {
                            try fileManager.moveItem(at: temporaryURL, to: destinationURL)
                        } catch {
                            print("Fehler beim Speichern des Mediums: \(error.localizedDescription)")
                        }
                        self.mediaModel.saveMedia(url: destinationURL, array: self.readMetadataFromVideoAtPath(destinationURL.absoluteString))
                        
                        group.leave()
                    }
                }
            }
        }
        group.notify(queue: .main) {
            NotificationCenter.default.post(name: Notification.Name("SelectedPhotosUpdated"), object: self.mediaModel.getMedia())
            self.importedVC.collectionView.reloadData()
            
            self.tabBarController?.selectedIndex = 1
            
        }
        }
    }
