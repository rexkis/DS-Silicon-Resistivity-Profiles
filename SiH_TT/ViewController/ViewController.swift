//
//  ViewController.swift
//  SiH_TT
//
//  Created by Igor Kutovoy on 03.05.17.
//  Copyright © 2017 Igor Kutovoy. All rights reserved.
//  GIT created 15.01.2019. Pull check

import Cocoa

// For Binding
// Binding AC with Data 1. Создаем класс ResData с параметрами, который будут отображаться в NSTableView
@objc(ResData)
class ResData: NSObject {
    @objc dynamic var sf : String = ""
    @objc dynamic var res: String = ""
    
    init(sf : String, res: String) {
        self.sf = sf
        self.res = res
    }
}

enum ChartTypeName:String {
    case DD  = "Dopant Density"
    case Net = "Net Density"
    case Res = "Resistivity"
    case Cmp = "Compensation"
}
enum CalcType:String {
    case customR = "CustomR"
    case customDD = "CustomDD"
}

class MainParams {
    static let shared = MainParams()
    
    var currentDopants: [String]?
    var calcType:CalcType?
}

@objcMembers
class ViewController: NSViewController {
    
    // Binding: ArrayController
    // Binding AC with Data: все как в https://www.youtube.com/watch?v=VfVYX7nO9dQ
    @objc dynamic var resData:[ResData] = []
    @IBOutlet var resAC: NSArrayController!
    @IBOutlet weak var tableView: NSTableView!
    
    // User Interface & controls
    @IBOutlet weak var mainStack: NSStackView!
    // mainStack consists of left part:
    @IBOutlet weak var left: NSStackView!
    @IBOutlet weak var inputView: InputView!
    @IBOutlet weak var resultView: ResultView!
    // with button
    @IBOutlet weak var calcButton: NSButton!
    // and with right part:
    @IBOutlet weak var right: NSStackView!
    @IBOutlet weak var graphView: GraphView!
    // Stack for Resistivity Data in tableView
    @IBOutlet weak var resView: NSStackView!
    
    //var calculationSuccess:Bool = false
    func makeResData() -> [ResData] {
        var md: [ResData] = [ResData(sf: String(format: "%4.2f",Constants.g[0]), res:String(format: "%4.2f",ingotData!.resDist[0]))]
        for i in 1 ..< Constants.g.count {
            md += [ResData(sf: String(format: "%4.2f",Constants.g[i]),
                           res: String(format: "%4.2f",ingotData!.resDist[i]))]
        }
        return md
    }

    
    // Class instances
    var stringMaker = StringMaker()
    // UI Logic variable for the first run
    var firstRun:Bool = true
    
    // Variables from UI
    // Main Parameters
    var currentDopants = [String]() {
        didSet {
            checkpoints = currentDopants.count == 2 ? "[0.05,0.85]" : "[0.05,0.50,0.85]"
            // Hiding controls in resultView. InputView does it "himself"
            let hider = currentDopants.count == 2 ? true : false
            _ = [resultView.resultLabel2,resultView.res2].map{$0?.isHidden = hider}
            setInputResultLabels()
            resultView.currentDopants = currentDopants
        }
    }
    var calcType:CalcType = .customR {
        didSet {
            let calcIdx = calcType == .customR ? 0 : 1
            inputView.inputTitleLabel.attributedStringValue = stringMaker.inputTitleLabelsText[calcIdx]
            resultView.resultLabel.attributedStringValue = stringMaker.resultTitleLabelsText[calcIdx]
            setInputResultLabels()
            resultView.calcType = calcType
        }
    }
    
    // Variables used in further calculations
    var checkpoints:String = ""
    var gExtraLabels:[String] {
        return currentDopants.count == 2 ? ["g = 0.05", "g = 0.85"] : ["g = 0.05", "g = 0.50", "g = 0.85"]
    }
    var dopantsDescriptionArray:[String] {
        var arr = [String]()
        for i in 0..<currentDopants.count {
            arr.append(Constants.dopantsDict[currentDopants[i]]!.description)
        }
        return arr
    }
    
    // Computed properties
    var initConcs: [Double] = []
    var initConcsProfile = [Double]()
    
    var resistivityProfile = [Double]()
    var checkPointsResistivities = [Double]()
    
    let allowedDDRange = (1e14...1e19)  // For at/cm3 unit
    let allowedResRange = (0.01...100)
    
    var feedstock = Feedstock(currentDopants: ["B","P"], inputFields: [1.0,1.0])
    var ingotData:Distributions?
    
    
    // UI Controls Actions
    // for calcButton
    @IBAction func calcButtonTapped(_ sender: NSButton) {
        guard getFieldCheck() else { return }
        guard getCalcCorrect() else { return }
    }
    
    func getFieldCheck() ->Bool {
        do {
            try checkFields()
        } catch AppErrors.notConvertible {
            ErrorAlert("Empty Field or Not convertible to Double!", alertMsg: AppErrors.notConvertible.description)
            return false
        } catch AppErrors.outOfRangeDD {
            ErrorAlert("Value out of Allowed Range!", alertMsg: AppErrors.outOfRangeDD.description)
            return false
        } catch AppErrors.outOfRangeRes {
            ErrorAlert("Value out of Allowed Range!", alertMsg: AppErrors.outOfRangeRes.description)
            return false
        } catch { print("Unknown error!")}
        return true
    }
    func getCalcCorrect() -> Bool {
        do {
            try calculate()
        } catch AppErrors.noSolution {
            ErrorAlert("No Solution! Re-Enter Resistivity Values!",alertMsg: AppErrors.noSolution.description)
            return false
        } catch {
            print("Unknown error!")
        }
        return true
    }
    
    // CHART
    var chartTypeName:ChartTypeName = .DD {
        didSet {graphView.chartTypeName = chartTypeName}
    }
    func setChartSubtitles() {
        switch calcType {
        case .customR:
            graphView.customLabelText = stringMaker.chartResString(calcType: calcType, checkpoints: checkpoints,resProfile: resistivityProfile)
            graphView.calculatedLabelText = stringMaker.chartDDString(calcType: calcType, dopants: currentDopants, concs: initConcs)
        case .customDD:
            graphView.customLabelText = stringMaker.chartDDString(calcType: calcType, dopants: currentDopants, concs: initConcsProfile)
            graphView.calculatedLabelText = stringMaker.chartResString(calcType: calcType, checkpoints: checkpoints, resProfile: checkPointsResistivities)
        }
    }      

    override func viewDidLayout() {
        makeBorders()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        resView.isHidden = false
        
////        Debug: Remove all UserDefaults data. !!! All OK, but chart for Resistivity, not for Dopant Densities. Correct later!
//        let domain = Bundle.main.bundleIdentifier!
//        UserDefaults.standard.removePersistentDomain(forName: domain)
        
        // Get ALL (not only this App) key/value pars in userDefaults
//        for (key, value) in userDefaults.dictionaryRepresentation() {
//            Swift.print("\(key) = \(value) \n")
//        }
        
        // Это можно будет перенести в GraphView
        if let settingsState = userDefaults.value(forKey: "settingsStateArray") as? [Int] {
            graphView.xGridEnabled = settingsState[0] == 0 ? false : true
            graphView.yGridEnabled = settingsState[1] == 0 ? false : true
            graphView.fillPNAreas = settingsState[2] == 0 ? false : true
        }

        addObservers()
        setInitialState()

//        print("ResData[75]: sf = \(resData[75].sf), res = \(resData[75].res)")
        
//        let appDomain = Bundle.main.bundleIdentifier!
//        let allKeys = userDefaults.dictionaryRepresentation().keys
//        Swift.print(allKeys)
//        Swift.print("appDomain = \(appDomain)")
//        
//        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
//        let folder = path[0]
//        NSLog("Your NSUserDefaults are stored in this folder: \(folder)/Preferences")
//        Swift.print("appDomain = \(appDomain)")
    }
    
    func findDopantsIndex(dopants:[String]) -> Int? {
        for (index,value) in Constants.dopantsArray.enumerated() {
            if value == currentDopants {return index}
        }
        return nil
    }
    
    func setInputResultLabels() {
        switch calcType {
        case .customDD:
            for i in 0..<currentDopants.count {
                resultView.resultLabelsArray[i].stringValue = String(gExtraLabels[i])
                inputView.inputLabelsArray[i].stringValue = dopantsDescriptionArray[i]
                
            }
        case .customR:
            for i in 0..<currentDopants.count {
                resultView.resultLabelsArray[i].stringValue = dopantsDescriptionArray[i]
                inputView.inputLabelsArray[i].stringValue = String(gExtraLabels[i])
            }
        }
    }

    func makeBorders() {
        let views:[NSView] = [inputView,resultView,graphView,resView]
        for v in views {
            v.wantsLayer = true
            v.layer?.borderWidth = 1.0
            v.layer?.borderColor  = NSColor.black.cgColor
            v.layer?.cornerRadius = 10.0
        }
    }
    
    func clearGraphView() {
        graphView.needsToRedraw = true
        graphView.needsDisplay = true
        resData = []
    }
    func showGraphView() {
        graphView.needsToRedraw = false
        graphView.needsDisplay = true
    }

}

