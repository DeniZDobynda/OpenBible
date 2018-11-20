//
//  Manager.swift
//  SplitB
//
//  Created by Denis Dobanda on 25.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit
import CoreData

class Manager {
    
    var context: NSManagedObjectContext!
    
    private lazy var module1: Module! = {
        if let all = try? Module.getAll(from: context), all.count > 0 {
            return all[0]
        }
        return nil
    }()
    private var module2: Module?
    
    var bookNumber: Int { didSet { plistManager.set(book: bookNumber, chapter: chapterNumber) } }
    var chapterNumber: Int { didSet { plistManager.set(book: bookNumber, chapter: chapterNumber) } }
    
    private var plistManager = PlistManager()
    
    var book1: Book? {
        if let books = module1?.books?.array as? [Book] {
            let bookFiltered = books.filter { Int($0.number) == bookNumber }
            return bookFiltered.first
        }
        return nil
    }
    var book2: Book? {
        if let books = module2?.books?.array as? [Book] {
            let bookFiltered = books.filter { Int($0.number) == bookNumber }
            return bookFiltered.first
        }
        return nil
    }
    var chapter1: Chapter? {
        if let book = book1, let chapters = book.chapters?.array as? [Chapter] {
            let chaptersFiltered = chapters.filter { Int($0.number) == chapterNumber }
            return chaptersFiltered.first
        }
        return nil
    }
    var chapter2: Chapter? {
        if let book = book2, let chapters = book.chapters?.array as? [Chapter] {
            let chaptersFiltered = chapters.filter { Int($0.number) == chapterNumber }
            return chaptersFiltered.first
        }
        return nil
    }
    
    
    init (in context: NSManagedObjectContext) {
        self.context = context
        let last = plistManager.getCurrentBookAndChapterIndexes()
        bookNumber = last.0
        chapterNumber = last.1
        let m1 = plistManager.getPrimaryModule()
        if m1.count > 0 {
            if let modules = try? Module.getAll(from: context) {
                let filtered = modules.filter {$0.key == m1}
                if filtered.count > 0 {
                    module1 = filtered[0]
                }
            }
        }
        let m2 = plistManager.getSecondaryModule()
        if m2.count > 0 {
            if let modules = try? Module.getAll(from: context) {
                let filtered = modules.filter {$0.key == m2}
                module2 = filtered.first
            }
        }
    }
    
    func getAvailableModules(exceptFirst: Bool = false) -> [Module]? {
        do {
            var all = try Module.getAll(from: context)
            if exceptFirst, let m = module1 {
                all.removeAll(where: {$0.key == m.key})
            }
            return all
        } catch {
            print(error)
        }
        return nil
    }
    
    func getMainModuleKey() -> String? {
        return module1?.key
    }
    
    func getSecondaryModuleKey() -> String? {
        return module2?.key
    }
    
    func setFirst(_ module: Module) {
        if module2?.key == module.key {
            module2 = module1
        }
        module1 = module
        plistManager.setPrimary(module: module.key ?? "")
    }
    
    func setSecond(_ module: Module?) {
        module2 = module
        plistManager.setSecondary(module: module?.key ?? "")
    }
    
    func getBooks() -> [Book]? {
        return (module1?.books?.array as? [Book])?.sorted(by: { (f, s) -> Bool in
            f.number < s.number
        })
    }
    
    
    func next() {
        if let book = book1, let chapters = book.chapters?.array as? [Chapter] {
            for chapter in chapters {
                if Int(chapter.number) == chapterNumber + 1 {
                    chapterNumber += 1
                    return
                }
            }
        }
        if let books = module1.books?.array as? [Book] {
            for book in books {
                if Int(book.number) == bookNumber + 1 {
                    bookNumber += 1
                    chapterNumber = 1
                    return
                }
            }
        }
    }
    func previous() {
        chapterNumber -= 1
        if chapterNumber == 0, bookNumber != 1, let books = module1.books?.array as? [Book] {
            for book in books {
                if Int(book.number) == bookNumber - 1 {
                    bookNumber -= 1
                    if let chapters = book.chapters?.array as? [Chapter] {
                        for chapter in chapters {
                            if Int(chapter.number) > chapterNumber {
                                chapterNumber = Int(chapter.number)
                            }
                        }
                        return
                    } else {
                        bookNumber += 1
                        chapterNumber += 1
                        return
                    }
                }
            }
            chapterNumber += 1
        }
        if (bookNumber == 1) {
            chapterNumber = 1
        }
        
    }

    func get1BookName() -> String {
        return book1?.name ?? ""
    }
    
    
    func getTwoStrings() -> ([String]?, [String]?) {
        var s1: [String]? = ["Please, download available modules"]
        var s2: [String]? = nil
        if let chapter = chapter1, let verses = chapter.verses?.array as? [Verse] {
            var s = [String]()
            for verse in verses {
                if let t = verse.text {
                    s.append(t)
                }
            }
            s1 = s
        }
        if let chapter = chapter2, let verses = chapter.verses?.array as? [Verse] {
            var s = [String]()
            for verse in verses {
                if let t = verse.text {
                    s.append(t)
                }
            }
            s2 = s
        }
        return (s1, s2)
    }
    
    
}
