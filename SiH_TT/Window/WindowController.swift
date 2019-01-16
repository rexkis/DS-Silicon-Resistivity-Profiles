//
//  WindowController.swift
//  SiH_TT
//
//  Created by Igor Kutovoy on 03.05.17.
//  Copyright © 2017 Igor Kutovoy. All rights reserved.
//

import Cocoa


let userDefaults = UserDefaults.standard
@available(OSX 10.12.2, *)
class WindowController: NSWindowController {
    
//    var vc:ViewController? {
//        return getContentVC()
//    }
//    func getContentVC() -> ViewController {
//        return window!.contentViewController as! ViewController
//    }
    
    // =============== TOOLBAR ===============
    @IBOutlet weak var toolbar: NSToolbar!
    // Toolbar: parameterPopUp control and Action
    @IBOutlet weak var parameterPopUp: NSPopUpButton!
    @IBAction func parameterPopUpTapped(_ sender: NSPopUpButton) {
        getParameterFromTool(sender)
    }
    // Toolbar: Layout Buttons
    @IBOutlet weak var chkXGrid: NSButton!
    @IBOutlet weak var chkYGrid: NSButton!
    @IBOutlet weak var chkColor: NSButton!
    @IBOutlet weak var chkTracking: NSButton!
    @IBOutlet weak var chkFullScreen: NSButton!
    var toolbarSwitchers:[NSButton] {
        return [chkXGrid, chkYGrid,chkColor]
    }
    var toolbarSwitchersState:[Int] {
        return toolbarSwitchers.map{$0.state.rawValue}
    }
    // Toolbar: Save to PDF Button
    @IBOutlet weak var toPDF: NSButton!
    
    // =============== TOUCHBAR ===============
    // Touchbar: parameterPopover with Segmented Control (seg) and Action
    @IBOutlet weak var parameterPopover: NSPopoverTouchBarItem!
    @IBOutlet weak var seg: NSSegmentedControl!
    @IBAction func setParameterToShow(_ sender: NSSegmentedControl) {
        getParameterFromTouch(sender: sender)
    }
    // Touchbar: Layout Buttons
    @IBOutlet weak var chartPopover: NSPopoverTouchBarItem!
    @IBOutlet weak var btnXGrid: NSButton!
    @IBOutlet weak var btnYGrid: NSButton!
    @IBOutlet weak var btnColor: NSButton!
    @IBOutlet weak var btnTracking: NSButton!
    @IBOutlet weak var btnFullScreen: NSButton!
    var touchbarSwitchers:[NSButton] {
        return [btnXGrid,btnYGrid,btnColor]
    }
    var touchbarSwitchersState:[Int] {
        return touchbarSwitchers.map{$0.state.rawValue}
    }
    // Touchbar: saveTouchItem with save to PDF Button
    @IBOutlet weak var saveTouchItem: NSTouchBarItem!
    @IBOutlet weak var saveButton: NSButton!
    
    // Layout settings variables
    var settingType = ""
    var settingFlag = false
    
    // Action for Toolbar
    @IBAction func chkTapped(_ sender: NSButton) {
        getLayoutFromTool(sender: sender)
        saveChartSettings(settingsStateArray: toolbarSwitchersState, settingFlag: settingFlag, settingType: settingType)
    }
    // Action for Touchbar
    @IBAction func touchButtonTapped(_ sender: NSButton) {
        getLayoutFromTouch(sender: sender)
        saveChartSettings(settingsStateArray: touchbarSwitchersState, settingFlag: settingFlag, settingType: settingType)
    }
    //    Save state of controls both in Tool- and Touchbar
    func saveChartSettings(settingsStateArray:[Int], settingFlag:Bool, settingType:String) {
        userDefaults.set(settingsStateArray, forKey: "settingsStateArray")
        NotificationCenter.default.post(name: .nSettingValue, object: self, userInfo: ["settingFlag": settingFlag, "settingType" : settingType])
    }
    //    Get controls state both for Tool- and Touchbar
    var savedChartSettings: [Int] {
        return userDefaults.value(forKey: "settingsStateArray") as? [Int] ?? [0,0,0]
    }
    

    override func windowDidLoad() {
        super.windowDidLoad()

//        self.window!.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
        
        toolbar.allowsUserCustomization = false
        toolbar.displayMode = .iconAndLabel
        toolbar.sizeMode = .small
        
        setWindowFrame()    // В окончательном варианте - ПРАВИТЬ!
        
        // Fill in PopUp Button
        parameterPopUp.removeAllItems()
        parameterPopUp.addItems(withTitles: ["Dopant Densities","Net Density","Resistivity","Compensation"])
        
        getSavedParameter()
        getSavedChartLayout()
        
        styleTouchBarItems()
    }
    
    // Пока задал оффсеты и начальную высоту initialHeight. В конце уже сделать размер начисто!
    fileprivate func setWindowFrame() {
        if let window = window, let screen = window.screen {
            let screenRect = screen.visibleFrame
            let offsetFromLeftRight: CGFloat = 50
            let offsetFromTop: CGFloat = 100
            let initialHeight: CGFloat = 500
            let windowRect = NSRect(x: offsetFromLeftRight,
                                    y: screenRect.height - offsetFromTop - initialHeight,
                                    width: screenRect.width - 2*offsetFromLeftRight,
                                    height: initialHeight)
            window.setFrame(windowRect, display: true)
            
        }
    }
    
}
