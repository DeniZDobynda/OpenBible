//
//  ModalViewController.swift
//  SplitB
//
//  Created by Denis Dobanda on 29.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {

    var manager: Manager?
    var delegate: ModalDelegate?
    var modules: [Module]?
    
    @IBOutlet private weak var table: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        modules = manager?.getAvailableModules()
        table.delegate = self
        table.dataSource = self
        
    }

    @IBAction func closeButton(_ sender: Any) {
        delegate?.modalViewWillResign()
        dismiss(animated: true, completion: nil)
    }
    
}

extension ModalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let m = modules {
            manager?.setFirst(m[indexPath.row])
            delegate?.modalViewWillResign()
            dismiss(animated: true, completion: nil)
        }
    }
}

extension ModalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modules?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Modal Table Cell", for: indexPath)
        if let m = modules {
            cell.detailTextLabel?.text = m[indexPath.row].name
            cell.textLabel?.text = m[indexPath.row].key
        }
        return cell
    }
    
    
}
