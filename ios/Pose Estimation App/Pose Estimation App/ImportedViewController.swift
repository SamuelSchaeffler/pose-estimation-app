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
    
    var mediaURL = [URL]()
    var mediaModel = MediaModel()
    var objectIDs = [NSManagedObjectID]()
    var photoVC = PhotoViewController()
    var videoVC = VideoViewController()
    var handTrackingVC = PhotoAnalysisViewController()
    let vectorFunctions = VectorFunctions()
    
    var selectionStatus = [Bool]()
    var selectedCount = 0
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

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
    
    let filterButton: UIButton = {
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
    
    let galleryButton: UIButton = {
    let button = UIButton()
    let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
    let image = UIImage(systemName: "plus", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
    button.setImage(image, for: .normal)
    button.adjustsImageWhenHighlighted = false
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
    let buttonWidth: CGFloat = 55
    let buttonHeight: CGFloat = 55
    button.frame = CGRect(x: (UIScreen.main.bounds.size.width - buttonWidth) / 2, y: UIScreen.main.bounds.size.height - 150, width: buttonWidth, height: buttonHeight)
    button.layer.cornerRadius = 27.5
    button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
    button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
    button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
    return button
}()
    
    let compareButton: UIButton = {
    let button = UIButton()
    let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
    let image = UIImage(systemName: "square.2.layers.3d.top.filled", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
    button.setImage(image, for: .normal)
    button.adjustsImageWhenHighlighted = false
    button.backgroundColor = .systemYellow
    button.setTitleColor(.white, for: .normal)
    button.addTarget(self, action: #selector(openComparison), for: .touchUpInside)
    let buttonWidth: CGFloat = 55 //UIScreen.main.bounds.size.width / 2
    let buttonHeight: CGFloat = 55
    button.frame = CGRect(x: 93 - buttonWidth , y: UIScreen.main.bounds.size.height - 150, width: buttonWidth, height: buttonHeight)
    button.layer.cornerRadius = 27.5
    button.isHidden = true
    button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
    button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
    button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
    return button
}()
    
    let alertController: UIAlertController = {
        let alertController = UIAlertController(title: "Handerkennung wird ausgeführt", message: "Bitte warten...", preferredStyle: .alert)
        var progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.setProgress(0.0, animated: true)
        progressBar.frame = CGRect(x: 10, y: 90, width: 250, height: 3)
        alertController.view.addSubview(progressBar)
        return alertController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUIWithSelectedMedia), name: Notification.Name("SelectedPhotosUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(_:)), name: Notification.Name("updateProgress"), object: nil)
        
        self.mediaURL = mediaModel.getMedia()
        selectionStatus = [Bool](repeating: false, count: mediaModel.getMedia().count)
        
        print("Importierte Medien: \(self.mediaURL.count)")

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
        photoVC.viewDidLoad()
        videoVC.viewDidLoad()
        handTrackingVC.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")

        view.addSubview(collectionView)
        view.addSubview(filterButton)
        view.addSubview(galleryButton)
        view.addSubview(compareButton)

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
        let photoPickerVC = PhotoPickerViewController()
        photoPickerVC.modalPresentationStyle = .fullScreen
        self.present(photoPickerVC, animated: false, completion: nil)
    }
    
    @objc func openComparison() {
        let pVC = PhotoComparisonViewController()
        let vVC = VideoComparisonViewController()
        let selectedIndices = selectionStatus.enumerated().compactMap { index, isSelected in
            isSelected ? index : nil
        }
        var isPhotoArray: [String] = []
        self.objectIDs = mediaModel.getObjectIDs()
        for i in 0..<(selectedIndices.count) {
            isPhotoArray.append(mediaModel.checkMediaType(objectID: objectIDs[selectedIndices[i]]))
        }
        if isPhotoArray.allSatisfy({ $0 == "true" }) {
            for i in 0..<(selectedIndices.count) {
                pVC.images.append(UIImage(contentsOfFile: mediaURL[selectedIndices[i]].path)!)
            }
            pVC.modalPresentationStyle = .overFullScreen
            self.present(pVC, animated: false, completion: nil)
        } else if isPhotoArray.allSatisfy({ $0 == "false" }) {
            if selectedIndices.count == 2 {
                var isAlertControllerPresented = false
                if mediaModel.checkVideoLandmarks(objectID: objectIDs[selectedIndices[0]]) == false {
                    if !isAlertControllerPresented {
                        self.present(alertController, animated: false)
                        isAlertControllerPresented = true
                    }
                    let handLandmarker = MediaPipeHandLandmarkerVideo()
                    DispatchQueue.main.async { [self] in
                        handLandmarker.generateLandmarks(objectID: objectIDs[selectedIndices[0]])
                        alertController.dismiss(animated: false)
                        isAlertControllerPresented = false
                    }
                }
                if mediaModel.checkVideoLandmarks(objectID: objectIDs[selectedIndices[1]]) == false {
                    if !isAlertControllerPresented {
                        self.present(alertController, animated: false)
                        isAlertControllerPresented = true
                    }
                    let handLandmarker = MediaPipeHandLandmarkerVideo()
                    DispatchQueue.main.async { [self] in
                        handLandmarker.generateLandmarks(objectID: objectIDs[selectedIndices[1]])
                        alertController.dismiss(animated: false)
                        isAlertControllerPresented = false
                    }
                }
                DispatchQueue.main.async { [self] in
                    let string1 = mediaModel.getVideoLandmarks(objectID: objectIDs[selectedIndices[0]])
                    let string2 = mediaModel.getVideoLandmarks(objectID: objectIDs[selectedIndices[1]])
                    let data1 = vectorFunctions.stringToVideoLandmarks(string1)!
                    let data2 = vectorFunctions.stringToVideoLandmarks(string2)!

                    vVC.video1URL = mediaURL[selectedIndices[0]]
                    vVC.video2URL = mediaURL[selectedIndices[1]]
                    vVC.video1Landmarks = vectorFunctions.scnVector3ArrayToCGPointArray(data1.0)
                    vVC.video2Landmarks = vectorFunctions.scnVector3ArrayToCGPointArray(data2.0)
                    vVC.video1Landmarks3 = data1.1
                    vVC.video2Landmarks3 = data2.1
                    vVC.video1Timestamps = data1.2
                    vVC.video2Timestamps = data2.2
                }
                vVC.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    if strongSelf.presentedViewController == nil {
                        strongSelf.present(vVC, animated: false)
                    } else {
                        strongSelf.presentedViewController?.dismiss(animated: false, completion: {
                            strongSelf.present(vVC, animated: false)
                        })
                    }
                }
            } else {
                let alertController = UIAlertController(title: "Achtung!", message: "Bitte wählen Sie insgesamt 2 Videos aus.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                present(alertController, animated: false, completion: nil)
            }
        } else {
            let alertController = UIAlertController(title: "Achtung!", message: "Bitte wählen Sie nur Fotos oder Videos aus.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: false, completion: nil)
        }
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

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            feedbackGenerator.impactOccurred()
        }
        if gesture.state != .ended {
            return
        }
        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            
            if selectedCount < 5 || selectionStatus[indexPath.item] {
                selectionStatus[indexPath.item] = !selectionStatus[indexPath.item]
                selectedCount += selectionStatus[indexPath.item] ? 1 : -1
                collectionView.reloadItems(at: [indexPath])
            }
        }
        compareButton.isHidden = selectedCount < 1
    }

    @objc func updateProgress(_ notification: Notification) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
        let progress = notification.object as! Float
        if let progressBar = self.alertController.view.subviews.first(where: { $0 is UIProgressView }) as? UIProgressView {
            progressBar.setProgress(progress, animated: false)
        }
    }
    
    func updateCollectionView(withMediaURL mediaURL: [URL]) {
        self.mediaURL = mediaModel.getMedia()
        selectionStatus = [Bool](repeating: false, count: mediaModel.getMedia().count)
        selectedCount = 0
            self.collectionView.reloadData()
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
}

extension ImportedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaURL.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        let mediaURL = mediaURL[indexPath.item]
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
            if mediaURL.pathExtension.lowercased() == "mp4" || mediaURL.pathExtension.lowercased() == "mov" {
                cell.imageView.image = generateThumbnail(for: mediaURL)
                cell.overlayImageView.image = UIImage(systemName: "video.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            } else {
                cell.imageView.image = UIImage(contentsOfFile: mediaURL.path)
                cell.overlayImageView.image = UIImage(systemName: "photo.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            }
        cell.selectionStatus = selectionStatus[indexPath.item]
        return cell
    }
}

extension ImportedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
    class ImageCollectionViewCell: UICollectionViewCell {
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
        
        var selectionIndicator: UIImageView?
        var image = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysOriginal)
        
        var selectionStatus: Bool = false {
            didSet {
                updateSelectionStatus()
            }
        }
        
        func updateSelectionStatus() {
            if selectionIndicator == nil {
                selectionIndicator = UIImageView(image: image)
                selectionIndicator!.frame = CGRect(x: self.frame.width - 30, y: 5, width: 26, height: 25)
                contentView.addSubview(selectionIndicator!)
            }
            selectionIndicator!.image = selectionStatus ? image : nil
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(imageView)
            contentView.addSubview(overlayImageView)

            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                
                overlayImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -37),
                overlayImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 40),
                overlayImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
                overlayImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
            ])
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}


