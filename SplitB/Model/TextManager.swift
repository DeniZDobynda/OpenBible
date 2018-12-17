//
//  Model.swift
//  TextViewCustom
//
//  Created by Denis Dobanda on 24.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class TextManager: NSObject {
    
    var textToDisplayInFirst: [String]
    var textToDisplayInSecond: [String]
    
    var textStorage: NSTextStorage!
    var layoutManager: NSLayoutManager!
    var textContainer: TwoColumnContainer!
    var fontSize: CGFloat = 30
    
    override init() {
        textToDisplayInFirst = []
        textToDisplayInSecond = []
    }
    
    init(first: [String], second: [String]) {
        textToDisplayInFirst = first
        textToDisplayInSecond = second
    }
    
    func placeText(into textStorage: inout NSTextStorage) -> ([Range<Int>], [Int]) {
        var ranges: [Range <Int>] = []
        var dividers: [Int] = []
        
        var m = min(textToDisplayInFirst.count, textToDisplayInSecond.count)
        
        if m == 0, textToDisplayInSecond.count != 0 {
            swap(&textToDisplayInFirst, &textToDisplayInSecond)
        }
        
        var effectiveRange = NSRange(1..<3)
        
        let attr: [NSAttributedString.Key:Any] = [.font:UIFont.systemFont(ofSize:fontSize)]
        let nl = NSAttributedString(string: "\n", attributes: [.font:UIFont.systemFont(ofSize:fontSize / 5)])
        var startRange = 0
        for i in 0..<m {
            if i >= 99 {
                effectiveRange = NSRange(1..<4)
            }
            let t1 = NSMutableAttributedString(string: " \(i + 1) " + textToDisplayInFirst[i], attributes: attr)
            let t2 = NSMutableAttributedString(string: " \(i + 1) " + textToDisplayInSecond[i], attributes: attr)
            t1.addAttribute(.font, value:UIFont.italicSystemFont(ofSize: fontSize * 0.6), range:effectiveRange)
            t1.addAttribute(.baselineOffset, value: fontSize * 0.3, range: effectiveRange)
            t1.addAttribute(.foregroundColor, value:UIColor.gray.withAlphaComponent(0.7), range:effectiveRange)
            textStorage.append(t1)
            //            textStorage.append(nl)
            t2.addAttribute(.font, value:UIFont.italicSystemFont(ofSize: fontSize * 0.6), range:effectiveRange)
            t2.addAttribute(.baselineOffset, value: fontSize * 0.3, range: effectiveRange)
            t2.addAttribute(.foregroundColor, value:UIColor.gray.withAlphaComponent(0.7), range:effectiveRange)
            textStorage.append(t2)
            
            startRange += t1.length// + 1
            ranges.append(startRange..<startRange + t2.length)
            startRange += t2.length// + 1
            if ( i != m ) {
                textStorage.append(nl)
                dividers.append(startRange)
                startRange += 1
            }
        }
        
        if m < textToDisplayInFirst.count {
            let c = textToDisplayInFirst.count
            if m > 0 {
                textStorage.append(nl)
//                textStorage.append(nl)
                startRange += 1
                dividers.append(startRange)
                startRange += 1
            }
            while m < c {
                if m >= 99 {
                    effectiveRange = NSRange(1..<4)
                }
                let t1 = NSMutableAttributedString(string: " \(m + 1) " + textToDisplayInFirst[m], attributes: attr)
                t1.addAttribute(.font, value:UIFont.italicSystemFont(ofSize: fontSize * 0.6), range:effectiveRange)
                t1.addAttribute(.baselineOffset, value: fontSize * 0.3, range: effectiveRange)
                t1.addAttribute(.foregroundColor, value:UIColor.gray.withAlphaComponent(0.7), range:effectiveRange)
                textStorage.append(t1)
                startRange += t1.length
                if (m != c ) {
                    textStorage.append(nl)
                    //                    textStorage.append(nl)
                    
                    dividers.append(startRange)
                    startRange += 1
                }
                m += 1
            }
        } else if m < textToDisplayInSecond.count {
            let c = textToDisplayInSecond.count
            if m > 0 {
                textStorage.append(nl)
//                textStorage.append(nl)
                startRange += 1
                dividers.append(startRange)
                startRange += 1
            }
            while m < c {
                if m >= 99 {
                    effectiveRange = NSRange(1..<4)
                }
                let t1 = NSMutableAttributedString(string: " \(m + 1) " + textToDisplayInSecond[m], attributes: attr)
                t1.addAttribute(.font, value:UIFont.italicSystemFont(ofSize: fontSize * 0.6), range:effectiveRange)
                t1.addAttribute(.baselineOffset, value: fontSize * 0.3, range: effectiveRange)
                t1.addAttribute(.foregroundColor, value:UIColor.gray.withAlphaComponent(0.7), range:effectiveRange)
                textStorage.append(t1)
                ranges.append(startRange..<startRange + t1.length)
                startRange += t1.length
                if (m < c ) {
                    textStorage.append(nl)
                    //                    textStorage.append(nl)
                    
                    dividers.append(startRange)
                    startRange += 1
                }
                m += 1
            }
        }
        return (ranges, dividers)
    }
    
    func getContainer(in bounds: CGSize) -> NSTextContainer {
        
        textStorage = NSTextStorage()
        let (ranges, dividers) = placeText(into: &textStorage)
        
        layoutManager = CustomDebugLayoutManager()
        layoutManager.allowsNonContiguousLayout = false
        let containerSize = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        textContainer = TwoColumnContainer(size: containerSize)
        let manager = TwoColumnPositioningManager(containerSize, ranges: ranges, dividers: dividers, height: 0.0)
//        container.rangesForSecond = textToDisplayInSecond.count > 0 ? ranges : nil
//        container.dividers = dividers
        textContainer.manager = manager
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        
        textStorage.addLayoutManager(layoutManager)
        
        return textContainer
    }
    
}
