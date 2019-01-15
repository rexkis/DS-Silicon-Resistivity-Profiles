//
//  InputViewExtensions.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 15.12.16.
//  Copyright © 2016 Igor Kutovoy. All rights reserved.
//

import Foundation
import Cocoa

// Implementation of NSTextFieldDelegate and clear fields at begin editing
extension InputView: NSTextFieldDelegate {
    // NSTextField Delegate Implementation (only Double Values in NSTextField)
    override func controlTextDidChange(_ obj: Notification) {
        let sm = obj.object as! NSTextField
        let str = sm.stringValue
        guard sm.stringValue != "" else {return}
        sm.stringValue = correctString(str)
        // Здесь сделать очистку полей resultView, когда при редактировании стираем символы при помощи backspace, вплоть до полного стирания
        NotificationCenter.default.post(name: .nClearResValues, object: self, userInfo: nil)
    }

    func correctString(_ string:String) -> String {
        guard string.dots > 1 || string.exps > 1 || goodSet.contains(String(describing: string.last!)) == false else {
            return string
        }
        return String(string.dropLast())
    }

    // Clear resArray in ResultView via NotificationCenter when input NSTextFields edit begins
    // Посылаем в ResultView уведомление о том, что началось изменение полей ввода. В ResultView уведомление принимается и уже затем очищаются поля 
    override func controlTextDidBeginEditing(_ obj: Notification) {
        NotificationCenter.default.post(name: .nClearResValues, object: self, userInfo: nil)
    }  
}

// NSComboBoxDataSource DataSource and Delegate
extension InputView: NSComboBoxDataSource, NSComboBoxDelegate {
    // DataSource
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return Constants.dopantProfiles.count
    }
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return Constants.dopantProfiles[index]
    }
}







