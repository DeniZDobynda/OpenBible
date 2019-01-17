//
//  ServiceTableViewCell.swift
//  OpenBible
//
//  Created by Denis Dobanda on 15.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class ServiceTableViewCell: UITableViewCell {

    var name: String? {didSet{updateUI()}}
    var select: Bool = true {didSet{updateUI()}}
    var index: Int = 0
    var delegate: SharingObjectTableCellDelegate? {didSet{updateUI()}}
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var switcher: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    private func updateUI() {
        nameLabel?.text = name
        switcher?.isOn = select
        nameLabel?.sizeToFit()
    }
    
    @IBAction func switched(_ sender: UISwitch) {
        delegate?.sharingTableCellWasSelected(sender.isOn, at: index)
    }
    

}
