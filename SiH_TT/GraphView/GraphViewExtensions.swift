//
//  GraphViewExtensions.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 06.02.17.
//  Copyright © 2017 Igor Kutovoy. All rights reserved.
//

import Cocoa

// Tracking
extension GraphView {
    // Calculate corrected track Point (taking in account coordinates of graphView relative to WINDOW!)
//    func getTrackPoint(point:NSPoint) -> NSPoint {
//        let graphViewRect:NSRect = self.convert(self.bounds, to: nil)
//        let xPoint = point.x - graphViewRect.origin.x - origin.x
//        let yPoint = point.y - graphViewRect.origin.y - origin.y
//        return NSPoint(x: xPoint, y: yPoint)
//    }
    
    func getTrackValueNote() -> String {
        var trackParameterName = chartTypeName.rawValue
        if chartTypeName == .Cmp {trackParameterName += " Level"}
        
        var trackNote:String
        var trackedValue:Double = 0
        
        if chartTypeName != .DD {
            trackedValue = yData!.objectAt(Int(100*gValue)) as! Double
            trackNote = "g = \(String(format: "%4.2f", gValue)), \(trackParameterName) = \(trackedValue.styled)"
        }
        else {
            trackNote = "Dopant Densities"
        }
        return trackNote
    }
    
    func drawTrackMark() {
        let size = (trackNote as NSString).size(withAttributes: GConstants.markAttributes)
        xPosition = origin.x + tickedXLength*CGFloat(gValue) + 2
        yPosition = origin.y + tickedYLength
        
        var markXPosition:CGFloat = 0
        if origin.x + tickedXLength - xPosition <= size.width {
            markXPosition = xPosition - size.width - 2
        }
        else {markXPosition = xPosition + 2}
        
        let rect = NSRect(x: markXPosition, y: yPosition, width: size.width, height: size.height)
        trackNote.draw(with: rect,
                       options: .usesLineFragmentOrigin,
                       attributes: GConstants.markAttributes, context: nil)
//        let ttt = trackNote.attr()
//        ttt.draw(with: rect, options: .usesLineFragmentOrigin)
//        ttt.draw(in: rect)
        
        xPosition -= 2
        yPosition -= 5
    }
    
    func drawTrackingLines() {
        trackXPath.removeAllPoints()
        needsDisplay = true
        NSColor.purple.setStroke()
        trackXPath.lineWidth = 1.0
        trackXPath.move(to: NSPoint(x: xPosition, y: origin.y))
        trackXPath.line(to: NSPoint(x: xPosition, y: yPosition))
        trackXPath.stroke()
    }

}

// P-N Areas, Legend
extension GraphView {
    
    func drawPNAreas() {
 
        let conductivityType = ingotData!.startConductivity
        negRange = ingotData!.negRange
        
        let colors = conductivityType == "P-type" ? [GConstants.pTypeColor,GConstants.nTypeColor] : [GConstants.nTypeColor,GConstants.pTypeColor]
        let origin = GConstants.chartOrigin
        
        var path1 = NSBezierPath()
        var path2 = NSBezierPath()
        var path3 = NSBezierPath()
        var width1 :CGFloat = 0
        var width2 :CGFloat = 0
        var width3 :CGFloat = 0
        let height:CGFloat = tickedYLength
        var rect1 = NSRect()
        var rect2 = NSRect()
        var rect3 = NSRect()
        
        if negRange! != [] {
            // First area
            width1 = tickedXLength*CGFloat(negRange![0])*0.01
            rect1 = NSRect(x: origin.x,
                              y: origin.y,
                              width: width1, height: height)
            path1 = NSBezierPath(rect: rect1)
            colors[0].setFill()
            path1.fill()
            
            // Second Area
            width2 = tickedXLength*CGFloat(negRange![1] - negRange![0])*0.01
            rect2 = NSRect(x: origin.x + width1,
                              y: origin.y,
                              width: width2, height: height)
            path2 = NSBezierPath(rect: rect2)
            colors[1].setFill()
            path2.fill()
            
            // Third Area (if exists)
            if negRange![1] != 99 {
                width3 = tickedXLength*(1.0 - CGFloat(negRange![1])*0.01)
                rect3 = NSRect(x: origin.x + width1 + width2,
                               y: origin.y,
                               width: width3, height: height)
                path3 = NSBezierPath(rect: rect3)
                colors[0].setFill()
                path3.fill()
            }

        }
        else {
            width1 = tickedXLength
            rect1 = NSRect(x: origin.x,
                           y: origin.y,
                           width: width1, height: height)
            path1 = NSBezierPath(rect: rect1)
            colors[0].setFill()
            path1.fill()
        }
        
    }
    
    func drawLegend(dopants:[String]) {
        
        let legendYPosition = calculatedLabel.frame.minY
        let legendOrigin = CGPoint(x: GConstants.chartOrigin.x + 20, y: legendYPosition - 10)
        let legendLineLength:CGFloat = 80
        
        for i in 0..<currentDopants.count {
            // Draw Legend Line
            let path = NSBezierPath()
            path.lineWidth = 2.0
            
            let currentLegendOrigin = CGPoint(
                x: legendOrigin.x + CGFloat(i)*(legendLineLength + 20),
                y: legendOrigin.y)
            path.move(to: currentLegendOrigin)
            path.line(to: CGPoint(x: currentLegendOrigin.x + legendLineLength , y: legendOrigin.y))
            (Constants.dopantsDict[dopants[i]]!.color).setStroke()
            path.stroke()
            
            // Draw Legend Marks
            let legendMarkOrigin = NSPoint(x: currentLegendOrigin.x + legendLineLength/2 - 4,
                                           y: currentLegendOrigin.y - 4)
            curves!.drawMark(markOrigin: legendMarkOrigin, dataName: currentDopants[i])
            
            // Draw Legend Title
            let dopantName = Constants.dopantsDict[dopants[i]]!.description as NSString
            let dopantNameSize:NSSize = dopantName.size(withAttributes: GConstants.markAttributes)
            let dopantNameOrigin = CGPoint(
                x: currentLegendOrigin.x + (legendLineLength - dopantNameSize.width)/2,
                y: currentLegendOrigin.y - 20)
            dopantName.draw(at: dopantNameOrigin, withAttributes: GConstants.markAttributes)
        }
    }

}
