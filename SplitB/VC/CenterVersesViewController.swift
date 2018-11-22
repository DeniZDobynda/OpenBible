//
//  CenterVersesViewController.swift
//  SplitB
//
//  Created by Denis Dobanda on 22.11.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class CenterVersesViewController: CenterViewController {

    var verseTextManager: VerseTextManager?
    var verseManager: VerseManager?
    
    override var coreManager: Manager? {
        get {
            return verseManager
        }
        set {
            print("Error!! didSet coreManager")
        }
    }
    override var textManager: TextManager? {
        get {
            return verseTextManager
        }
        set {
            print("Error!! didSet textManager")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func loadTextManager(_ forced: Bool = true) {
//        var first: [String] = []
//        var second: [String] = []
//        let texts = verseTextManager?.getTwoStrings()
//        if let f = texts?.0 {
//            first = f
//        }
//        if let s = texts?.1 {
//            second = s
//        }
        if forced, let verses = verseManager?.getVerses() {
            verseTextManager = VerseTextManager(verses: verses)
            if let m = coreManager {
                navigationItem.title = "\(m.get1BookName()) \(m.chapterNumber)"
            }
            
            switch customTextView {
            case .some:
                customTextView.removeFromSuperview()
            default: break
            }
            
            customTextView = CustomTextView(frame: scrollView.bounds)
            customTextView.textManager = textManager
            scrollView.addSubview(customTextView)
            scrollView.scrollRectToVisible(CGRect(0,0,1,1), animated: false)
        }
        textManager?.fontSize = fontSize
        customTextView.setNeedsLayout()
    }

}
