//
//  Extensions.swift
//  SplitB
//
//  Created by Denis Dobanda on 28.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

extension CGRect {
    init(_ x: Double, _ y: Double, _ width: Double, _ height: Double) {
        self.init(x: x, y: y, width: width, height: height)
    }
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.init(x: x, y: y, width: width, height: height)
    }
    init(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
        self.init(x: x, y: y, width: width, height: height)
    }
    
    init(_ fir: CGPoint, _ sec: CGPoint) {
        self.init(origin: CGPoint(x: min(fir.x, sec.x), y: min(fir.y, sec.y)), size: CGSize(width: abs(fir.x - sec.x), height: abs(fir.y - sec.y)))
    }
    init(bounding first: CGRect, with second: CGRect) {
        let fX = first.origin.x
        let fY = first.origin.y
        let sX = second.origin.x
        let sY = second.origin.y
        let minX = min(fX, sX)
        let minY = min(fY, sY)
        
        let lfX = fX + first.width
        let lfY = fY + first.height
        let lsX = sX + second.width
        let lsY = sY + second.height
        
        let w = max(lfX, lsX)
        let h = max(lfY, lsY)
        self.init(minX, minY, w, h)
    }
    
    static func +(lhs: CGRect, rhs: CGRect ) -> CGRect {
        var rect = lhs
        rect.origin.y = rhs.origin.y + rhs.size.height
        return rect
    }
    static func -(lhs: CGRect, rhs: CGRect ) -> CGRect {
        var rect = lhs
        rect.origin.y = rhs.origin.y - lhs.size.height
        return rect
    }
}


extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
    
    func ranging(from range: Range<Int>) -> Range<String.Index> {
        return self.index(startIndex, offsetBy: range.lowerBound)..<self.index(startIndex, offsetBy: range.upperBound)
    }
}

extension UIEdgeInsets {
    init(size: CGFloat) {
        self.init(top: size, left: size, bottom: size, right: size)
    }
}

extension Range where Bound: FixedWidthInteger {
    var nsRange: NSRange { return NSRange(self) }
}
