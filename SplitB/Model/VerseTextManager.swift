//
//  VerseTextManager.swift
//  SplitB
//
//  Created by Denis Dobanda on 22.11.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class VerseTextManager: TextManager {

    var verses: ([NSAttributedString], [NSAttributedString]?)?
    var versesRanges: ([Range <Int>], [Range<Int>]?)?
    
    init(verses:([NSAttributedString], [NSAttributedString]?)) {
        self.verses = verses
        super.init()
    }
    
    override func placeText(into textStorage: inout NSTextStorage) -> ([Range<Int>], [Int]) {
        var r1: [Range <Int>] = []
        var r2: [Range <Int>] = []


        var currentStartPoint = 1
        if let verses = verses {
            for i in 0..<verses.0.count {
                let endpoint = 2 + String(i).count + verses.0[i].length + currentStartPoint
                r1.append(currentStartPoint..<endpoint)
//                textToDisplayInFirst.append(verses.0[i])
                currentStartPoint = endpoint + 1
                if let secondVerse = verses.1?[i] {
                    let endpoint = 2 + String(i).count + secondVerse.length + currentStartPoint
                    r2.append(currentStartPoint..<endpoint)
//                    textToDisplayInSecond.append(secondVerse)
                    currentStartPoint = endpoint + 1
                }
            }
            if let secondVerses = verses.1,
                secondVerses.count > verses.0.count {
                for i in verses.0.count..<secondVerses.count {
                    let endpoint = 2 + String(i).count + secondVerses[i].length + currentStartPoint
                    r2.append(currentStartPoint..<endpoint)
//                    textToDisplayInSecond.append(secondVerses[i])
                    currentStartPoint = endpoint + 1
                    
                }
            }
            textToDisplayInFirst = verses.0
            if let v2 = verses.1 {
                textToDisplayInSecond = v2
            }
        }

        versesRanges = r2.count > 0 ? (r1, r2) : (r1, nil)
        
        return super.placeText(into: &textStorage)
    }

}
