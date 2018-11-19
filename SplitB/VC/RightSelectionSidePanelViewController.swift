//
//  RightSelectionSidePanelViewController.swift
//  SplitB
//
//  Created by Denis Dobanda on 19.11.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class RightSelectionSidePanelViewController: SidePanelViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!
    
    var manager: Manager! {
        didSet {
            var m: [Module?] = [nil]
            m.append(contentsOf: manager?.getAvailableModules(exceptFirst: true) ?? [])
            modules = m
        }
    }
    private var modules: [Module?] = [nil]
    
    override func viewDidLoad() {
        table?.delegate = self
        table?.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var m: [Module?] = [nil]
        m.append(contentsOf: manager?.getAvailableModules(exceptFirst: true) ?? [])
        modules = m
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "Module Selection Cell", for: indexPath)
        cell.textLabel?.text = modules[indexPath.row]?.name ?? "Disabled"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectModule(modules[indexPath.row])
    }
    

}
