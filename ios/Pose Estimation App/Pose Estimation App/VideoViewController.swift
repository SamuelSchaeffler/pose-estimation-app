//
//  VideoViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 25.09.23.
//

import UIKit
import AVKit
import CoreData
import SceneKit

class VideoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var image: UIImage?
    var url: URL?
    var objectID: NSManagedObjectID?
    
    var mediaModel = MediaModel()
    var trashModel = TrashModel()
    
    var MetadataArray1 = ["Aufnahmedatum:","Zeit:", "Auflösung:", "Dauer", "Bildwiederholrate", "Kamerahersteller:", "BPM:", "Rudiment:","Interpret:","Hand:","Grip:","Grip Matched:"]
    var Metadata: [String] = []

    var videoLandmarks: [[SCNVector3]] = []
    var videoWorldLandmarks: [[SCNVector3]] = []
    var videoTimestamps: [Int] = []
    
    let vectorFunctions = VectorFunctions()
    
    let videoViewContainer: UIView = {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 2.5)
        container.backgroundColor = .systemBackground
        return container
    }()

    lazy var videoView: UIImageView = {
        let videoView = UIImageView()
        videoView.image = image
        videoView.contentMode = .scaleAspectFill
        videoView.clipsToBounds = true
        videoView.frame = CGRect(x: 0, y: 0, width: videoViewContainer.frame.width, height: videoViewContainer.frame.height)
        videoView.isUserInteractionEnabled = true
        return videoView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let image = UIImage(systemName: "trash", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.setTitle("löschen", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let spacing: CGFloat = 10
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        let buttonWidth: CGFloat = UIScreen.main.bounds.size.width / 3
        let buttonHeight: CGFloat = 50
        button.frame = CGRect(x: ((UIScreen.main.bounds.size.width - buttonWidth) / 2) + 100, y: UIScreen.main.bounds.size.height - 150, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
        return button
    }()

    let trackingButton: UIButton = {
        let button = UIButton()
        button.adjustsImageWhenHighlighted = false
        button.setTitle("Handerkennung", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(startHandTracking), for: .touchUpInside)
        let buttonWidth: CGFloat = UIScreen.main.bounds.size.width / 2
        let buttonHeight: CGFloat = 50
        button.frame = CGRect(x: 25, y: UIScreen.main.bounds.size.height - 150, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
        return button
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let image = UIImage(systemName: "play.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 80
        button.frame = CGRect(x: (videoViewContainer.frame.width - buttonWidth) / 2, y: (videoViewContainer.frame.height - buttonHeight) / 2, width: buttonWidth, height: buttonHeight)
        return button
    }()

    lazy var videoTitle: UILabel = {
        let title = UILabel()
        title.text = "Titel"
        title.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        title.textAlignment = .center
        title.frame = CGRect(x: 0, y: (UIScreen.main.bounds.size.height / 2.5) + 10, width: view.frame.width, height: 40)
        return title
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    var alertController: UIAlertController = {
        let alertController = UIAlertController(title: "Handerkennung wird ausgeführt", message: "Bitte warten...", preferredStyle: .alert)
        var progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.setProgress(0.0, animated: true)
        progressBar.frame = CGRect(x: 10, y: 90, width: 250, height: 3)
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { (action) in
            NotificationCenter.default.post(name: Notification.Name("cancelAlert"), object: nil)
        }
        alertController.view.addSubview(progressBar)
        return alertController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: Notification.Name("UpdateVideo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateURL(_:)), name: Notification.Name("UpdateURL"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateObjectID(_:)), name: Notification.Name("UpdateObjectID"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(_:)), name: Notification.Name("updateProgress"), object: nil)
        
        self.tableView.reloadData()
        
        view.addSubview(videoViewContainer)
        videoViewContainer.addSubview(videoView)
        videoViewContainer.addSubview(playButton)
        view.addSubview(deleteButton)
        view.addSubview(trackingButton)
        view.addSubview(videoTitle)
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: (UIScreen.main.bounds.size.height / 2.5) + 50, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - (UIScreen.main.bounds.size.height / 2.5) - 220)
    }

    @objc func updateUI(_ notification: Notification) {
        if let image = notification.object as? UIImage {
            self.videoView.image = image
            self.tableView.reloadData()
        }
    }

    @objc func updateURL(_ notification: Notification) {
        if let videourl = notification.object as? URL {
            url = videourl
            self.videoTitle.text = String(videourl.lastPathComponent)
        }
    }
    
    @objc func updateObjectID(_ notification: Notification) {
        if let id = notification.object as? NSManagedObjectID {
            objectID = id
            Metadata = mediaModel.getVideoMetadata(objectID: objectID!)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func deleteItem() {
        trashModel.moveObjectFromMediaToTrash(objectID: objectID!)
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("SelectedPhotosUpdated"), object: self.mediaModel.getMedia())
    }
    
    @objc func startHandTracking() {
        if mediaModel.checkVideoLandmarks(objectID: objectID!) == false {
            self.present(alertController, animated: false)
            let handLandmarker = MediaPipeHandLandmarkerVideo()
            DispatchQueue.main.async { [self] in
                handLandmarker.generateLandmarks(objectID: objectID!)
                alertController.dismiss(animated: false)
            }
        }
        DispatchQueue.main.async { [self] in
            let string = mediaModel.getVideoLandmarks(objectID: objectID!)
            let data = vectorFunctions.stringToVideoLandmarks(string)!
            videoLandmarks = data.0
            videoWorldLandmarks = data.1
            videoTimestamps = data.2
            let playerVC = VideoAnalysisViewController()
            playerVC.videoURL = url
            playerVC.videoLandmarks = vectorFunctions.scnVector3ArrayToCGPointArray(videoLandmarks)
            playerVC.videoLandmarks3 = videoWorldLandmarks
            playerVC.videoTimestamps = videoTimestamps
            playerVC.modalPresentationStyle = .fullScreen
            present(playerVC, animated: false)
        }
    }
    
    @objc func updateProgress(_ notification: Notification) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
        let progress = notification.object as! Float
        if let progressBar = self.alertController.view.subviews.first(where: { $0 is UIProgressView }) as? UIProgressView {
            progressBar.setProgress(progress, animated: false)
        }
    }
    
    @objc func editTablePressed(indexPath: IndexPath) {
        if indexPath.row == 0 {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.layer.frame = CGRect(x: ((UIScreen.main.bounds.size.width-150)/2) - 43, y: 34, width: 130, height: 50)
            let alertController = UIAlertController(title: "Wählen Sie ein Datum", message: "                         ", preferredStyle: .alert)
            alertController.view.addSubview(datePicker)
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { (action) in
            }
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                let selectedDate = datePicker.date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                let dateString = dateFormatter.string(from: selectedDate)
                self.Metadata[indexPath.row] = dateString
                self.mediaModel.saveVideoMetadata(objectID: self.objectID!, array: self.Metadata)
                self.tableView.reloadData()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .time
            datePicker.layer.frame = CGRect(x: ((UIScreen.main.bounds.size.width-150)/2)-34, y: 34, width: 100, height: 50)
            let alertController = UIAlertController(title: "Wählen Sie eine Zeit", message: "                         ", preferredStyle: .alert)
            alertController.view.addSubview(datePicker)
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { (action) in
            }
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                let selectedDate = datePicker.date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let dateString = dateFormatter.string(from: selectedDate)
                self.Metadata[indexPath.row] = dateString + " Uhr"
                self.mediaModel.saveVideoMetadata(objectID: self.objectID!, array: self.Metadata)
                self.tableView.reloadData()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 2 {
            let alertController = UIAlertController(title: "Bearbeiten", message: "Geben Sie die neue Auflösung ein:", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Auflösung"
            }
            let saveAction = UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
                guard let textField = alertController.textFields?.first else { return }
                let newText = textField.text ?? ""
                self?.Metadata[indexPath.row] = newText
                self?.mediaModel.saveVideoMetadata(objectID: self!.objectID!, array: self!.Metadata)
                self?.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 3 {
            let alertController = UIAlertController(title: "Bearbeiten", message: "Geben Sie die neue Dauer ein:", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Dauer"
            }
            let saveAction = UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
                guard let textField = alertController.textFields?.first else { return }
                let newText = textField.text ?? ""
                self?.Metadata[indexPath.row] = newText
                self?.mediaModel.saveVideoMetadata(objectID: self!.objectID!, array: self!.Metadata)
                self?.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 4 {
            let alertController = UIAlertController(title: "Bearbeiten", message: "Geben Sie die neue Bildwiederholrate ein:", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Bildwiederholrate"
            }
            let saveAction = UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
                guard let textField = alertController.textFields?.first else { return }
                let newText = textField.text ?? ""
                self?.Metadata[indexPath.row] = newText
                self?.mediaModel.saveVideoMetadata(objectID: self!.objectID!, array: self!.Metadata)
                self?.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 5 {
            let alertController = UIAlertController(title: "Bearbeiten", message: "Geben Sie den neuen Kamerahersteller ein:", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Kamerahersteller"
            }
            let saveAction = UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
                guard let textField = alertController.textFields?.first else { return }
                let newText = textField.text ?? ""
                self?.Metadata[indexPath.row] = newText
                self?.mediaModel.saveVideoMetadata(objectID: self!.objectID!, array: self!.Metadata)
                self?.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 6 {
            let alertController = UIAlertController(title: "Bearbeiten", message: "Geben Sie die neuen BPM ein:", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "BPM"
            }
            let saveAction = UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
                guard let textField = alertController.textFields?.first else { return }
                let newText = textField.text ?? ""
                self?.Metadata[indexPath.row] = newText
                self?.mediaModel.saveVideoMetadata(objectID: self!.objectID!, array: self!.Metadata)
                self?.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 7 {
            let alertController = UIAlertController(title: "Bearbeiten", message: "Geben Sie das neue Rudiment ein:", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Rudiment"
            }
            let saveAction = UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
                guard let textField = alertController.textFields?.first else { return }
                let newText = textField.text ?? ""
                self?.Metadata[indexPath.row] = newText
                self?.mediaModel.saveVideoMetadata(objectID: self!.objectID!, array: self!.Metadata)
                self?.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 8 {
            let alertController = UIAlertController(title: "Bearbeiten", message: "Geben Sie den neuen Interpret ein:", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Interpret"
            }
            let saveAction = UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
                guard let textField = alertController.textFields?.first else { return }
                let newText = textField.text ?? ""
                self?.Metadata[indexPath.row] = newText
                self?.mediaModel.saveVideoMetadata(objectID: self!.objectID!, array: self!.Metadata)
                self?.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 9 {
            let alertController = UIAlertController(title: "Bearbeiten", message: "Geben Sie die neue Hand ein:", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Hand"
            }
            let saveAction = UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
                guard let textField = alertController.textFields?.first else { return }
                let newText = textField.text ?? ""
                self?.Metadata[indexPath.row] = newText
                self?.mediaModel.saveVideoMetadata(objectID: self!.objectID!, array: self!.Metadata)
                self?.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 10 {
            let alertController = UIAlertController(title: "Bearbeiten", message: "Geben Sie den neuen Grip ein:", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Grip"
            }
            let saveAction = UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
                guard let textField = alertController.textFields?.first else { return }
                let newText = textField.text ?? ""
                self?.Metadata[indexPath.row] = newText
                self?.mediaModel.saveVideoMetadata(objectID: self!.objectID!, array: self!.Metadata)
                self?.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 11 {
            let alertController = UIAlertController(title: "Bearbeiten", message: "Geben Sie den neuen Grip Matched ein:", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Grip Matched"
            }
            let saveAction = UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
                guard let textField = alertController.textFields?.first else { return }
                let newText = textField.text ?? ""
                self?.Metadata[indexPath.row] = newText
                self?.mediaModel.saveVideoMetadata(objectID: self!.objectID!, array: self!.Metadata)
                self?.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    @objc func playVideo() {
        let player = AVPlayer(url: url!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        editTablePressed(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(MetadataArray1.count, Metadata.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var label1 = cell.viewWithTag(1) as? UILabel
        var label2 = cell.viewWithTag(2) as? UILabel
        if label1 == nil {
            label1 = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.bounds.size.width / 2 - 15, height: cell.bounds.size.height))
            label1?.tag = 1
            label1?.numberOfLines = 0
            label1?.adjustsFontSizeToFitWidth = true
            label1?.minimumScaleFactor = 0.5
            cell.contentView.addSubview(label1!)
        }
        if label2 == nil {
            label2 = UILabel(frame: CGRect(x: tableView.bounds.size.width / 2, y: 0, width: tableView.bounds.size.width / 2 - 10, height: cell.bounds.size.height))
            label2?.tag = 2
            label2?.numberOfLines = 0
            label2?.textAlignment = .right
            label2?.adjustsFontSizeToFitWidth = true
            label2?.minimumScaleFactor = 0.5
            cell.contentView.addSubview(label2!)
        }
        label1?.text = (indexPath.row < MetadataArray1.count) ? MetadataArray1[indexPath.row] : ""
        label2?.text = (indexPath.row < Metadata.count) ? Metadata[indexPath.row] : ""
        return cell
    }
}
