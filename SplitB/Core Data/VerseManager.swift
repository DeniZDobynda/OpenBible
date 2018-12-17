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
        if module1 == nil {
            initMainModule()
        }
        if module2 == nil {
            initSecondModule()
        }
        var v1: [String] = []
        var v2: [String]?
        if var verses = chapter1?.verses?.array as? [Verse],
            verses.count > 0 {
            verses.sort { $0.number < $1.number }
            v1 = verses.map { return $0.text ?? ""}
//            for i in 0..<v1.count {
//                v1[i].remove(at: v1[i].index(v1[i].endIndex, offsetBy: -1))
//            }
        }
        if var verses = chapter2?.verses?.array as? [Verse],
            verses.count > 0 {
            verses.sort { $0.number < $1.number }
            v2 = verses.map { return $0.text ?? ""}
//            for i in 0..<v2!.count {
//                v2![i].remove(at: v2![i].index(v2![i].endIndex, offsetBy: -1))
//            }
        }
        return (v1, v2)
    }
    
    func getBooksTitles() -> [String]? {
        if let module = module1,
            let books = module.books?.array as? [Book] {
            return books.map {$0.name ?? ""}
        }
        return nil
    }
    
    func setBook(byTitle title: String) {
        let t = title.lowercased()
        if let books = module1.books?.array as? [Book] {
            for book in books {
                if let name = book.name?.lowercased(),
                    name.starts(with: t) {
                    bookNumber = Int(book.number)
                    chapterNumber = 1
                    
                    return
                }
            }
        }
    }
    
    
    func setChapter(number: Int) {
        if let book = book1, let ch = book.chapters?.array, ch.count > number {
            chapterNumber = number
        }
    }

}

