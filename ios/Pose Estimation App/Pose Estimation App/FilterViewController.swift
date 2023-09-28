//
//  ViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 22.09.23.
//

import UIKit

var filterSettings: [String] = ["0","","1","","","","0","0"]

class FilterViewController: UIViewController {
    
    var importedVC = ImportedViewController()
    var mediaModel = MediaModel()
    
    let customView: UIView = {
        let customView = UIView()
        customView.backgroundColor = .systemGray6
        customView.frame = CGRect(x: 0, y: 0, width: 300, height: 400)
        customView.layer.cornerRadius = 20
        return customView
        
    }()
    
    let filterButton: UIButton = {
            let button = UIButton()
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
            let image = UIImage(systemName: "slider.horizontal.2.square", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            button.setImage(image, for: .normal)
            button.adjustsImageWhenHighlighted = false
            button.setTitle("Filter", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(closeFilter), for: .touchUpInside)
            let buttonWidth: CGFloat = 90 //UIScreen.main.bounds.size.width / 2
            let buttonHeight: CGFloat = 50
            button.frame = CGRect(x: UIScreen.main.bounds.size.width - 107, y: UIScreen.main.bounds.size.height - 150, width: buttonWidth, height: buttonHeight)
            button.layer.cornerRadius = 25
            
            button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
            button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
            button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
            
            return button
        }()
    
    let filterLabel: UILabel = {
        let label = UILabel()
        label.text = "Medien filtern"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: (300 - width) / 2, y: 10, width: width, height: height)
        return label
    }()
    
    let mediaSegmentedControl: UISegmentedControl = {
        let items = ["Alles", "Videos", "Fotos"]
        let segmentedControl = UISegmentedControl(items: items)
        let width: CGFloat = 250
        let height: CGFloat = 30
        segmentedControl.frame = CGRect(x: (300 - width) / 2, y: 50, width: width, height: height)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Aufnahmedatum:"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: ((300 - width) / 2), y: 100, width: width, height: height)
        return label
    }()
    
    let calendarPicker: UIDatePicker = {
        let calendar = UIDatePicker()
        calendar.datePickerMode = .date
        let width: CGFloat = 250
        let height: CGFloat = 30
        calendar.frame = CGRect(x: 25, y: 100, width: width, height: height)
        calendar.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return calendar
    }()

    let bpmLabel: UILabel = {
            let label = UILabel()
            label.text = "BPM:"
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label.textAlignment = .left
            let width: CGFloat = 250
            let height: CGFloat = 30
            label.frame = CGRect(x: ((300 - width) / 2), y: 150, width: width, height: height)
            return label
        }()

    let bpmSegmentedControl: UISegmentedControl = {
        let items = ["<", "=", ">"]
        let segmentedControl = UISegmentedControl(items: items)
        let width: CGFloat = 120
        let height: CGFloat = 30
        segmentedControl.frame = CGRect(x: (300 - width) / 2, y: 150, width: width, height: height)
        segmentedControl.selectedSegmentIndex = 0 // Standardmäßig ausgewählte Option
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    let bpmTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "BPM"
        textField.keyboardType = .numbersAndPunctuation
        textField.returnKeyType = .done
        textField.backgroundColor = .systemBackground
        textField.textAlignment = .center
        let width: CGFloat = 50
        let height: CGFloat = 30
        textField.frame = CGRect(x: ((300 - width) / 2) + 100, y: 150, width: width, height: height)
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    let interpretLabel: UILabel = {
            let label = UILabel()
            label.text = "Interpret:"
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label.textAlignment = .left
            let width: CGFloat = 250
            let height: CGFloat = 30
            label.frame = CGRect(x: ((300 - width) / 2), y: 200, width: width, height: height)
            return label
        }()
    
    let interpretTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Interpret"
        textField.backgroundColor = .systemBackground
        textField.textAlignment = .center
        textField.returnKeyType = .done
        let width: CGFloat = 170
        let height: CGFloat = 30
        textField.frame = CGRect(x: ((300 - width) / 2) + 40, y: 200, width: width, height: height)
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    let handLabel: UILabel = {
            let label = UILabel()
            label.text = "Hand:"
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label.textAlignment = .left
            let width: CGFloat = 250
            let height: CGFloat = 30
            label.frame = CGRect(x: ((300 - width) / 2), y: 350, width: width, height: height)
            return label
        }()
    
    let handSegmentedControl: UISegmentedControl = {
        let items = ["Alle", "Links", "Rechts"]
        let segmentedControl = UISegmentedControl(items: items)
        let width: CGFloat = 170
        let height: CGFloat = 30
        segmentedControl.frame = CGRect(x: ((300 - width) / 2) + 40, y: 350, width: width, height: height)
        segmentedControl.selectedSegmentIndex = 0 // Standardmäßig ausgewählte Option
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return segmentedControl
    }()

    let gripLabel: UILabel = {
            let label = UILabel()
            label.text = "Grip:"
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label.textAlignment = .left
            let width: CGFloat = 250
            let height: CGFloat = 30
            label.frame = CGRect(x: ((300 - width) / 2), y: 250, width: width, height: height)
            return label
        }()
    
    let gripTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Grip"
        textField.backgroundColor = .systemBackground
        textField.textAlignment = .center
        textField.returnKeyType = .done
        let width: CGFloat = 170
        let height: CGFloat = 30
        textField.frame = CGRect(x: ((300 - width) / 2) + 40, y: 250, width: width, height: height)
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    let gripSegmentedControl: UISegmentedControl = {
        let items = ["Alle", "Matched", "Unmatched"]
        let segmentedControl = UISegmentedControl(items: items)
        let width: CGFloat = 250
        let height: CGFloat = 30
        segmentedControl.frame = CGRect(x: (300 - width) / 2, y: 300, width: width, height: height)
        segmentedControl.selectedSegmentIndex = 0 // Standardmäßig ausgewählte Option
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        
        setFilterSettings()
        
        bpmTextField.text = filterSettings[3]
        interpretTextField.text = filterSettings[4]
        gripTextField.text = filterSettings[5]
        
        customView.center = view.center
        view.addSubview(customView)
        view.addSubview(filterButton)
        
        bpmTextField.delegate = self
        interpretTextField.delegate = self
        gripTextField.delegate = self
        
        customView.addSubview(filterLabel)
        customView.addSubview(mediaSegmentedControl)
        customView.addSubview(dateLabel)
        customView.addSubview(calendarPicker)
        customView.addSubview(bpmLabel)
        customView.addSubview(bpmSegmentedControl)
        customView.addSubview(bpmTextField)
        customView.addSubview(interpretLabel)
        customView.addSubview(interpretTextField)
        customView.addSubview(handLabel)
        customView.addSubview(handSegmentedControl)
        customView.addSubview(gripLabel)
        customView.addSubview(gripTextField)
        customView.addSubview(gripSegmentedControl)
        
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
    @objc func closeFilter() {
        dismiss(animated: false, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("SelectedPhotosUpdated"), object: self.mediaModel.getMedia())
        self.importedVC.collectionView.reloadData()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        //filterSettings[1] = "date)"
        print(sender.date)
    }

    @objc func segmentedControlValueChanged(sender: UISegmentedControl) {
        // Verarbeite die ausgewählte Option
        let selectedIndex = sender.selectedSegmentIndex
        let selectedOption = sender.titleForSegment(at: selectedIndex)
        
        if sender == mediaSegmentedControl {
            filterSettings[0] = String(sender.selectedSegmentIndex)
        }
        if sender == bpmSegmentedControl {
            filterSettings[2] = String(sender.selectedSegmentIndex)
        }
        if sender == gripSegmentedControl {
            filterSettings[6] = String(sender.selectedSegmentIndex)
        }
        if sender == handSegmentedControl {
            filterSettings[7] = String(sender.selectedSegmentIndex)
        }
    }
    
    func setFilterSettings() {
        mediaSegmentedControl.selectedSegmentIndex = Int(filterSettings[0])!
        bpmSegmentedControl.selectedSegmentIndex = Int(filterSettings[2])!
        gripSegmentedControl.selectedSegmentIndex = Int(filterSettings[6])!
        handSegmentedControl.selectedSegmentIndex = Int(filterSettings[7])!
    }
}

extension FilterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == bpmTextField {
            filterSettings[3] = String(textField.text!)
        } else if textField == interpretTextField {
            filterSettings[4] = String(textField.text!)
        } else {
            filterSettings[5] = String(textField.text!)
        }
        textField.resignFirstResponder()
        return true
    }
}
