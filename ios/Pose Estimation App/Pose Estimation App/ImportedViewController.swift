//
//  ImportedViewController1.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 23.09.23.
//

import UIKit

class ImportedViewController: UIViewController {

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10


        // Die Breite der CollectionView sollte entsprechend der Anzahl der Fotos pro Reihe angepasst werden.
        // Hier setzen wir 3 Fotos pro Reihe, daher sollte die Breite entsprechend berechnet werden.
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - 4 * layout.minimumInteritemSpacing) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth) // Die Größe der Zellen festlegen

        // Den Abstand zwischen den Zellen und dem Bildschirmrand einstellen
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground // Hintergrundfarbe ändern

        return collectionView
    }()
    
    let videoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10


        // Die Breite der CollectionView sollte entsprechend der Anzahl der Fotos pro Reihe angepasst werden.
        // Hier setzen wir 3 Fotos pro Reihe, daher sollte die Breite entsprechend berechnet werden.
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - 4 * layout.minimumInteritemSpacing) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth) // Die Größe der Zellen festlegen

        // Den Abstand zwischen den Zellen und dem Bildschirmrand einstellen
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground // Hintergrundfarbe ändern

        return collectionView
    }()
    
    var mediaURL = [URL]()
    var mediaModel = MediaModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUIWithSelectedMedia), name: Notification.Name("SelectedPhotosUpdated"), object: nil)
        
        self.mediaURL = mediaModel.getMedia()
        print("Importierte Medien: \(self.mediaURL.count)")
        
        view.backgroundColor = .systemBackground
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")

        view.addSubview(collectionView)

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
        self.mediaURL = mediaModel.getMedia()
            self.collectionView.reloadData()
        print("Importierte Medien: \(self.mediaURL.count)")
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

                // Hier könntest du das Video-Thumbnail anzeigen oder ein Symbol für Videos verwenden
                cell.imageView.image = UIImage(systemName: "viewfinder")
            } else {
                
                cell.imageView.image = UIImage(contentsOfFile: mediaURL.path)
            }
            print(mediaURL.path)
            return cell
    }
}

extension ImportedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Aktion, die ausgeführt wird, wenn ein Bild ausgewählt wird
        // Hier können Sie beispielsweise das ausgewählte Bild in einer Detailansicht anzeigen
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

