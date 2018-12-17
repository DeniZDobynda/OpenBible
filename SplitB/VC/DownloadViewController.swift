//
//  DownloadViewController.swift
//  SplitB
//
//  Created by Denis Dobanda on 24.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit
import CoreData

class DownloadViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView! { didSet { table.delegate = self; table.dataSource = self } }
    
    private var modules: [ModuleOffline]! //{ didSet{ update() }}
    private var modulesDownloaded: [String] = []
    private var modulesDownloading: [IndexPath]? = []
    
    private var downloadManager: DownloadManager = DownloadManager(in: AppDelegate.context)
    private var manager: Manager = Manager(in: AppDelegate.context)
    
    private let backSelectionView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        backSelectionView.backgroundColor = UIColor.green
        modules = [
            ModuleOffline("King James Version", "kjv"),
            ModuleOffline("Schlachter 1951", "schlachter"),
            ModuleOffline("KJV Easy Read", "akjv"),
            ModuleOffline("American Standard Version", "asv"),
            ModuleOffline("World English Bible", "web"),
            ModuleOffline("Luther (1912)", "luther1912"),
            ModuleOffline("Elberfelder (1871)", "elberfelder"),
            ModuleOffline("Elberfelder (1905)", "elberfelder1905"),
            ModuleOffline("Luther (1545)", "luther1545"),
            ModuleOffline("Textus Receptus", "text"),
            ModuleOffline("NT Textus Receptus (1550 1894) Parsed", "textusreceptus"),
            ModuleOffline("Hebrew Modern", "modernhebrew"),
            ModuleOffline("Aleppo Codex", "aleppo"),
            ModuleOffline("OT Westminster Leningrad Codex", "codex"),
            ModuleOffline("Hungarian Karoli", "karoli"),
            ModuleOffline("Vulgata Clementina", "vulgate"),
            ModuleOffline("Almeida Atualizada", "almeida"),
            ModuleOffline("Cornilescu", "cornilescu"),
            ModuleOffline("Synodal Translation (1876)", "synodal"),
            ModuleOffline("Makarij Translation Pentateuch (1825)", "makarij"),
            ModuleOffline("Sagradas Escrituras", "sse"),
            ModuleOffline("NT (P Kulish 1871)", "ukranian")
        ]
        
        if let downloaded = manager.getAvailableModules() {
            modulesDownloaded = downloaded.map() {$0.key?.lowercased() ?? ""}
        }
    }
    
//    private func update() {
//        performSelector(onMainThread: #selector(updateUI), with: nil, waitUntilDone: false)
//    }
//
//    @objc private func updateUI() {
//        table.reloadData()
//    }
    
}


extension DownloadViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "Module Cell", for: indexPath)
        if let modules = modules {
            let m = modules[indexPath.row]
            cell.textLabel?.text = m.key
            cell.detailTextLabel?.text = m.name
            cell.accessoryType = modulesDownloaded.contains(m.key) ? .checkmark : .none
        }
        return cell
    }
}

extension DownloadViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if cell.accessoryType == .none {
            if cell.selectedBackgroundView == backSelectionView {
                print("deselected")
            } else {
                cell.selectedBackgroundView = backSelectionView
                let module = modules[indexPath.row]
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.downloadManager.downloadAsync(module) { [weak self] (success, error) in
                        if success {
                            self?.modulesDownloaded.append(module.key)
                            DispatchQueue.main.async {
                                cell.accessoryType = .checkmark
                                tableView.beginUpdates()
                                tableView.endUpdates()
                            }
                        } else {
                            DispatchQueue.main.async { [weak self] in
                                let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                self?.present(alert, animated:true, completion:nil)
                            }
                        }
                        DispatchQueue.main.async {
                            cell.selectedBackgroundView = UIView()
                            cell.setSelected(false, animated: false)
                            tableView.beginUpdates()
                            tableView.endUpdates()
                        }
                    }
                }
            }
        } else  {
            let module = modules[indexPath.row]
            let alert = UIAlertController(title: "Alert", message: "Delete \(module.name) Module?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title:"Yes", style:.default, handler:{ [weak self] _ in
                self?.downloadManager.removeAsync(module) { [weak self] (success, error) in
                    if success {
                        self?.modulesDownloaded.removeAll(where: { (key) -> Bool in
                            return key == module.key
                        })
                        DispatchQueue.main.async {
                            cell.accessoryType = .none
                            tableView.beginUpdates()
                            tableView.endUpdates()
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self?.present(alert, animated:true, completion:nil)
                        }
                    }
                }
                
            }))
            self.present(alert, animated: true) {
                cell.setSelected(false, animated: false)
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        if cell.selectedBackgroundView == backSelectionView {
            cell.setSelected(true, animated: false)
        }
    }
    
}
