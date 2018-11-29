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
    var verseTextView: VerseTextView! { didSet{ verseTextView?.delegate = self }}
    
    override var customTextView: CustomTextView! {
        get {return verseTextView}
        set {print("Error: set customTextView")}
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
    
    @IBOutlet weak var search: SearchTextField!
    private var isInSearch = false {
        didSet {
            topScrollConstraint.constant = isInSearch ? search.frame.height : 0.0
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
    }
    @IBOutlet weak var topScrollConstraint: NSLayoutConstraint!
    
    @IBAction func searchAction(_ sender: UIBarButtonItem) {
        isInSearch = !isInSearch
    }
    
    private var tapInProgress = false
    private var panInProgress = false
    private var menuRect: CGRect?
    private var firstMenuRect: CGRect?
    private var timerScrollingMenu: Timer?
    
    @IBAction func searchDidEnd(_ sender: SearchTextField) {
        if let text = sender.text {
            parseSearch(text: text)
        }
        isInSearch = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let titles = verseManager?.getBooksTitles() {
            search.filterStrings(titles)
        }
        search.theme.font = UIFont.systemFont(ofSize: 12)
        search.theme.bgColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(touch(sender:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(tap)
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
            
            switch verseTextView {
            case .some:
                verseTextView.removeFromSuperview()
            default: break
            }
            
            verseTextView = VerseTextView(frame: scrollView.bounds)
            verseTextView.verseTextManager = verseTextManager
            scrollView.addSubview(verseTextView)
            scrollView.scrollRectToVisible(CGRect(0,0,1,1), animated: false)
        }
        textManager?.fontSize = fontSize
        customTextView.setNeedsLayout()
    }
    
    @objc private func touch(sender: UITapGestureRecognizer) {
        if sender.state == .ended && !panInProgress {
            if let rect = verseTextView.selectVerse(at: sender.location(in: scrollView)) {
                tapInProgress = true
                
                switch firstMenuRect {
                case .none:
                    menuRect = rect
                    firstMenuRect = rect
                case .some(let r):
                    menuRect = CGRect(bounding: r, with: rect)
                }
                showMenu()
            }
        }
        panInProgress = false
    }
    
    private func showMenu() {
        if let s = customTextView.getSelection(), let rect = menuRect {
            textToCopy = s
            becomeFirstResponder()
            let copyItem = UIMenuItem(title: "Copy", action: #selector(copySelector))
            let defineItem = UIMenuItem(title: "Define", action: #selector(defineSelector))
            UIMenuController.shared.menuItems = [copyItem, defineItem]
            UIMenuController.shared.setTargetRect(rect, in: scrollView)
            UIMenuController.shared.setMenuVisible(true, animated: true)
        } else {
            tapInProgress = false
            panInProgress = false
            menuRect = nil
            firstMenuRect = nil
        }
    }
    
    private func parseSearch(text: String) {
        guard text.count > 0 else {return}
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

    override func UIMenuControllerWillHide() {
        if !tapInProgress {
            verseTextView.clearSelection()
        }
    }
    
    override func longTap(sender: UILongPressGestureRecognizer) {
        super.longTap(sender: sender)
        panInProgress = true
        tapInProgress = false
        menuRect = nil
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        timerScrollingMenu?.invalidate()
        timerScrollingMenu = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] (t) in
            self?.showMenu()
            self?.timerScrollingMenu = nil
            t.invalidate()
        }
    }
}
