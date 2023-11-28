//
//  ViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 22.09.23.
//

import UIKit
import RangeUISlider

let currentDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)

var filterSettings: [String] = ["0","","1","","","","0","0"]
var dateFilterSettings: [String] = ["false", "", ""]
var bpmFilterSettings: [String] = ["false", "50", "150"]

class FilterViewController: UIViewController, RangeUISliderDelegate {
    

    
    
    var mediaModel = MediaModel()
    
    class LineView: UIView {
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            // Definieren Sie die Start- und Endpunkte der Linie
            let startPoint = CGPoint(x: 0, y: rect.height / 2)
            let endPoint = CGPoint(x: rect.width, y: rect.height / 2)
            
            // Erstellen Sie ein UIBezierPath-Objekt für die Linie
            let linePath = UIBezierPath()
            linePath.move(to: startPoint)
            linePath.addLine(to: endPoint)
            
            // Legen Sie die Linienfarbe und -dicke fest
            let lineColor = UIColor.systemGray2.withAlphaComponent(0.5)
            lineColor.setStroke()
            linePath.lineWidth = 2.0
            
            // Zeichnen Sie die Linie
            linePath.stroke()
        }
    }

    let line1 = LineView(frame: CGRect(x: 4, y: 90, width: 292, height: 2))
    let line2 = LineView(frame: CGRect(x: 4, y: 180, width: 292, height: 2))
    
    let customView: UIView = {
        let customView = UIView()
        customView.backgroundColor = .systemGray6
        customView.frame = CGRect(x: 0, y: -230, width: 300, height: 500)
        customView.layer.cornerRadius = 20
        return customView
        
    }()
    
    let filterButton: UIButton = {
            let button = UIButton()
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
            let image = UIImage(systemName: "slider.horizontal.2.square", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            button.setImage(image, for: .normal)
            button.adjustsImageWhenHighlighted = false
            button.backgroundColor = .systemGreen
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(closeFilter), for: .touchUpInside)
            let buttonWidth: CGFloat = 55 //UIScreen.main.bounds.size.width / 2
            let buttonHeight: CGFloat = 55
            button.frame = CGRect(x: UIScreen.main.bounds.size.width - 93, y: UIScreen.main.bounds.size.height - 150, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = 27.5
            
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
    
    let dateLabel1: UILabel = {
        let label = UILabel()
        label.text = "Zeitspanne wählen"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: ((300 - width) / 2), y: 100, width: width, height: height)
        return label
    }()
    
    let dateToggle: UISwitch = {
        let toggle = UISwitch()
        let width: CGFloat = 250
        let height: CGFloat = 30
        toggle.layer.frame = CGRect(x: 225, y: 100, width: width, height: height)
        toggle.addTarget(self, action: #selector(dateToggleChanged(_:)), for: .valueChanged)
        toggle.isOn = Bool(dateFilterSettings[0])!
        return toggle
    }()
    
    let dateOffView: UIView = {
        let view = UIView()
        view.layer.frame = CGRect(x: 2, y: 140, width: 298, height: 40)
        view.backgroundColor = .systemGray6.withAlphaComponent(0.5)
        view.isHidden = Bool(dateFilterSettings[0])!
        return view
    }()
    
    let dateLabel2: UILabel = {
        let label = UILabel()
        label.text = "von"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: ((300 - width) / 2), y: 140, width: width, height: height)
        return label
    }()

    let calendarPicker1: UIDatePicker = {
        let calendar = UIDatePicker()
        calendar.datePickerMode = .date
        
        if dateFilterSettings[1] == "" {
            calendar.date = Date()
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let date = dateFormatter.date(from: dateFilterSettings[1])
            calendar.date = date!
        }
        let width: CGFloat = 80
        let height: CGFloat = 30
        calendar.frame = CGRect(x: 65, y: 140, width: width, height: height)
        calendar.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return calendar
    }()
    
    let dateLabel3: UILabel = {
        let label = UILabel()
        label.text = "bis"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: ((300 - width))+110, y: 140, width: width, height: height)
        return label
    }()
    
    let calendarPicker2: UIDatePicker = {
        let calendar = UIDatePicker()
        calendar.datePickerMode = .date
        
        if dateFilterSettings[2] == "" {
            calendar.date = Date()
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let date = dateFormatter.date(from: dateFilterSettings[2])
            calendar.date = date!
        }
        let width: CGFloat = 80
        let height: CGFloat = 30
        calendar.frame = CGRect(x: 195, y: 140, width: width, height: height)
        calendar.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return calendar
    }()

    let bpmLabel1: UILabel = {
            let label = UILabel()
            label.text = "BPM wählen"
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label.textAlignment = .left
            let width: CGFloat = 250
            let height: CGFloat = 30
            label.frame = CGRect(x: ((300 - width) / 2), y: 200, width: width, height: height)
            return label
        }()
    
    let bpmToggle: UISwitch = {
        let toggle = UISwitch()
        let width: CGFloat = 250
        let height: CGFloat = 30
        toggle.layer.frame = CGRect(x: 225, y: 200, width: width, height: height)
        toggle.addTarget(self, action: #selector(bpmToggleChanged(_:)), for: .valueChanged)
        toggle.isOn = Bool(bpmFilterSettings[0])!
        return toggle
    }()
    
    let bpmOffView: UIView = {
        let view = UIView()
        view.layer.frame = CGRect(x: 2, y: 235, width: 298, height: 40)
        view.backgroundColor = .systemGray6.withAlphaComponent(0.5)
        view.isHidden = Bool(bpmFilterSettings[0])!
        return view
    }()
    
    let bpmLabel2: UILabel = {
            let label = UILabel()
            label.text = "von"
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label.textAlignment = .left
            let width: CGFloat = 50
            let height: CGFloat = 30
            label.frame = CGRect(x: ((300 - width) / 2) - 10, y: 240, width: width, height: height)
            return label
        }()

    let bpmLabel3: UILabel = {
            let label = UILabel()
            label.text = "-"
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label.textAlignment = .left
            let width: CGFloat = 50
            let height: CGFloat = 30
            label.frame = CGRect(x: ((300 - width) - 37 ), y: 240, width: width, height: height)
            return label
        }()

    let rangeSlider: RangeUISlider = {
        var rangeSlider = RangeUISlider(frame: CGRect(origin: CGPoint(x: 20, y: 20), size: CGSize(width: 100, height: 50)))
        rangeSlider.translatesAutoresizingMaskIntoConstraints = false
        rangeSlider.scaleMinValue = 0
        rangeSlider.scaleMaxValue = 200
        rangeSlider.defaultValueLeftKnob = CGFloat(Int(bpmFilterSettings[1])!)
        rangeSlider.defaultValueRightKnob = CGFloat(Int(bpmFilterSettings[2])!)
        rangeSlider.rangeSelectedGradientColor1 = .systemGreen
        rangeSlider.rangeSelectedGradientColor2 = .systemGreen
        rangeSlider.rangeSelectedGradientStartPoint = CGPoint(x: 0, y: 0.5)
        rangeSlider.rangeSelectedGradientEndPoint = CGPoint(x: 0, y: 1)
        rangeSlider.rangeNotSelectedGradientColor1 = .systemGray2
        rangeSlider.rangeNotSelectedGradientColor2 = .systemGray2
        rangeSlider.rangeNotSelectedGradientStartPoint = CGPoint(x: 0, y: 0.5)
        rangeSlider.rangeNotSelectedGradientEndPoint = CGPoint(x: 0, y: 1)
        rangeSlider.barHeight = 5
        rangeSlider.barCorners = 2.5
        rangeSlider.leftKnobColor = .white
        rangeSlider.leftKnobWidth = 20
        rangeSlider.leftKnobHeight = 20
        rangeSlider.leftKnobCorners = 10
        rangeSlider.rightKnobColor = .white
        rangeSlider.rightKnobWidth = 20
        rangeSlider.rightKnobHeight = 20
        rangeSlider.rightKnobCorners = 10
        rangeSlider.isUserInteractionEnabled = true
                
        return rangeSlider
    }()
    
    let bpmTextField1: UITextField = {
        let textField = UITextField()
        textField.placeholder = "BPM"
        textField.keyboardType = .numbersAndPunctuation
        textField.returnKeyType = .done
        textField.backgroundColor = .systemBackground
        textField.textAlignment = .center
        let width: CGFloat = 50
        let height: CGFloat = 30
        textField.frame = CGRect(x: ((300 - width) / 2) + 32 , y: 240, width: width, height: height)
        textField.layer.cornerRadius = 8
        textField.isUserInteractionEnabled = false
        return textField
    }()
    
    let bpmTextField2: UITextField = {
        let textField = UITextField()
        textField.placeholder = "BPM"
        textField.keyboardType = .numbersAndPunctuation
        textField.returnKeyType = .done
        textField.backgroundColor = .systemBackground
        textField.textAlignment = .center
        let width: CGFloat = 50
        let height: CGFloat = 30
        textField.frame = CGRect(x: ((300 - width) / 2) + 100, y: 240, width: width, height: height)
        textField.layer.cornerRadius = 8
        textField.isUserInteractionEnabled = false
        return textField
    }()
    
    let interpretLabel: UILabel = {
            let label = UILabel()
            label.text = "Interpret:"
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label.textAlignment = .left
            let width: CGFloat = 250
            let height: CGFloat = 30
            label.frame = CGRect(x: ((300 - width) / 2), y: 300, width: width, height: height)
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
        textField.frame = CGRect(x: ((300 - width) / 2) + 40, y: 300, width: width, height: height)
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
            label.frame = CGRect(x: ((300 - width) / 2), y: 450, width: width, height: height)
            return label
        }()
    
    let handSegmentedControl: UISegmentedControl = {
        let items = ["Alle", "Links", "Rechts"]
        let segmentedControl = UISegmentedControl(items: items)
        let width: CGFloat = 170
        let height: CGFloat = 30
        segmentedControl.frame = CGRect(x: ((300 - width) / 2) + 40, y: 450, width: width, height: height)
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
            label.frame = CGRect(x: ((300 - width) / 2), y: 350, width: width, height: height)
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
        textField.frame = CGRect(x: ((300 - width) / 2) + 40, y: 350, width: width, height: height)
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    let gripSegmentedControl: UISegmentedControl = {
        let items = ["Alle", "Matched", "Unmatched"]
        let segmentedControl = UISegmentedControl(items: items)
        let width: CGFloat = 250
        let height: CGFloat = 30
        segmentedControl.frame = CGRect(x: (300 - width) / 2, y: 400, width: width, height: height)
        segmentedControl.selectedSegmentIndex = 0 // Standardmäßig ausgewählte Option
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        
        setFilterSettings()
        
        bpmTextField1.text = bpmFilterSettings[1]
        bpmTextField2.text = bpmFilterSettings[2]
        interpretTextField.text = filterSettings[4]
        gripTextField.text = filterSettings[5]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        if dateFilterSettings[1] == "" {
            dateFilterSettings[1] = formatter.string(from: Date())
        }
        if dateFilterSettings[2] == "" {
            dateFilterSettings[2] = formatter.string(from: Date())
        }
        
        customView.center = view.center
        view.addSubview(customView)
        view.addSubview(filterButton)
        
        rangeSlider.delegate = self
        bpmTextField1.delegate = self
        bpmTextField2.delegate = self
        interpretTextField.delegate = self
        gripTextField.delegate = self
        
        customView.addSubview(filterLabel)
        customView.addSubview(mediaSegmentedControl)

        customView.addSubview(dateLabel1)
        customView.addSubview(dateToggle)
        customView.addSubview(dateLabel2)
        customView.addSubview(calendarPicker1)
        customView.addSubview(dateLabel3)

        customView.addSubview(calendarPicker2)
        customView.addSubview(dateOffView)

        customView.addSubview(bpmLabel1)
        customView.addSubview(bpmToggle)
        
        customView.addSubview(rangeSlider)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: rangeSlider,
                               attribute: .leading,
                               relatedBy: .equal,
                               toItem: customView,
                               attribute: .leading,
                               multiplier: 1.0,
                               constant: 5),
            NSLayoutConstraint(item: rangeSlider,
                               attribute: .trailing,
                               relatedBy: .equal,
                               toItem: customView,
                               attribute: .trailing,
                               multiplier: 1.0,
                               constant: -133),
            NSLayoutConstraint(item: rangeSlider,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: customView,
                               attribute: .top,
                               multiplier: 1.0,
                               constant: 230),
            NSLayoutConstraint(item: rangeSlider,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1.0,
                               constant: 50)
        ])
        
        customView.addSubview(bpmTextField1)
        customView.addSubview(bpmTextField2)
        customView.addSubview(bpmLabel3)
        customView.addSubview(bpmOffView)

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
    }
    
    @objc func dateToggleChanged(_ sender: UISwitch) {
        dateOffView.isHidden = sender.isOn
        dateFilterSettings[0] = String(sender.isOn)
    }
    
    @objc func bpmToggleChanged(_ sender: UISwitch) {
        bpmOffView.isHidden = sender.isOn
        bpmFilterSettings[0] = String(sender.isOn)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        if sender == calendarPicker1 {
            let date = sender.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let dateString = dateFormatter.string(from: date)
            dateFilterSettings[1] = dateString
        } else {
            let date = sender.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let dateString = dateFormatter.string(from: date)
            dateFilterSettings[2] = dateString
        }
    }

    @objc func segmentedControlValueChanged(sender: UISegmentedControl) {
        // Verarbeite die ausgewählte Option
        let selectedIndex = sender.selectedSegmentIndex
        let selectedOption = sender.titleForSegment(at: selectedIndex)
        
        if sender == mediaSegmentedControl {
            filterSettings[0] = String(sender.selectedSegmentIndex)
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
        gripSegmentedControl.selectedSegmentIndex = Int(filterSettings[6])!
        handSegmentedControl.selectedSegmentIndex = Int(filterSettings[7])!
    }
    
    func rangeChangeFinished(event: RangeUISliderChangeFinishedEvent) {
        //print("\(event.minValueSelected) -  \(event.maxValueSelected) - identifier: \(event.slider.identifier)")
    }
    func rangeIsChanging(event: RangeUISliderChangeEvent) {
        bpmFilterSettings[1] = String(Int(event.minValueSelected))
        bpmFilterSettings[2] = String(Int(event.maxValueSelected))
        bpmTextField1.text = bpmFilterSettings[1]
        bpmTextField2.text = bpmFilterSettings[2]

        print("\(event.minValueSelected) -  \(event.maxValueSelected) - identifier: \(event.slider.identifier)")
    }
}

extension FilterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == bpmTextField1 {
            bpmFilterSettings[1] = String(textField.text!)
            rangeSlider.defaultValueLeftKnob = CGFloat(Int(bpmFilterSettings[1])!)
        } else if textField == bpmTextField2 {
            bpmFilterSettings[2] = String(textField.text!)
            rangeSlider.defaultValueRightKnob = CGFloat(Int(bpmFilterSettings[2])!)
        } else if textField == interpretTextField {
            filterSettings[4] = String(textField.text!)
        } else {
            filterSettings[5] = String(textField.text!)
        }
        textField.resignFirstResponder()
        return true
    }
}
