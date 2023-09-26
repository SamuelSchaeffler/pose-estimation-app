//
//  PhotoPickerViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 23.09.23.
//

import UIKit
import PhotosUI

class PhotoPickerViewController: UIViewController, PHPickerViewControllerDelegate {
    
    var importedVC = ImportedViewController()
    var mediaModel = MediaModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
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
        pickerViewController.modalPresentationStyle = .fullScreen
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
                        self.mediaModel.saveMedia(url: destinationURL)
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
                        self.mediaModel.saveMedia(url: destinationURL)
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
