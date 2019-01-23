//
//  ViewControllerExtensions.swift
//  SiH_TT
//
//  Created by Igor Kutovoy on 06.05.17.
//  Copyright © 2017 Igor Kutovoy. All rights reserved.
//

import Cocoa

// Set start values and initial state, fill fields & showing GraphView
extension ViewController {

    func setInitialState() {
        setStartValues()
        
        firstRun = true
        
        inputView.calcType = calcType
        inputView.currentDopants = currentDopants
        resultView.calcType = calcType
        resultView.currentDopants = currentDopants

        fillFields()

        guard getCalcCorrect() else { return }
        
        firstRun = false
        getChartTypeName()
        showGraphView()  
    }

    private func setStartValues() {
        // Получаем из userDefaults значения currentDopants. Из него определяем индекс текущего значения currentDopants в inputView comboBox (в самом inputView с помощью этого индекса ставим необходимую строку для currentDopants)
        currentDopants = userDefaults.value(forKey: "currentDopants")  as? [String] ?? ["B","P","Ga"]
        inputView.currentDopantsIndex = findDopantsIndex(dopants: currentDopants)!

        
        // Get OR Set calcType
        var idx:Int = 0
        // Читаем строку calcTypeString из userDefaults. Переводим строку в значение calcType; в inputView делаем отмеченным необходимый radioButton
        if let _calcType = userDefaults.value(forKey: "calcTypeString") as? String {
            switch _calcType {
            case "CustomR":
                calcType = .customR
                inputView.radioCustomR.state = NSControl.StateValue(rawValue: 1)
                idx = 0
            default:
                calcType = .customDD
                inputView.radioCustomDD.state = NSControl.StateValue(rawValue: 1)
                idx = 1
            }
        }
        else {
            calcType = .customR
            inputView.radioCustomR.state = NSControl.StateValue(rawValue: 1)
        }
        // В зависимости от определенного ранее индекса idx в inputView и resultView делаем заголовки
        inputView.inputTitleLabel.attributedStringValue = stringMaker.inputTitleLabelsText[idx]
        resultView.resultLabel.attributedStringValue = stringMaker.resultTitleLabelsText[idx]
    }
    private func fillFields() {
        switch calcType {
        case .customDD:
            let x = userDefaults.value(forKey: "initConcsProfile") as? [Double]   // GET initConcsProfile
            
            // Fill in INPUT fields tfArray with saved initial dopant densities
            if let concsProfile = x, x!.isEmpty != true {
                for i in 0..<concsProfile.count {
                    
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    
                    // Если вылетает при СОХРАНЕННЫХ неправильных значениях ввода - раскомментить строку ниже и закомментить строку после нее
//                    inputView.tfArray[i].stringValue = "1e16"
                    // Смотреть и ИСПРАВЛЯТЬ вариант [B,P,Ga]/[1e16,1e17,1e16] - в таком варианте вылетает
                    // Также при [B,P]/[1e16,1e15]
                    inputView.tfArray[i].stringValue = concsProfile[i].styled
                }
            }
            else {
                inputView.tfArray.forEach{$0.stringValue = "1e16"}
                let inputFields = inputView.tfArray.compactMap{Double($0.stringValue)}
                userDefaults.set(inputFields, forKey: "initConcsProfile")   // SET initConcsProfile !?
                // Recursion
                setInitialState()
            }
            
            // Fill in OUTPUT fields resArray with calculated and saved resistivities at check points
            if let calculatedTargetResistivities = userDefaults.object(forKey: "checkPointsResistivities") as? [Double] {
                for i in 0..<calculatedTargetResistivities.count {
                    resultView.resArray[i].stringValue = calculatedTargetResistivities[i].styled
                }
            }
            else {resultView.resArray.forEach{$0.stringValue = ""}}
            
        case .customR:
            // Fill in INPUT fields tfArray with precalculated and saved input saved resistivities at check points
            let x = userDefaults.value(forKey: "resistivityProfile") as? [Double]
            if let resProfile = x, x!.isEmpty != true {
                for i in 0..<resProfile.count {
                    inputView.tfArray[i].stringValue = resProfile[i].styled
                }
            }
            else {
                inputView.tfArray.forEach{$0.stringValue = "1.0"}
                let inputFields = inputView.tfArray.compactMap{Double($0.stringValue)}
                userDefaults.set(inputFields, forKey: "resistivityProfile")
                // Recursion
                setInitialState()
            }
            
            // Fill in OUTPUT fields resArray with precalculated and saved initial dopant densities
            let y = userDefaults.object(forKey: "initConcs") as? [Double]
            if let initDD = y, y!.isEmpty != true {
                for i in 0..<initDD.count {
                    resultView.resArray[i].stringValue = initDD[i].styled
                }
            }
            else {resultView.resArray.forEach{$0.stringValue = ""}}
        }
        
    }
    
//    // Searching index of currentDopants in Constants.dopantsArray
//    func findDopantsIndex(dopants:[String]) -> Int? {
//        for (index,value) in Constants.dopantsArray.enumerated() {
//            if value == currentDopants {return index}
//        }
//        return nil
//    }
}


// Checking text fields for allowed symbols, Error Alerts, clearing fields in inputView and resultView
extension ViewController {
    
    // Checking using errors throwing. Checking for allowed symbols, full length and allowed range of input values
    func checkFields() throws {
        let _tfArray = (inputView.tfArray).filter{$0.isHidden == false}
        let rangeForValue = calcType == .customDD ? allowedDDRange : allowedResRange

        for tf in _tfArray {
            // Check for empty and not Double
            guard tf.checkPassed == true else {
                tf.becomeFirstResponder()
                tf.stringValue = ""
                throw AppErrors.notConvertible
            }

            // using ~= operator (range containment operator, https://medium.com/@nahive/swift-range-containment-operator-3ba838fb8487)
            guard rangeForValue ~= Double(tf.stringValue)! else {
                tf.becomeFirstResponder()
                tf.stringValue = ""
                if calcType == .customDD {
                    throw AppErrors.outOfRangeDD
                } else {
                    throw AppErrors.outOfRangeRes
                }
            }
        }
    }
    
    func ErrorAlert(_ messageText: String, alertMsg:String) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText="\n" + alertMsg
        
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    // Clear fields while changing values in segControl and switcher
    func clearFields() {
        inputView.clearFields()
        resultView.clearFields()
    }
}

// CALCULUS
extension ViewController {
    
    // Calculate with throwing
    func checkConcs(_ concs:[Double]) -> Bool {
        for conc in concs {
            if conc.isInfinite {
                return true
            }
        }
        return false
    }
    func calculate() throws {
        let inputFields = inputView.tfArray.compactMap{Double($0.stringValue)}
        
        switch calcType {
        case .customR:
            feedstock = Feedstock(currentDopants: currentDopants, inputFields: inputFields)
            initConcs = feedstock.initConcs
            for conc in initConcs {
                if conc.isInfinite {
                    throw AppErrors.noSolution
                }
            }
            let negativeRoots = initConcs.contains{$0 < 0}
            let badConcs = checkConcs(initConcs)
            guard !negativeRoots, !badConcs else {
                clearFields()
                inputView.tf0.becomeFirstResponder()
                throw AppErrors.noSolution
            }
            ingotData = Ingot(currentDopants:currentDopants, initConcs: initConcs).getData()
            resistivityProfile = inputFields
            userDefaults.set(resistivityProfile, forKey: "resistivityProfile")
            userDefaults.set(initConcs, forKey: "initConcs")
            
            for i in 0..<initConcs.count {
                resultView.resArray[i].stringValue = initConcs[i].styled
            }
            
        case .customDD:
            initConcs = inputFields
            ingotData = Ingot(currentDopants:currentDopants, initConcs: initConcs).getData()
            initConcsProfile = inputFields
            userDefaults.set(initConcsProfile, forKey: "initConcsProfile")
            var resDistrib = ingotData?.resDist
            var checkPointsRes = currentDopants.count == 2 ?
                [resDistrib?[5],resDistrib?[85]] :
                [resDistrib?[5],resDistrib?[50],resDistrib?[85]]
            for i in 0..<checkPointsRes.count {
                resultView.resArray[i].stringValue = checkPointsRes[i]!.styled
            }
            checkPointsResistivities = checkPointsRes.map{$0!}
            
            // Сохраняем рассчитанные checkPointsResistivities в userDefaults для помещения этих значений в resArray при запуске
            userDefaults.set(checkPointsResistivities, forKey: "checkPointsResistivities")
        }
        
        saveDataToUserDefaults()
        
        graphView.currentDopants = currentDopants
        graphView.ingotData = ingotData
        // !!! Here we get chartTypeName from Notification (func getChangedChartTypeName)
        getChartTypeName()
        setChartSubtitles()
        showGraphView()

        // 
        resData = makeResData()
        tableView.isHidden = false
    }
    
    func saveDataToUserDefaults() {
        userDefaults.set(inputView.currentDopants, forKey: "currentDopants")
        userDefaults.set(inputView.calcType.rawValue, forKey: "calcTypeString")
    }
    
    // Get chartTypeName from userDefaults via chartTypeString
    func getChartTypeName() {
        // Get chartTypeName.rawValue from userDefaults and convert it to chartTypeName parameter
        let chartTypeString = userDefaults.value(forKey: "chartTypeName") as? String ?? "Resistivity"
        switch chartTypeString {
        case "Dopant Densities" :
            chartTypeName = .DD
        case "Net Density" :
            chartTypeName = .Net
        case "Resistivity" :
            chartTypeName = .Res
        case "Compensation":
            chartTypeName = .Cmp
        default: ()
        }
    }
}

