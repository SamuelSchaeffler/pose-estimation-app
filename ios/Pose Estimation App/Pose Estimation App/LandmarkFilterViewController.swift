//
//  LandmarkFilterViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 14.12.23.
//

import UIKit

class LandmarkFilterViewController: UIViewController {
    
    let filter = Filter.shared
    
    let pickerData = ["1/10s", "1/20s", "1/30s", "1/40s", "1/50s", "1/60s"]
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.adjustsImageWhenHighlighted = false
        button.setTitle("zurück", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        let buttonWidth: CGFloat = UIScreen.main.bounds.size.width / 5
        let buttonHeight: CGFloat = 30
        button.frame = CGRect(x: 20, y: 50, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = 15
        return button
    }()
    
    let movingAverageLabel1: UILabel = {
        let label = UILabel()
        label.text = "Gleitender Durchschnitt"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 100, width: width, height: height)
        return label
    }()
    
    lazy var movingAverageToggle: UISwitch = {
        let toggle = UISwitch()
        let width: CGFloat = 150
        let height: CGFloat = 30
        toggle.layer.frame = CGRect(x: 285, y: 100, width: width, height: height)
        toggle.addTarget(self, action: #selector(movingAverageToggleChanged(_:)), for: .valueChanged)
        toggle.isOn = filter.landmarkFilterStates[0]
        return toggle
    }()
    
    let movingAverageLabel2: UILabel = {
        let label = UILabel()
        label.text = "Fenstergröße:"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 140, width: width, height: height)
        return label
    }()
    
    let movingAverageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "0"
        textField.keyboardType = .numbersAndPunctuation
        textField.returnKeyType = .done
        textField.backgroundColor = .systemGray6
        textField.textAlignment = .center
        let width: CGFloat = 50
        let height: CGFloat = 30
        textField.frame = CGRect(x: 210 , y: 140, width: width, height: height)
        textField.layer.cornerRadius = 8
        textField.isUserInteractionEnabled = true
        return textField
    }()
    
    lazy var  movingAverageOffView: UIView = {
        let view = UIView()
        view.layer.frame = CGRect(x: 30, y: 80, width: 240, height: 100)
        view.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        view.isHidden = filter.landmarkFilterStates[0]
        return view
    }()
    
    let pt1FilterLabel1: UILabel = {
        let label = UILabel()
        label.text = "PT1-Filter"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 200, width: width, height: height)
        return label
    }()
    
    lazy var pt1FilterToggle: UISwitch = {
        let toggle = UISwitch()
        let width: CGFloat = 150
        let height: CGFloat = 30
        toggle.layer.frame = CGRect(x: 285, y: 200, width: width, height: height)
        toggle.addTarget(self, action: #selector(pt1FilterToggleChanged(_:)), for: .valueChanged)
        toggle.isOn = filter.landmarkFilterStates[1]
        return toggle
    }()
    
    let pt1FilterLabel2: UILabel = {
        let label = UILabel()
        label.text = "Grenzfrequenz:"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 240, width: width, height: height)
        return label
    }()
    
    let pt1FilterTextField1: UITextField = {
        let textField = UITextField()
        textField.placeholder = "0"
        textField.keyboardType = .numbersAndPunctuation
        textField.returnKeyType = .done
        textField.backgroundColor = .systemGray6
        textField.textAlignment = .center
        let width: CGFloat = 50
        let height: CGFloat = 30
        textField.frame = CGRect(x: 210 , y: 240, width: width, height: height)
        textField.layer.cornerRadius = 8
        textField.isUserInteractionEnabled = true
        return textField
    }()
    
    let pt1FilterLabel3: UILabel = {
        let label = UILabel()
        label.text = "Abtastzeit:"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 280, width: width, height: height)
        return label
    }()
    
    let pt1FilterTextField2: UIPickerView = {
        let textField = UIPickerView()
        let width: CGFloat = 75
        let height: CGFloat = 50
        textField.frame = CGRect(x: 225 , y: 270, width: width, height: height)
        textField.isUserInteractionEnabled = true
        return textField
    }()
    
    lazy var  pt1FilterOffView: UIView = {
        let view = UIView()
        view.layer.frame = CGRect(x: 30, y: 190, width: 262, height: 200)
        view.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        view.isHidden = filter.landmarkFilterStates[1]
        return view
    }()
    
    let pt1FilterLabel4: UILabel = {
        let label = UILabel()
        label.text = "FPS"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 160, y: 280, width: width, height: height)
        return label
    }()
    
    let pt1FilterCheckBox: UIButton = {
        let checkBox = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        checkBox.setImage(UIImage(systemName: "square.fill", withConfiguration: symbolConfiguration), for: .normal)
        checkBox.setImage(UIImage(systemName: "checkmark.square.fill", withConfiguration: symbolConfiguration), for: .selected)
        checkBox.frame = CGRect(x: 190, y: 275, width: 40, height: 40)
        checkBox.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        return checkBox
    }()
    
    let  pt1FilterCheckBoxOffView: UIView = {
        let view = UIView()
        view.layer.frame = CGRect(x: 225, y: 270, width: 85, height: 60)
        view.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()
    
    let kalmanFilterLabel1: UILabel = {
        let label = UILabel()
        label.text = "Kalman-Filter"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 340, width: width, height: height)
        return label
    }()
    
    lazy var kalmanFilterToggle: UISwitch = {
        let toggle = UISwitch()
        let width: CGFloat = 150
        let height: CGFloat = 30
        toggle.layer.frame = CGRect(x: 285, y: 340, width: width, height: height)
        toggle.addTarget(self, action: #selector(kalmanFilterToggleChanged(_:)), for: .valueChanged)
        toggle.isOn = filter.landmarkFilterStates[2]
        return toggle
    }()
    
    let kalmanFilterLabel2: UILabel = {
        let label = UILabel()
        label.text = "Prozessrauschen:"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 380, width: width, height: height)
        return label
    }()
    
    let kalmanFilterTextField1: UITextField = {
        let textField = UITextField()
        textField.placeholder = "0"
        textField.keyboardType = .numbersAndPunctuation
        textField.returnKeyType = .done
        textField.backgroundColor = .systemGray6
        textField.textAlignment = .center
        let width: CGFloat = 50
        let height: CGFloat = 30
        textField.frame = CGRect(x: 210 , y: 380, width: width, height: height)
        textField.layer.cornerRadius = 8
        textField.isUserInteractionEnabled = true
        return textField
    }()
    
    let kalmanFilterLabel3: UILabel = {
        let label = UILabel()
        label.text = "Messrauschen:"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 420, width: width, height: height)
        return label
    }()
    
    let kalmanFilterTextField2: UITextField = {
        let textField = UITextField()
        textField.placeholder = "0"
        textField.keyboardType = .numbersAndPunctuation
        textField.returnKeyType = .done
        textField.backgroundColor = .systemGray6
        textField.textAlignment = .center
        let width: CGFloat = 50
        let height: CGFloat = 30
        textField.frame = CGRect(x: 210 , y: 420, width: width, height: height)
        textField.layer.cornerRadius = 8
        textField.isUserInteractionEnabled = true
        return textField
    }()
    
    let kalmanFilterLabel4: UILabel = {
        let label = UILabel()
        label.text = "anfängl. Schätzfehler:"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 460, width: width, height: height)
        return label
    }()
    
    let kalmanFilterTextField3: UITextField = {
        let textField = UITextField()
        textField.placeholder = "0"
        textField.keyboardType = .numbersAndPunctuation
        textField.returnKeyType = .done
        textField.backgroundColor = .systemGray6
        textField.textAlignment = .center
        let width: CGFloat = 50
        let height: CGFloat = 30
        textField.frame = CGRect(x: 210 , y: 460, width: width, height: height)
        textField.layer.cornerRadius = 8
        textField.isUserInteractionEnabled = true
        return textField
    }()
    
    lazy var kalmanFilterOffView: UIView = {
        let view = UIView()
        view.layer.frame = CGRect(x: 30, y: 330, width: 240, height: 180)
        view.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        view.isHidden = filter.landmarkFilterStates[2]
        return view
    }()
    
    let shiftLandmarksLabel1: UILabel = {
        let label = UILabel()
        label.text = "Phasenverschiebung"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 520, width: width, height: height)
        return label
    }()
    
    lazy var shiftLandmarksToggle: UISwitch = {
        let toggle = UISwitch()
        let width: CGFloat = 150
        let height: CGFloat = 30
        toggle.layer.frame = CGRect(x: 285, y: 520, width: width, height: height)
        toggle.addTarget(self, action: #selector(shiftLandmarksToggleChanged(_:)), for: .valueChanged)
        toggle.isOn = filter.landmarkFilterStates[3]
        return toggle
    }()
    
    let shiftLandmarksLabel2: UILabel = {
        let label = UILabel()
        label.text = "Verschiebungswert:"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 560, width: width, height: height)
        return label
    }()
    
    let shiftLandmarksTextField1: UITextField = {
        let textField = UITextField()
        textField.placeholder = "0"
        textField.keyboardType = .numbersAndPunctuation
        textField.returnKeyType = .done
        textField.backgroundColor = .systemGray6
        textField.textAlignment = .center
        let width: CGFloat = 50
        let height: CGFloat = 30
        textField.frame = CGRect(x: 210 , y: 560, width: width, height: height)
        textField.layer.cornerRadius = 8
        textField.isUserInteractionEnabled = true
        return textField
    }()
    
    lazy var shiftLandmarksOffView: UIView = {
        let view = UIView()
        view.layer.frame = CGRect(x: 30, y: 510, width: 240, height: 90)
        view.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        view.isHidden = filter.landmarkFilterStates[2]
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        movingAverageTextField.delegate = self
        pt1FilterTextField1.delegate = self
        pt1FilterTextField2.delegate = self
        kalmanFilterTextField1.delegate = self
        kalmanFilterTextField2.delegate = self
        kalmanFilterTextField3.delegate = self
        shiftLandmarksTextField1.delegate = self
        pt1FilterTextField2.dataSource = self
        
        view.addSubview(movingAverageLabel1)
        view.addSubview(movingAverageLabel2)
        view.addSubview(movingAverageTextField)
        view.addSubview(movingAverageOffView)
        view.addSubview(pt1FilterLabel1)
        view.addSubview(pt1FilterLabel2)
        view.addSubview(pt1FilterLabel3)
        view.addSubview(pt1FilterTextField1)
        view.addSubview(pt1FilterTextField2)
        view.addSubview(pt1FilterLabel4)
        view.addSubview(pt1FilterCheckBox)
        view.addSubview(pt1FilterCheckBoxOffView)
        view.addSubview(pt1FilterOffView)
        view.addSubview(kalmanFilterLabel1)
        view.addSubview(kalmanFilterLabel2)
        view.addSubview(kalmanFilterLabel3)
        view.addSubview(kalmanFilterLabel4)
        view.addSubview(kalmanFilterTextField1)
        view.addSubview(kalmanFilterTextField2)
        view.addSubview(kalmanFilterTextField3)
        view.addSubview(kalmanFilterOffView)
        view.addSubview(shiftLandmarksLabel1)
        view.addSubview(shiftLandmarksLabel2)
        view.addSubview(shiftLandmarksTextField1)
        view.addSubview(shiftLandmarksOffView)
        view.addSubview(movingAverageToggle)
        view.addSubview(pt1FilterToggle)
        view.addSubview(kalmanFilterToggle)
        view.addSubview(shiftLandmarksToggle)
        view.addSubview(closeButton)
    }
    
    @objc func closeVC() {
        self.dismiss(animated: true)
    }
    
    @objc func movingAverageToggleChanged(_ sender: UISwitch) {
        movingAverageOffView.isHidden = sender.isOn
        filter.landmarkFilterStates[0] = sender.isOn
    }
    
    @objc func pt1FilterToggleChanged(_ sender: UISwitch) {
        pt1FilterOffView.isHidden = sender.isOn
        filter.landmarkFilterStates[1] = sender.isOn
    }
    
    @objc func kalmanFilterToggleChanged(_ sender: UISwitch) {
        kalmanFilterOffView.isHidden = sender.isOn
        filter.landmarkFilterStates[2] = sender.isOn
    }
    
    @objc func shiftLandmarksToggleChanged(_ sender: UISwitch) {
        shiftLandmarksOffView.isHidden = sender.isOn
        filter.landmarkFilterStates[3] = sender.isOn
    }
    
    @objc func checkboxTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        pt1FilterCheckBoxOffView.isHidden.toggle()
        filter.useFPSSampleTimePT1.toggle()
    }
}
extension LandmarkFilterViewController: UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == movingAverageTextField {
            filter.windowSizeMA = Int(textField.text!) ?? 0
        } else if textField == pt1FilterTextField1 {
            filter.omegaCPT1 = Float(textField.text!) ?? 0
        } else if textField == pt1FilterTextField2 {
            filter.sampleTimePT1 = Float(textField.text!) ?? 0
        } else if textField == kalmanFilterTextField1 {
            filter.qKalman = Float(textField.text!) ?? 0
        } else if textField == kalmanFilterTextField2 {
            filter.rKalman = Float(textField.text!) ?? 0
        } else if textField == kalmanFilterTextField3 {
            filter.initialPKalman = Float(textField.text!) ?? 0
        } else if textField == shiftLandmarksTextField1 {
            filter.landmarkShiftAmount = Int(textField.text!) ?? 0
       }
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let data: [Float] = [(1 / 10), (1 / 20), (1 / 30), (1 / 40), (1 / 50), (1 / 60)]
        print("Ausgewählte Option: \(pickerData[row])")
        filter.sampleTimePT1 = Float(data[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        if let reuseView = view as? UILabel {
            label = reuseView
        } else {
            label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20)
        }
        label.text = pickerData[row]
        return label
    }
}
