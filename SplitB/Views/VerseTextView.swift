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
    
    var selectedFirstVerse: (Int, Bool)?
    var selectedSecondVerse: (Int, Bool)?
    private var versesRanges: ([Range<Int>], [Range<Int>]?)? {
        return verseTextManager.versesRanges
    }
    
    
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
                    if second[i].contains(point) {
                        selectVerse(number: i, first: false)
                        return second[i]
                    }
                }
            }
        }
        return nil
    }
    
    private func selectVerse(number: Int, first: Bool = true) {
        var rangeCh: Range<Int>
        if selectedFirstVerse == nil {
            rangeCh = first ? versesRanges!.0[number] : versesRanges!.1![number]
            selectedFirstVerse = (number, first)
        } else {
            if let second = selectedSecondVerse {
                if selectedFirstVerse!.0 < number && second.0 > number {
                    clearSelection()
                    return
                } else if selectedFirstVerse!.0 > number && second.0 < number {
                    clearSelection()
                    return
                } else if selectedFirstVerse!.0 == number && selectedFirstVerse!.1 == first {
                    clearSelection()
                    return
                } else if second.0 == number && second.1 == first {
                    clearSelection()
                    return
                }
            } else if number == selectedFirstVerse!.0 && first == selectedFirstVerse!.1 {
                clearSelection()
                return
            }
            var lower: Int
            var upper: Int
            if selectedFirstVerse!.0 < number || ( selectedFirstVerse!.0 == number && selectedFirstVerse!.1 == true) {
                lower = selectedFirstVerse!.1 ? versesRanges!.0[selectedFirstVerse!.0].lowerBound : versesRanges!.1![selectedFirstVerse!.0].lowerBound
                upper = first ? versesRanges!.0[number].upperBound : versesRanges!.1![number].upperBound
            } else {
                upper = selectedFirstVerse!.1 ? versesRanges!.0[selectedFirstVerse!.0].upperBound : versesRanges!.1![selectedFirstVerse!.0].upperBound
                lower = first ? versesRanges!.0[number].lowerBound : versesRanges!.1![number].lowerBound
            }
            rangeCh = lower..<upper
            selectedSecondVerse = (number, first)
        }
        var ixStart = layoutManager.glyphIndexForCharacter(at: rangeCh.lowerBound)
        var ixEnd = layoutManager.glyphIndexForCharacter(at: rangeCh.upperBound)
        var range: NSRange
        if ixStart > ixEnd {
            swap(&ixStart, &ixEnd)
        }
        
        let s = layoutManager.textStorage!.string
        var sub = String(s[..<s.index(s.startIndex, offsetBy: ixStart)])
        var count = sub.indicesOf(string: "\r").count
        if boundingRectsForVerses?.1 != nil {
            count /= 2
        }
        ixStart += count
//        var charRange = layoutManager.characterRange(forGlyphRange: NSRange(ixStart - count..<ixEnd - count), actualGlyphRange: nil)
//        while(charRange.lowerBound > 1 && !separators.contains(s[s.index(s.startIndex, offsetBy: charRange.lowerBound - 1)])) {
//            charRange.location -= 1
//            charRange.length += 1
//            ixStart -= 1
//        }
        sub = String(s[s.index(s.startIndex, offsetBy: rangeCh.lowerBound)..<s.index(s.startIndex, offsetBy: rangeCh.upperBound)])
        if boundingRectsForVerses?.1 != nil {
            count += (sub.indicesOf(string: "\r").count - 1 ) / 2
        } else {
            count += sub.indicesOf(string: "\r").count - 1
        }
//        charRange.length -= count
//        while(charRange.upperBound < s.count - 1 && !separators.contains(s[s.index(s.startIndex, offsetBy: charRange.upperBound + 1)])) {
//            charRange.length += 1
//            ixEnd += 1
//        }
        ixEnd += count
        range = NSRange(ixStart...ixEnd)
        previousRange = range
        layoutManager.selectedRange = range
        setNeedsDisplay()
    }
    
    override func clearSelection() {
        super.clearSelection()
        selectedFirstVerse = nil
        selectedSecondVerse = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let versesRanges = verseTextManager.versesRanges {
            let wid = bounds.width / 2
            let first = versesRanges.0
            var rects1: [CGRect] = []
            var rects2: [CGRect] = []
            for i in 0..<first.count {
                let range = first[i]
                let glyphRange = layoutManager.glyphRange(forCharacterRange: range.nsRange, actualCharacterRange: nil
                )
                var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                rect.size.width = wid
                rects1.append(rect)
                
                if let second = versesRanges.1?[i] {
                    let glyphRange2 = layoutManager.glyphRange(forCharacterRange: second.nsRange, actualCharacterRange: nil
                    )
                    var rect2 = layoutManager.boundingRect(forGlyphRange: glyphRange2, in: textContainer)
                    rect2.size.width = wid
                    rect2.origin.x = rect.origin.x + wid
                    rects2.append(rect2)
                }
            }
            
            if let second = versesRanges.1,
                second.count > first.count {
                for i in first.count..<second.count {
                    let glyphRange2 = layoutManager.glyphRange(forCharacterRange: second[i].nsRange, actualCharacterRange: nil
                    )
                    var rect2 = layoutManager.boundingRect(forGlyphRange: glyphRange2, in: textContainer)
                    rect2.size.width = wid
                    rect2.origin.x = rects2[i-1].origin.x
                    rects2.append(rect2)
                }
            }
            
            boundingRectsForVerses = rects2.count > 0 ? (rects1, rects2) : (rects1, nil)
        }
//        print(boundingRectsForVerses)
    }

}
