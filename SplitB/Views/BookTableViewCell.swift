//
//  BookTableViewCell.swift
//  SplitB
//
//  Created by Denis Dobanda on 29.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var book: Book! {
        didSet {
            titleLabel?.text = book.name
        }
    }
    var delegate: BookTableViewCellDelegate?
    var bookNumber: Int {
        return Int(book.number)
    }
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var numbersCollection: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numbersCollection.isHidden = true
//        titleLabel.text = book.name
        numbersCollection.dataSource = self
        numbersCollection.delegate = self
        sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        numbersCollection.isHidden = !selected
        numbersCollection.sizeToFit()
        numbersCollection.reloadData()
        sizeToFit()
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.bookTableViewCellDidSelect(chapter: indexPath.row + 1, in: bookNumber)
    }
    
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return book.chapters?.array.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "Number Collection Cell", for: indexPath)
        if let cell = c as? NumberCollectionViewCell {
            cell.number = indexPath.row + 1
        }
        c.backgroundColor = UIColor.white
        return c
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Compute the dimension of a cell for an NxN layout with space S between
        // cells.  Take the collection view's width, subtract (N-1)*S points for
        // the spaces between the cells, and then divide by N to find the final
        // dimension for the cell's width and height.
        
        let cellsAcross: CGFloat = 5
        let spaceBetweenCells: CGFloat = 10
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim)
    }
}
