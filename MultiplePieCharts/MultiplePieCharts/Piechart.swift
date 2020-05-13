//
//  Piechart.swift
//  MultiplePieCharts
//
//  Created by Michael Charland on 2020-05-12.
//  Copyright © 2020 charland. All rights reserved.
//

import UIKit

@IBDesignable
open class Piechart: UIControl {

    public struct Slice {
        // public var color: UIColor!
        var value: CGFloat = 5
    }

    enum RadiusTpe {
        case inner
        case outer
    }

    public struct Radius {
        var type: RadiusTpe
        var inner: CGFloat
        var outer: CGFloat
        var border: CGFloat
    }

    func getTotal(slices: [Slice]) -> CGFloat {
        var total: CGFloat = 0
        for slice in slices {
            total = slice.value + total
        }
        return total
    }
    private var outerPaths = [UIBezierPath]()
    private var innerPaths = [UIBezierPath]()
    private var centerPath: UIBezierPath?

    var innerRadius: Radius = Radius(type: .inner, inner: 20, outer: 50, border: 2)
    var outerRadius: Radius = Radius(type: .outer, inner: 60, outer: 120, border: 5)
    var activeSlice: (RadiusTpe,Int)?

    open var innnerSlices: [Slice] = []
    open var outerSlices: [Slice] = []

    var highightColor = UIColor.orange
    var pieColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1)

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPieChart()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupPieChart()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
        setupPieChart()
    }

    open override func draw(_ rect: CGRect) {
        super.draw(rect)

        outerPaths = drawPieChart(radius: outerRadius, slices: outerSlices)
        innerPaths = drawPieChart(radius: innerRadius, slices: innnerSlices)
    }

    private func drawPieChart(radius: Radius, slices: [Slice]) -> [UIBezierPath] {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        var startValue: CGFloat = 0
        var startAngle: CGFloat = 0
        var endValue: CGFloat = 0
        var endAngle: CGFloat = 0
        let total = getTotal(slices: slices)

        var paths = [UIBezierPath]()
        for (index, slice) in slices.enumerated() {

            startAngle = (startValue * 2 * CGFloat(Double.pi)) - CGFloat(Double.pi / 2)
            endValue = startValue + (slice.value / total)
            endAngle = (endValue * 2 * CGFloat(Double.pi)) - CGFloat(Double.pi / 2)

            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius.outer, startAngle: startAngle, endAngle: endAngle, clockwise: true)

            var color = pieColor
            if let i = activeSlice, i.0 == radius.type, i.1 == index {
                color = highightColor
            }
            color.setFill()
            path.fill()

            // add color border to slice
            backgroundColor?.setStroke()
            path.lineWidth = radius.border
            path.stroke()

            paths.append(path)
            // increase start value for next slice
            startValue += slice.value / total
        }

        drawCenterCircle(radius: radius)

        return paths
    }

    private func drawCenterCircle(radius: Radius) {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        centerPath = UIBezierPath()
        centerPath?.move(to: center)
        centerPath?.addArc(withCenter: center, radius: radius.inner, startAngle: 0, endAngle: CGFloat(Double.pi) * 2, clockwise: true)
        backgroundColor?.setFill()
        centerPath?.fill()
    }
}

extension Piechart {
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let pt = touch.location(in: self)
        guard let inner = centerPath, !inner.contains(pt) else {
            return true
        }
        for i in 0..<outerPaths.count {
            let path = outerPaths[i]
            if path.contains(pt) {
                var found = false
                for inner in innerPaths {
                    if inner.contains(pt) {
                        found = true
                        break
                    }
                }
                if !found {
                    activeSlice = (.outer, i)
                    setNeedsDisplay()
                    return false
                }
            }
        }
        for i in 0..<innerPaths.count {
            let path = innerPaths[i]
            if path.contains(pt) {
                activeSlice = (.inner, i)
                setNeedsDisplay()
                return false
            }
        }

        return true
    }
}

extension Piechart {
    public func setupPieChart() {
        for _ in 0..<6 {
            innnerSlices.append(Slice())
        }

        for _ in 0..<12 {
            outerSlices.append(Slice())
        }
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.systemBackground

    }
}
