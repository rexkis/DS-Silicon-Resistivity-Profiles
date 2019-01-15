//
//  LazyBoxer.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 09.01.17.
//  Copyright © 2017 Igor Kutovoy. All rights reserved.
//

import Cocoa

public enum LazyValue<T> {
    case notYetComputed(() -> T)
    case computed(T)
}

public final class LazyBox<T> {
    
    init(computation: @escaping () -> T) {
        _value = .notYetComputed(computation)
    }
    
    var _value: LazyValue<T>
    
    /// All reads and writes of `_value` must happen on this queue.
    private let queue = DispatchQueue(
        label: "LazyBox._value", attributes: .concurrent)
    
    var value: T {
        var returnValue: T? = nil
        queue.sync {
            switch self._value {
            case .notYetComputed(let computation):
                let result = computation()
                self._value = .computed(result)
                returnValue = result
            case .computed(let result):
                returnValue = result
            }
        }
        assert(returnValue != nil)
        return returnValue!
    }
}

