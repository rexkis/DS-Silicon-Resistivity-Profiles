//
//  VCNotifications.swift
//  SiH_TT
//
//  Created by Igor Kutovoy on 25/11/2018.
//  Copyright © 2018 Igor Kutovoy. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let nDopants = Notification.Name("dopants")
    static let nCalcType = Notification.Name("calcType")
    static let nClearResValues = Notification.Name("clearResValues")
    static let nChartTypeString = Notification.Name("chartTypeString")
    static let nSettingValue = Notification.Name("settingValue")
    static let nParameterIndex = Notification.Name("parameterIndex")
}

extension ViewController {
    func addObservers() {
        
        // currentDopants Notification from InputView: defines output labels text
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.manageCurrentDopants(notification:)), name: .nDopants, object: nil)
        
        // CalcType Notification from InputView: defines resultLabel.attributedStringValue
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.manageCalcType(notification:)), name: .nCalcType, object: nil)
        
        // currentDopants Notification from InputView: defines output labels text
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.clearResValues(notification:)), name: .nClearResValues, object: nil)
        
        // chartTypeName Notification from ChartView: defines output labels text
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.getChangedChartTypeName(notification:)), name: .nChartTypeString, object: nil)
        
        // Chart Layout Settings Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.manageSettings(notification:)), name: .nSettingValue, object: nil)
    }
    
    func manageCurrentDopants(notification:Notification) {
        if firstRun != true {
            clearGraphView()
        }
        //        currentDopants = notification.userInfo?["currentDopants"] as! [String]
        if let dopants = notification.userInfo?["currentDopants"] as! [String]? {
            currentDopants = dopants
        }

    }
    // Changes depended on calcType + Clear GraphView & TableView
    func manageCalcType(notification:Notification) {
        if firstRun != true {
            clearGraphView()
        }
        let calcTypeString = notification.userInfo?["calcTypeString"] as! String
        calcType = calcTypeString == "CustomR" ? .customR : .customDD
//        if let type = notification.userInfo?["calcTypeString"] as! String? {
//            calcType = type == "CustomR" ? .customR : .customDD
//        }
        
    }
    // Clear resultView calculated values when text fields in input view are editing + Clear GraphView & TableView
    func clearResValues(notification:Notification) {
        if firstRun != true {
            clearGraphView()
        }
        resultView.clearFields()
    }
    // Get chartTypeName from notification via chartTypeString
    func getChangedChartTypeName(notification:Notification) {
        let chartTypeString = notification.userInfo?["chartTypeString"] as! String
        switch chartTypeString {
        case "Dopant Densities" :
            chartTypeName = .DD
        case "Net Density" :
            chartTypeName = .Net
        case "Resistivity" :
            chartTypeName = .Res
        case "Compensation" :
            chartTypeName = .Cmp
        default: ()
        }
        showGraphView()
    }
    // Managing function for "settingValue" notification from WindowController
    func manageSettings(notification:Notification) {
        let settingFlag = notification.userInfo?["settingFlag"] as! Bool
        let settingType = notification.userInfo?["settingType"] as! String
        
        switch settingType {
        case "xGrid":
            graphView.xGridEnabled = settingFlag
        case "yGrid":
            graphView.yGridEnabled = settingFlag
        case "color":
            graphView.fillPNAreas = settingFlag
        case "tracking":
            graphView.trackEnabled = settingFlag
        case "fullScreen":
            //            self.view.enterFullScreenMode((self.view.window?.screen)!, withOptions: [ NSFullScreenModeAllScreens: String.self])
            left.isHidden = settingFlag
//            resView.isHidden = settingFlag
        case "toPDF":
            graphView.toPDF()
        default: ()
        }
    }
}
