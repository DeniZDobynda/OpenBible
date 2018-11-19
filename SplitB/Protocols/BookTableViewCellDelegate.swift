//
//  BookTableViewCellDelegate.swift
//  SplitB
//
//  Created by Denis Dobanda on 29.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

protocol BookTableViewCellDelegate {
    func bookTableViewCellDidSelect(chapter: Int, in book: Int)
}
