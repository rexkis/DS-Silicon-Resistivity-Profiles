//
//  InputView.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 15.12.16.
//  Copyright © 2016 Igor Kutovoy. All rights reserved.
//

import Cocoa

class InputView: NSView {
    
    // Initialize XIB in InputView
    @IBOutlet var contentView: NSView!
    
    // MARK: Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: "InputView"), owner: self, topLevelObjects: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(content)
        
    }
    
    // UI
    @IBOutlet weak var radioCustomR: NSButton!
    @IBOutlet weak var radioCustomDD: NSButton!
    @IBAction func rbTapped(_ sender: NSButton) {
        switch sender.title {
        case "Custom Resistivities":
            calcType = .customR
        default:
            calcType = .customDD
        }
    }
    
    @IBOutlet weak var dopantsCombo: NSComboBox!
    @IBAction func chooseDopants(_ sender: NSComboBox) {
        let selectedIndex = sender.indexOfSelectedItem
        if selectedIndex != -1 {
            currentDopants = Constants.dopantsArray[selectedIndex]
        }
    }
    
    @IBOutlet weak var inputTitleLabel: NSTextField!
    @IBOutlet weak var inpLabel0: NSTextField!
    @IBOutlet weak var inpLabel1: NSTextField!
    @IBOutlet weak var inpLabel2: NSTextField!
    var inputLabelsArray:[NSTextField] {
        return [inpLabel0,inpLabel1,inpLabel2]
    }
    
    @IBOutlet weak var inputLabelsStackView: NSStackView!
    @IBOutlet weak var inputValuesStackView: NSStackView!
    @IBOutlet weak var tf0: NSTextField!
    @IBOutlet weak var tf1: NSTextField!
    @IBOutlet weak var tf2: NSTextField!
    var tfArray:[NSTextField] {
        return [tf0,tf1,tf2]
    }

    // MARK: Parameters from UI
    var calcType:CalcType = .customR {
        didSet {
            clearFields()
            tf0.becomeFirstResponder()
            sendCalcTypeNotification()
            manageTitlesAndControls()
        }
    }
    
    var currentDopants: [String]  = [] {
        didSet {
            clearFields()
            tf0.becomeFirstResponder()
            let hider = currentDopants.count == 2 ? true : false
            _ = [inpLabel2,tf2].map{$0?.isHidden = hider}
            sendCurrentDopantsNotification()
            currentDopantsIndex = findDopantsIndex(dopants: self.currentDopants)!
        }
    }

    var currentDopantsIndex:Int = 0
    let decimalSeparator = NSLocale(localeIdentifier: "US").decimalSeparator as String
    var goodSet:[String] {
        return ["0","1","2","3","4","5","6","7","8","9","0","E","e",decimalSeparator]
    }
    
    override func viewWillDraw() {
        
        for tf in tfArray {
            tf.delegate = self
        }
        dopantsCombo.dataSource = self
        dopantsCombo.usesDataSource = true
        dopantsCombo.delegate = self
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        dopantsCombo.selectItem(at: currentDopantsIndex)
        tf0.nextKeyView = tf1
        tf1.nextKeyView = tf2
        tf2.nextKeyView = tf0
    }
    
    func findDopantsIndex(dopants:[String]) -> Int? {
        for (index,value) in Constants.dopantsArray.enumerated() {
            if value == currentDopants {return index}
        }
        return nil
    }
    func manageTitlesAndControls() {
        let inputLabels = Titles(dopants: currentDopants, calcType: calcType).setInputLabels()
        for i in 0..<currentDopants.count {
            inputLabelsArray[i].stringValue = inputLabels[i]
        }
        
        let inputTitle = Titles(dopants: currentDopants, calcType: calcType).setInputTitle()
        inputTitleLabel.attributedStringValue = inputTitle
        
        switch calcType {
        case .customR:
            radioCustomR.state = NSControl.StateValue(rawValue: 1)
        default:
            radioCustomDD.state = NSControl.StateValue(rawValue: 1)
        }
    }
    
    // POST Notifications for calcType (rawValue: "calcType") and currentDopants (rawValue: "dopants")
    func sendCalcTypeNotification() {
        NotificationCenter.default.post(name: .nCalcType, object: self, userInfo: ["calcTypeString":calcType.rawValue])
    }
    func sendCurrentDopantsNotification() {
        NotificationCenter.default.post(name: .nDopants, object: self, userInfo: ["currentDopants":currentDopants])
    }
    func clearFields() {
        tfArray.forEach{$0.stringValue = ""}
    }
}





