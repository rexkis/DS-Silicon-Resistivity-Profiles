//
//  ResultView.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 15.12.16.
//  Copyright © 2016 Igor Kutovoy. All rights reserved.
//

import Cocoa

class ResultView: NSView {

    @IBOutlet var contentView: NSView!
    
    // MARK: Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: "ResultView"), owner: self, topLevelObjects: nil)
        
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.width,.height]
        self.addSubview(content)
        
        self.wantsLayer = true
    }

    // Output Title and labels
    @IBOutlet weak var resultLabel: NSTextField!
    @IBOutlet weak var outputLabelsStackView: NSStackView!
    @IBOutlet weak var resultLabel0: NSTextField!
    @IBOutlet weak var resultLabel1: NSTextField!
    @IBOutlet weak var resultLabel2: NSTextField!
    
    // Output calculated values
    @IBOutlet weak var outputValuesStackView: NSStackView!
    @IBOutlet weak var res0: NSTextField!
    @IBOutlet weak var res1: NSTextField!
    @IBOutlet weak var res2: NSTextField!
    
    // MARK: Properties
    var resultLabelsArray: [NSTextField] {return [resultLabel0,resultLabel1,resultLabel2]}
    var resArray:[NSTextField] { return [res0,res1,res2] }
    
    var calcType:CalcType = .customR {
        didSet {
            clearFields()
        }
    }
    var currentDopants:[String] = [] {
        didSet {
            clearFields()
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
    }

    func clearFields() {
        for element in resArray {
            element.stringValue = ""
        }
    }
}
