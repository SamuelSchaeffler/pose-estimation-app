//
//  ImportedViewController1.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 23.09.23.
//

import UIKit
import AVFoundation
import CoreData

class ImportedViewController: UIViewController {

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
    
    lazy var filterButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
        let image = UIImage(systemName: "slider.horizontal.2.square", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(openFilter), for: .touchUpInside)
        let buttonWidth: CGFloat = 55 //UIScreen.main.bounds.size.width / 2
        let buttonHeight: CGFloat = 55
        button.frame = CGRect(x: UIScreen.main.bounds.size.width - 93, y: UIScreen.main.bounds.size.height - 150, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = 27.5
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
        
        return button
    }()
    
    lazy var galleryButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
        let image = UIImage(systemName: "plus", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        let buttonWidth: CGFloat = 55 //UIScreen.main.bounds.size.width / 2
        let buttonHeight: CGFloat = 55
        button.frame = CGRect(x: (UIScreen.main.bounds.size.width - buttonWidth) / 2, y: UIScreen.main.bounds.size.height - 150, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = 27.5
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
        
        return button
    }()
    
    var mediaURL = [URL]()
    var mediaModel = MediaModel()
    var objectIDs = [NSManagedObjectID]()
    var photoVC = PhotoViewController()
    var videoVC = VideoViewController()
    var handTrackingVC = HandTrackingViewController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUIWithSelectedMedia), name: Notification.Name("SelectedPhotosUpdated"), object: nil)
        
        self.mediaURL = mediaModel.getMedia()
        
        print("Importierte Medien: \(self.mediaURL.count)")
        
        view.backgroundColor = .systemBackground
        
        photoVC.viewDidLoad()
        videoVC.viewDidLoad()
        handTrackingVC.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")

        view.addSubview(collectionView)
        view.addSubview(filterButton)
        view.addSubview(galleryButton)
        
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
    
    @objc func openFilter() {
        let customPopupVC = FilterViewController()
        customPopupVC.modalPresentationStyle = .overFullScreen
        self.present(customPopupVC, animated: false, completion: nil)

    }
    
    @objc func openGallery() {
        let customPopupVC = PhotoPickerViewController()
        customPopupVC.modalPresentationStyle = .fullScreen

        self.present(customPopupVC, animated: false, completion: nil)
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

    func updateCollectionView(withMediaURL mediaURL: [URL]) {
        self.mediaURL = mediaModel.getMedia()
            self.collectionView.reloadData()
        print("Importierte Medien: \(self.mediaURL.count)")
        }

    func generateThumbnail(for videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 2), actualTime: nil)
            var image = UIImage(cgImage: cgImage)
            
            if let cgImage = image.cgImage {
               // image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
            }
            
            return image
        } catch {
            print("Fehler beim Erstellen des Thumbnails: \(error.localizedDescription)")
            return nil
        }
    }

}

extension ImportedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaURL.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        let mediaURL = mediaURL[indexPath.item]
            
            if mediaURL.pathExtension.lowercased() == "mp4" || mediaURL.pathExtension.lowercased() == "mov" {

                cell.imageView.image = generateThumbnail(for: mediaURL)
            } else {
                
                cell.imageView.image = UIImage(contentsOfFile: mediaURL.path)
            }
            return cell
    }
}

extension ImportedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Aktion, die ausgeführt wird, wenn ein Bild ausgewählt wird
        let mediaURL = mediaURL[indexPath.item]
        if mediaURL.pathExtension.lowercased() == "mp4" || mediaURL.pathExtension.lowercased() == "mov" {
            let object = generateThumbnail(for: mediaURL)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("UpdateVideo"), object: object)
                NotificationCenter.default.post(name: Notification.Name("UpdateURL"), object: mediaURL)
                self.present(self.videoVC, animated: true, completion: nil)
            }
        } else {
            let object = UIImage(contentsOfFile: mediaURL.path)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("UpdatePhoto"), object: object)
                NotificationCenter.default.post(name: Notification.Name("UpdateURL"), object: mediaURL)
                self.present(self.photoVC, animated: true, completion: nil)
            }
        }
        self.objectIDs = mediaModel.getObjectIDs()
        NotificationCenter.default.post(name: Notification.Name("UpdateObjectID"), object: objectIDs[indexPath.item])
    }
    
    
}

class ImageCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
