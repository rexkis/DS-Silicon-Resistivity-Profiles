
//
//  WindowExtensions.swift
//  SiH_TT
//
//  Created by Igor Kutovoy on 05.05.17.
//  Copyright © 2017 Igor Kutovoy. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
extension WindowController {
    
////    Save state of controls both in Tool- and Touchbar
//    func saveChartSettings(settingsStateArray:[Int], settingFlag:Bool, settingType:String) {
//        userDefaults.set(settingsStateArray, forKey: "settingsStateArray")
//        NotificationCenter.default.post(name: .nSettingValue, object: self, userInfo: ["settingFlag": settingFlag, "settingType" : settingType])
//    }
    
    func getSavedParameter() {
        let parameterIndex = userDefaults.integer(forKey: "parameterIndex")
        parameterPopUp.selectItem(at: parameterIndex)
        seg.selectedSegment = parameterIndex
    }
    
    func getSavedChartLayout() {
        manageToolbar()
        manageTouchbar()
    }
    private func manageToolbar() {
        for i in 0..<toolbarSwitchers.count {
            toolbarSwitchers[i].state = NSControl.StateValue(rawValue: savedChartSettings[i])
        }
    }
    private func manageTouchbar() {
        for i in 0..<3 {
            // Положение переключателей
            touchbarSwitchers[i].state = NSControl.StateValue(rawValue: savedChartSettings[i])
            // Надписи на кнопках в TouchBar
            switch i {
            case 0 :
                touchbarSwitchers[i].title = savedChartSettings[i] == 1 ? "X-Grid ON" : "X-Grid OFF"
            case 1:
                touchbarSwitchers[i].title = savedChartSettings[i] == 1 ? "Y-Grid ON" : "Y-Grid OFF"
            case 2:
                touchbarSwitchers[i].title = savedChartSettings[i] == 1 ? "Color ON " : "Color OFF"
            default: ()
            }
            // Цвет кнопок
            touchbarSwitchers[i].bezelColor = savedChartSettings[i] == 1 ? NSColor.blue : NSColor.red
        }
    }
    
    func styleTouchBarItems() {
        // Styling TouchBar
        styleTouchBarButton(button: parameterPopover.view as? NSButton,color: NSColor.purple)
        styleTouchBarButton(button: chartPopover.view as? NSButton,color: NSColor.orange)
        styleTouchBarButton(button: saveTouchItem.view as? NSButton,color: NSColor.red)
        
        seg.wantsLayer = true
        seg.selectedSegmentBezelColor = NSColor.blue
        seg.layer?.cornerRadius = 10.0
        seg.layer?.borderColor = NSColor.white.cgColor
        seg.layer?.borderWidth = 1.0
    }
    
    func styleTouchBarButton(button: NSButton?,color: NSColor) {
        button?.bezelColor = color
        button?.wantsLayer = true
        button?.layer?.cornerRadius = 10.0
        button?.layer?.borderColor = NSColor.white.cgColor
        button?.layer?.borderWidth = 1.0
    }
}

@available(OSX 10.12.2, *)
extension WindowController {
    
    // 1. Getting Parameter to show in Chart from toolbar and touchbar. Save parameter index to userDefaults and send NSNotification.Name(rawValue: "parameterIndex"). Also save to userDefaults value of chartTypeName (taken from sender title/label). Send NSNotification.Name(rawValue: "chartTypeString").
    func getParameterFromTool(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        userDefaults.set(index, forKey: "parameterIndex")
        NotificationCenter.default.post(name: .nParameterIndex, object: self, userInfo: ["parameterIndex":index])
        
        userDefaults.set(sender.title, forKey: "chartTypeName")
        NotificationCenter.default.post(name: .nChartTypeString, object: self, userInfo: ["chartTypeString":sender.title])
        seg.selectedSegment = sender.indexOfSelectedItem // Change touchbar segmented control selection
    }
    func getParameterFromTouch(sender: NSSegmentedControl) {
        let index = sender.selectedSegment
        userDefaults.set(index, forKey: "parameterIndex")
        NotificationCenter.default.post(name: .nParameterIndex, object: self, userInfo: ["parameterIndex":index])
        parameterPopUp.selectItem(at: index)
        
        let chartTypeString = sender.label(forSegment: index)
        userDefaults.set(chartTypeString, forKey: "chartTypeName")
        NotificationCenter.default.post(name: .nChartTypeString, object: self, userInfo: ["chartTypeString":chartTypeString ?? "Dopant Densities"])
    }
    
    
    func getLayoutFromTool(sender: NSButton) {
        let currentState = sender.state.rawValue
        settingFlag = currentState == 0 ? false : true
        switch sender.title {
        case "X-Grid":
            settingType = "xGrid"
            btnXGrid.state = sender.state
            btnXGrid.title = currentState == 1 ? "X-Grid ON" : "X-Grid OFF"
            btnXGrid.bezelColor = currentState == 1 ? NSColor.blue : NSColor.red
        case "Y-Grid":
            settingType = "yGrid"
            btnYGrid.state = sender.state
            btnYGrid.title = currentState == 1 ? "Y-Grid ON" : "Y-Grid OFF"
            btnYGrid.bezelColor = currentState == 1 ? NSColor.blue : NSColor.red
        case "Color PN Areas":
            settingType = "color"
            btnColor.state = sender.state
            btnColor.title = currentState == 1 ? "Color ON " : "Color OFF"
            btnColor.bezelColor = currentState == 1 ? NSColor.blue : NSColor.red
        case "Tracking":
            settingType = "tracking"
            btnTracking.state = sender.state
            btnTracking.title = currentState == 1 ? "Tracking ON " : "Tracking OFF"
            btnTracking.bezelColor = currentState == 1 ? NSColor.blue : NSColor.red
        case "Full Screen":
            settingType = "fullScreen"
            btnFullScreen.state = sender.state
            btnFullScreen.title = currentState == 1 ? "Full Screen ON" : "Full Screen OFF"
            btnFullScreen.bezelColor = currentState == 1 ? NSColor.blue : NSColor.red
        case "Save to PDF":
            settingType = "toPDF"
            settingFlag = true
        default: ()
        }
    }
    func getLayoutFromTouch(sender: NSButton) {
        let currentState = sender.state.rawValue
        settingFlag = currentState == 0 ? false : true
        switch sender {
        case btnXGrid:
            sender.title = currentState == 1 ? "X-Grid ON " : "X-Grid OFF"
            chkXGrid.state = sender.state
            settingType = "xGrid"
        case btnYGrid:
            sender.title = currentState == 1 ? "Y-Grid ON " : "Y-Grid OFF"
            chkYGrid.state = sender.state
            settingType = "yGrid"
        case btnColor:
            sender.title = currentState == 1 ? "Color ON " : "Color OFF"
            chkColor.state = sender.state
            settingType = "color"
        case btnTracking:
            sender.title = currentState == 1 ? "Tracking ON " : "Tracking OFF"
            chkTracking.state = sender.state
            settingType = "tracking"
        case btnFullScreen:
            sender.title = currentState == 1 ? "Full Screen ON " : "Full Screen OFF"
            chkFullScreen.state = sender.state
            settingType = "fullScreen"
        case saveButton:
            settingType = "toPDF"
            settingFlag = true
        default: ()
        }
        if sender != saveButton {
            sender.bezelColor = currentState == 1 ? NSColor.blue : NSColor.red
        }
    }
}

