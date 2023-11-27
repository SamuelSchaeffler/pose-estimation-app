//
//  TrashViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 26.09.23.
//

import UIKit
import AVFoundation
import CoreData

class TrashViewController: UIViewController {
    
    lazy var emptyTrashButton: UIButton = {
        let button = UIButton()
        button.adjustsImageWhenHighlighted = false
        button.setTitle("Papierkorb leeren", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(emptyTrash), for: .touchUpInside)
        let buttonWidth: CGFloat = UIScreen.main.bounds.size.width / 2
        let buttonHeight: CGFloat = 50
        button.frame = CGRect(x: ((UIScreen.main.bounds.size.width - buttonWidth) / 2), y: UIScreen.main.bounds.size.height - 150, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = 25
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
            
        
        return button
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - 4 * layout.minimumInteritemSpacing) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground

        return collectionView
    }()
    
    let videoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - 4 * layout.minimumInteritemSpacing) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground

        return collectionView
    }()
    
    var trashURL = [URL]()
    var trashModel = TrashModel()
    var mediaModel = MediaModel()
    var objectIDs = [NSManagedObjectID]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        NotificationCenter.default.addObserver(self, selector: #selector(updateUIWithSelectedMedia), name: Notification.Name("SelectedPhotosUpdated"), object: nil)
        
        self.trashURL = trashModel.getTrash()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrashCollectionViewCell.self, forCellWithReuseIdentifier: "TrashCell")

        view.addSubview(collectionView)

        view.addSubview(emptyTrashButton)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc func updateUIWithSelectedMedia(notification: Notification) {
        if let mediaURL = notification.object as? [URL] {
            updateCollectionView(withMediaURL: mediaURL)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateCollectionView(withMediaURL mediaURL: [URL]) {
        self.trashURL = trashModel.getTrash()
            self.collectionView.reloadData()
        print("Medien im Papierkorb: \(self.trashURL.count)")
        }

    func generateThumbnail(for videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let videoOrientation = videoTrack.preferredTransform
        let videoAngle = atan2(videoOrientation.b, videoOrientation.a) * (180 / .pi)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 2), actualTime: nil)
            var image = UIImage(cgImage: cgImage)
            
            if let cgImage = image.cgImage {
                if abs(videoAngle) == 90 {
                    //Hochformat
                    image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
                } else if abs(videoAngle) == 180 {
                    image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .down)
                }
                
               
            }
            
            return image
        } catch {
            print("Fehler beim Erstellen des Thumbnails: \(error.localizedDescription)")
            return nil
        }
    }
    
    @objc func emptyTrash() {
        
        let fileManager = FileManager.default
            for url in trashURL {
                do {
                    try fileManager.removeItem(at: url)
                    print("Datei gelöscht: \(url.lastPathComponent)")
                } catch {
                    print("Fehler beim Löschen der Datei \(url.lastPathComponent): \(error.localizedDescription)")
                }
                do {
                    try fileManager.removeItem(at: annotatedURL(from: url)!)
                    print("Datei gelöscht: \(annotatedURL(from: url)!.lastPathComponent)")
                } catch {
                    print("Fehler beim Löschen der Datei \(annotatedURL(from: url)!.lastPathComponent): \(error.localizedDescription)")
                }
            }
        trashModel.emptyTrash()
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("SelectedPhotosUpdated"), object: self.trashModel.getTrash())
    }
    
    @objc func buttonPressed(sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
    }
    @objc func buttonReleased(sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
}

extension TrashViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trashURL.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrashCell", for: indexPath) as! TrashCollectionViewCell
        let trashURL = trashURL[indexPath.item]
            
            if trashURL.pathExtension.lowercased() == "mp4" || trashURL.pathExtension.lowercased() == "mov" {

                cell.imageView.image = generateThumbnail(for: trashURL)
            } else {
                
                cell.imageView.image = UIImage(contentsOfFile: trashURL.path)
            }
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold)
            cell.overlayImageView.image = UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            return cell
    }
}

extension TrashViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Aktion, die ausgeführt wird, wenn ein Bild ausgewählt wird
        
        self.objectIDs = trashModel.getObjectIDs()
        trashModel.moveObjectFromTrashToMedia(objectID: objectIDs[indexPath.item])
        self.trashURL = trashModel.getTrash()
        self.collectionView.reloadData()
        print("Medien im Papierkorb: \(self.trashURL.count)")
        NotificationCenter.default.post(name: Notification.Name("SelectedPhotosUpdated"), object: self.mediaModel.getMedia())
        
    }
}

class TrashCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    let overlayImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .center
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(overlayImageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            overlayImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            overlayImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            overlayImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            overlayImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
        
        

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
