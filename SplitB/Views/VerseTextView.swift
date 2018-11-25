//
//  VerseTextView.swift
//  SplitB
//
//  Created by Denis Dobanda on 25.11.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class VerseTextView: CustomTextView {

    var verseTextManager: VerseTextManager!
    override var textManager: TextManager! {
        get { return verseTextManager }
        set { print("Error: Set of textManager in VerseTextView") }
    }
    
    internal var boundingRectsForVerses: ([CGRect], [CGRect]?)?
    
    func selectVerse(at point: CGPoint) -> CGRect? {
        if let rects = boundingRectsForVerses {
            for i in 0..<rects.0.count {
                if rects.0[i].contains(point) {
                    selectVerse(number: i)
                    return rects.0[i]
                }
            }
            if let second = rects.1 {
                for i in 0..<second.count {
                    if rects.0[i].contains(point) {
                        selectVerse(number: i, first: false)
                        return rects.0[i]
                    }
                }
            }
        }
        return nil
    }
    
    private func selectVerse(number: Int, first: Bool = true) {
        let rangeCh = first ? verseTextManager.versesRanges!.0[number] : verseTextManager.versesRanges!.1![number]
        var ixStart = layoutManager.glyphIndexForCharacter(at: rangeCh.lowerBound)
        var ixEnd = layoutManager.glyphIndexForCharacter(at: rangeCh.upperBound)
        var range: NSRange
        if ixStart > ixEnd {
            swap(&ixStart, &ixEnd)
        }
//        let s = layoutManager.textStorage!.string
//        var sub = String(s[..<s.index(s.startIndex, offsetBy: ixStart)])
//        var count = sub.indicesOf(string: "\r\n").count
//        var charRange = layoutManager.characterRange(forGlyphRange: NSRange(ixStart - count..<ixEnd - count), actualGlyphRange: nil)
//        while(charRange.lowerBound > 1 && !separators.contains(s[s.index(s.startIndex, offsetBy: charRange.lowerBound - 1)])) {
//            charRange.location -= 1
//            charRange.length += 1
//            ixStart -= 1
//        }
//        sub = String(s[s.index(s.startIndex, offsetBy: charRange.lowerBound)..<s.index(s.startIndex, offsetBy: charRange.upperBound)])
//        count = sub.indicesOf(string: "\r\n").count
//        charRange.length -= count
//        while(charRange.upperBound < s.count - 1 && !separators.contains(s[s.index(s.startIndex, offsetBy: charRange.upperBound + 1)])) {
//            charRange.length += 1
//            ixEnd += 1
//        }
        range = NSRange(ixStart...ixEnd)
        previousRange = range
        layoutManager.selectedRange = range
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let versesRanges = verseTextManager.versesRanges {
            let first = versesRanges.0
            var rects1: [CGRect] = []
            var rects2: [CGRect] = []
            for i in 0..<first.count {
                let range = first[i]
                let glyphRange = layoutManager.glyphRange(forCharacterRange: range.nsRange, actualCharacterRange: nil
                )
                let rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                rects1.append(rect)
                
                if let second = versesRanges.1?[i] {
                    let glyphRange2 = layoutManager.glyphRange(forCharacterRange: second.nsRange, actualCharacterRange: nil
                    )
                    let rect2 = layoutManager.boundingRect(forGlyphRange: glyphRange2, in: textContainer)
                    rects2.append(rect2)
                }
            }
            
            if let second = versesRanges.1,
                second.count > first.count {
                for i in first.count..<second.count {
                    let glyphRange2 = layoutManager.glyphRange(forCharacterRange: second[i].nsRange, actualCharacterRange: nil
                    )
                    let rect2 = layoutManager.boundingRect(forGlyphRange: glyphRange2, in: textContainer)
                    rects2.append(rect2)
                }
            }
            
            boundingRectsForVerses = rects2.count > 0 ? (rects1, rects2) : (rects1, nil)
        }
//        print(boundingRectsForVerses)
    }

}
