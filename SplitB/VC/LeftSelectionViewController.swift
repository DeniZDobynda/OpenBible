//
//  ViewController.swift
//  TextViewCustom
//
//  Created by Denis Dobanda on 23.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class LeftSelectionViewController: SidePanelViewController {

    
    var manager: Manager! {
        didSet {
            if let m = manager {
                books = m.getBooks()
                moduleButton?.setTitle(m.getMainModuleKey(), for: .normal)
            }
        }
    }
    var rightSpace: CGFloat = 0.0 {
        didSet {
            rightConstraint.constant = rightSpace
            rightButtonConstraint.constant = -rightSpace // guess why :)
        }
    }
    
    @IBOutlet weak var moduleButton: UIButton!
    private var heightForRowNotSelected: CGFloat = 50.0
    private var heightForRowSelected: CGFloat = 60.0
    private var selectedIndexPath: IndexPath?
    
    @IBOutlet private weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var bookTable: UITableView!
    
    private var books: [Book]? {
        didSet {
            bookTable?.reloadData()
            bookTable?.scrollToRow(at: IndexPath(row: manager.bookNumber - 1, section: 0), at: UITableView.ScrollPosition.middle, animated: false)
        }
    }
    
    private var count: Int {
        return books?.count ?? 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        books = manager.getBooks()
        rightConstraint.constant = rightSpace
        rightButtonConstraint.constant = rightSpace
        heightForRowSelected = bookTable.bounds.width / 5
        bookTable.dataSource = self
        bookTable.delegate = self
        moduleButton?.setTitle(manager?.getMainModuleKey(), for: .normal)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Modal Picker", let dest = segue.destination as? ModalViewController {
            dest.manager = manager
            dest.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let m = manager {
            books = m.getBooks()
            moduleButton?.setTitle(m.getMainModuleKey(), for: .normal)
//            bookTable?.scrollToRow(at: IndexPath(row: m.bookNumber - 1, section: 0), at: UITableView.ScrollPosition.middle, animated: true)
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        bookTable?.reloadData()
//    }
    
    
}

extension LeftSelectionViewController: BookTableViewCellDelegate {
    func bookTableViewCellDidSelect(chapter: Int, in book: Int) {
        delegate?.didSelect(chapter: chapter, in: book)
        print("selected \(chapter) in \(book)")
    }
}


extension LeftSelectionViewController: ModalDelegate {
    func modalViewWillResign() {
        bookTable?.reloadData()
        delegate?.setNeedsReload()
    }
}

extension LeftSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let sel = selectedIndexPath , indexPath == sel, let b = books {
            //            let cell = tableView.cellForRow(at: indexPath) as! BookTableViewCell
            let cellsAcross: CGFloat = 5
            let spaceBetweenCells: CGFloat = 10
            let dim = (tableView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
            
            let countOfNumbers = b[indexPath.row].chapters!.count
            var countOfRows = countOfNumbers / Int(cellsAcross)
            countOfRows += countOfNumbers % Int(cellsAcross) == 0 ? 0 : 1
            
            return heightForRowNotSelected + dim * CGFloat(countOfRows) + spaceBetweenCells * CGFloat(countOfRows -  1) - 10
        }
        return heightForRowNotSelected
    }
}

extension LeftSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Book Table Cell", for: indexPath)
        if let c = cell as? BookTableViewCell, let b = books {
            c.book = b[indexPath.row]
            c.delegate = self
        }
        cell.autoresizingMask = .flexibleHeight
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectedIndexPath{
        case .none:
            selectedIndexPath = indexPath
            tableView.reloadRows(at: [indexPath], with: .none)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        case .some:
            if selectedIndexPath == indexPath {
                selectedIndexPath = nil
                tableView.deselectRow(at: indexPath, animated: true)
                tableView.reloadRows(at: [indexPath], with: .none)
            } else {
                let old = selectedIndexPath
                tableView.deselectRow(at: selectedIndexPath!, animated: false)
                tableView.reloadRows(at: [old!], with: .none)
                selectedIndexPath = indexPath
                tableView.reloadRows(at: [old!, indexPath], with: .none)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            }
        }
    }
}
