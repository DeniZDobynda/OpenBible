//
//  VerseManager.swift
//  SplitB
//
//  Created by Denis Dobanda on 22.11.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class VerseManager: Manager {

    func getVerses() -> ([String], [String]?) {
        var v1: [String] = []
        var v2: [String]?
        if var verses = chapter1?.verses?.array as? [Verse],
            verses.count > 0 {
            verses.sort { $0.number < $1.number }
            v1 = verses.map { return $0.text ?? ""}
        }
        if var verses = chapter2?.verses?.array as? [Verse],
            verses.count > 0 {
            verses.sort { $0.number < $1.number }
            v2 = verses.map { return $0.text ?? ""}
        }
        return (v1, v2)
    }

}
