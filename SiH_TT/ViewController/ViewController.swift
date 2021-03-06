//
//  ViewController.swift
//  SiH_TT
//
//  Created by Igor Kutovoy on 03.05.17.
//  Copyright © 2017 Igor Kutovoy. All rights reserved.
//  GIT created 15.01.2019. Pull check

import Cocoa

// Binding AC with Data: according to https://www.youtube.com/watch?v=VfVYX7nO9dQ
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

@objcMembers
class ViewController: NSViewController {
    
    // Binding: ArrayController
    // Binding AC with Data
    @objc dynamic var resData:[ResData] = []
    @IBOutlet var resAC: NSArrayController!
    @IBOutlet weak var tableView: NSTableView!
    // Prepare res data for NSTableView
    func makeResData() -> [ResData] {
        var md: [ResData] = [ResData(sf: Constants.gString[0], res:ingotData!.resDist[0].styled)]
        for i in 1 ..< Constants.g.count {
            md += [ResData(sf: Constants.gString[i],
                           res: ingotData!.resDist[i].styled)]
        }
        return md
    }
    
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
    
    // Class instances
    var stringMaker = StringMaker()
    // UI Logic variable for the first run
    var firstRun:Bool = true
    
    // Variables from UI
    // Main Parameters
    var dopantsCount: Int = 0
    var currentDopants = [String]() {
        didSet {
            dopantsCount = currentDopants.count
            if firstRun == true {
                inputView.manageTitlesAndControls()
                resultView.manageTitlesAndControls()
            }
            resultView.currentDopants = currentDopants
        }
    }
    var calcType:CalcType = .customR {
        didSet {
            if firstRun == true {
                inputView.manageTitlesAndControls()
                resultView.manageTitlesAndControls()
            }
            resultView.calcType = calcType
        }
    }
    
    // Variables used in further calculations
    var checkpoints: String {
        return dopantsCount == 2 ? "[0.05,0.85]" : "[0.05,0.50,0.85]"
    }
    
    // Computed properties
    var initConcs: [Double] = []
    var initConcsProfile = [Double]()
    
    var resistivityProfile = [Double]()
    var checkPointsResistivities = [Double]()
    
    let allowedDDRange = (1e14...1e19)  // For at/cm3 unit
    let allowedResRange = (0.01...100)
    
//    var feedstock = Feedstock(currentDopants: ["B","P"], inputFields: [1.0,1.0])
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
            graphView.customLabel.attributedStringValue = stringMaker.chartResString(calcType: calcType, checkpoints: checkpoints,resProfile: resistivityProfile)
            graphView.calculatedLabel.attributedStringValue = stringMaker.chartDDString(calcType: calcType, dopants: currentDopants, concs: initConcs)
        case .customDD:
            graphView.customLabel.attributedStringValue = stringMaker.chartDDString(calcType: calcType, dopants: currentDopants, concs: initConcsProfile)
            graphView.calculatedLabel.attributedStringValue = stringMaker.chartResString(calcType: calcType, checkpoints: checkpoints, resProfile: checkPointsResistivities)
        }
    }      

    override func viewDidLayout() {
        makeBorders()
//        print("viewDidLayout: chartOrigin in window coordinates")
//        print(graphView.convert(GConstants.chartOrigin, to: nil))
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        resView.isHidden = false
        addObservers()
        setInitialState()
        
////        Debug: Remove all UserDefaults data. !!! All OK, but chart for Resistivity, not for Dopant Densities. Correct later!
//        let domain = Bundle.main.bundleIdentifier!
//        UserDefaults.standard.removePersistentDomain(forName: domain)
        
        // Get ALL (not only this App) key/value pars in userDefaults
//        for (key, value) in userDefaults.dictionaryRepresentation() {
//            Swift.print("\(key) = \(value) \n")
//        }

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

