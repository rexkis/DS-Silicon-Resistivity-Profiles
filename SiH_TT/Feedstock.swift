//
//  Feedstock.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 15.12.16.
//  Copyright © 2016 Igor Kutovoy. All rights reserved.
//

import Cocoa

// В этот класс  "заходим" только в случае .customR !!!
class Feedstock: NSObject {
    
    // Initializing
    var currentDopants:[String]
    var inputFields:[Double]
    
    // Computed properties
    var assignedConductivity:String {
        return (currentDopants.first == "B" || currentDopants.first == "Ga") ? "P-type" : "N-type"
    }
    
    // Output property
    var initConcs:[Double] = []
    
    init(currentDopants:[String], inputFields:[Double]) {
        self.currentDopants = currentDopants
        self.inputFields = inputFields
        super.init()
        initConcs = InitConcsFinder.init(dopants: currentDopants,
                                        resProfile: inputFields,
                                        conductivity: assignedConductivity).roots
    }
}

