//
//  InitConcsFinder.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 15.12.16.
//  Copyright © 2016 Igor Kutovoy. All rights reserved.
//

import Cocoa
import Accelerate

public typealias ConvFunction = (Double) -> Double
typealias LAInt = __CLPK_integer

// Used external variables:
// 

class InitConcsFinder {
    public var roots = [Double]()
    
    private var dopants     : [String]
    private var resProfile  : [Double]
    private var conductivity: String
    private var multipliers = [Double]()
    private var leftMatrix = [Double]()
    private var rightMatrix = [Double]()
    private var len:Int {
        return dopants.count
    }
    // Computed properties
    var checkPoints:[Double] {
        return dopants.count == 2 ? [0.05,0.85] : [0.05,0.50,0.85]
    }

    public init(dopants:[String],resProfile:[Double],conductivity: String) {
        self.dopants = dopants
        self.resProfile = resProfile
        self.conductivity = conductivity
        multipliers = getMultipliers()
        leftMatrix = getLeftMatrix()
        rightMatrix = getRightMatrix()
        roots = getInitConcs()
    }
    
    // OLD
//    unc getInitConcs() -> [Double] {
//        let k = vDSP_Length(len)
//        var roots = [Double](repeating: 0.0, count: len)
//        
//        vDSP_mmulD(invert(leftMatrix), 1, rightMatrix, 1, &roots, 1, k, 1, k)
//    
//        return roots
//    }
    
    // New from https://stackoverflow.com/questions/41526674/solving-system-of-equations-in-swift
    
    //func la_matrix_from_double_buffer(_ buffer: UnsafePointer<Double>, _ matrix_rows: la_count_t, _ matrix_cols: la_count_t, _ matrix_row_stride: la_count_t, _ matrix_hint: la_hint_t, _ attributes: la_attribute_t) -> la_object_t
    //Description
    //Create a matrix using data from a buffer of doubles. Ownership of the buffer remains in control of the caller.
    //This function creates an object representing a matrix whose entries are copied out of the supplied buffer of doubles. Negative or zero strides are not supported by this function (but note that you can reverse the rows or columns using the la_matrix_slice function defined below).
    //This routine assumes that the elements of the matrix are stored in the buffer in row-major order. If you need to work with data that is in column-major order, you can do that as follows:
    //1. Use this routine to create a matrix object, but pass the number of columns in your matrix for the matrix_rows parameter and vice-versa. For the matrix_row_stride parameter, pass the column stride of your matrix.
    //2. Make a new matrix transpose object from the object created in step 1. The resulting object represents the matrix that you want to work with.
    //Parameters
    //buffer             Pointer to double data providing the elements of the matrix.
    //matrix_rows        The number of rows in the matrix.
    //matrix_cols        The number of columns in the matrix.
    //matrix_row_stride  The offset in the buffer (measured in doubles) between corresponding
    //                   elements in consecutive rows of the matrix. Must be positive.
    //matrix_hint        Flags describing special matrix structures.
    //attributes         Attributes to attach to the new la_object_t object. Pass
    //                   LA_DEFAULT_ATTRIBUTES to create a normal object.
    //Returns            a new la_object_t object representing the matrix.
    //Declared In	     Accelerate.vecLib.LinearAlgebra.matrix
    
    // NEW
    func getInitConcs() -> [Double] {
        
        let x = Int(sqrt(Double(leftMatrix.count)))
        let N = la_count_t(x)
        
        let mat = la_matrix_from_double_buffer(leftMatrix, N, N, N, la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))
        let vec = la_matrix_from_double_buffer(rightMatrix, N, 1, 1, la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))
        let vecCj = la_solve(mat, vec)
        var cj: [Double] = Array(repeating: 0.0, count: x)
        let status = la_matrix_to_double_buffer(&cj, 1, vecCj)
        if status == la_status_t(LA_SUCCESS) {
            return cj
        } else {
            print("Failure: \(status)")
        }
        return cj
    }
    

    private func getMultipliers() -> [Double] {
        var mult = Array<Double>(repeating: 0.0, count: len)
        var m = 0.0
        var condArray = dopants.map{Constants.dopantsDict[$0]!.conductivity}
        for i in 0..<len {
            m = condArray[i] == conductivity ? 1.0 : -1.0
            mult[i] = m
        }
        return mult
    }
    
    private func getLeftMatrix() -> [Double] {
        var leftMatrix = [Double]()
        var mult = multipliers
        // Расчет левой матрицы
        for i in 0..<len {      // Loop for columns
            for j in 0..<len {  // Loop for rows
                let k = Constants.dopantsDict[dopants[j]]!.segCf
                var value = k*pow(1 - checkPoints[i], k - 1)
                value *= mult[j]
                leftMatrix.append(value)
            }
        }
        return leftMatrix
    }
    
    private func getRightMatrix() -> [Double] {
        let convFunc:ConvFunction = conductivity == "P-type" ? CNV.pR2C : CNV.nR2C
        let rightMatrix = resProfile.map{convFunc($0)}
        return rightMatrix
    }

    
    deinit {
    }
}
