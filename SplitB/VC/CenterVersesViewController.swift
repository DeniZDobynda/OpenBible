//
//  CenterVersesViewController.swift
//  SplitB
//
//  Created by Denis Dobanda on 22.11.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit
import SearchTextField

class CenterVersesViewController: CenterViewController {

    var verseTextManager: VerseTextManager?
    var verseManager: VerseManager?
    
    @IBOutlet weak var search: SearchTextField!
    private var isInSearch = false {
        didSet {
            topScrollConstraint.constant = isInSearch ? search.frame.height : 0.0
        }
    }
    @IBOutlet weak var topScrollConstraint: NSLayoutConstraint!
    
    
    @IBAction func searchAction(_ sender: UIBarButtonItem) {
        isInSearch = !isInSearch
        if isInSearch {
            search.isHidden = false
            search.text = nil
            search.becomeFirstResponder()
        } else {
            search.isHidden = true
            search.text = nil
            view.endEditing(true)
        }
    }
    
    @IBAction func searchDidEnd(_ sender: SearchTextField) {
        if let text = sender.text {
            parseSearch(text: text)
        }
        sender.text = nil
        sender.isHidden = true
        isInSearch = false
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let titles = verseManager?.getBooksTitles() {
            search.filterStrings(titles)
        }
        search.theme.font = UIFont.systemFont(ofSize: 12)
        search.theme.bgColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
    }
    
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
    
    private func parseSearch(text: String) {
        var index = 0
        while (!("0"..."9" ~= text[text.index(text.startIndex, offsetBy: index)]) ||
            index == 0) &&
            index < text.count - 1 {
            index += 1
        }
        let s1 = String(text[..<text.index(text.startIndex, offsetBy: index)]).trimmingCharacters(in: .whitespacesAndNewlines)
        let s2 = String(text[text.index(text.startIndex, offsetBy: index)...]).trimmingCharacters(in: .whitespacesAndNewlines)
//        print(s1)
//        print("--")
//        print(s2, Int(s2))
        
        verseManager?.setBook(byTitle: s1)
        if let number = Int(s2) {
            verseManager?.setChapter(number: number)
        }
        loadTextManager()
    }

}