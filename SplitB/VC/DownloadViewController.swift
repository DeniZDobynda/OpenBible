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
    
    private var modulesToDownload: [ModuleOffline]! { didSet{ update() }}
    private var modulesDownloaded: [ModuleOffline]! { didSet{ update() }}
    private var modulesDownloading: [ModuleOffline]! { didSet{ update() }}
    
    private var downloadManager: DownloadManager = DownloadManager(in: AppDelegate.context)
    private var manager: Manager = Manager(in: AppDelegate.context)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modulesToDownload = [
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
        modulesDownloading = []
        modulesDownloaded = []
        
        if let downloaded = manager.getAvailableModules() {
            let available = downloaded.map() {$0.key?.lowercased()}
            for m in modulesToDownload {
                if available.contains(m.key.lowercased()) {
                    modulesToDownload.removeAll(where: {$0.key.lowercased() == m.key.lowercased()})
                    modulesDownloaded.append(m)
                }
            }
        }
    }
    
    private func update() {
        performSelector(onMainThread: #selector(updateUI), with: nil, waitUntilDone: false)
    }

    @objc private func updateUI() {
        table.reloadData()
    }
    
    func download(moduleOffline: ModuleOffline) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.modulesDownloading.append(moduleOffline)
            self?.modulesToDownload.removeAll(where: { $0.key == moduleOffline.key })
            self?.downloadManager.downloadAsync(moduleOffline) { [weak self] (success, error) in
                if success {
                    self?.modulesDownloaded.append(moduleOffline)
                    self?.modulesDownloading.removeAll(where: { $0.key == moduleOffline.key })
                } else {
                    DispatchQueue.main.async { [weak self] in
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    }
                    self?.modulesToDownload.append(moduleOffline)
                    self?.modulesDownloading.removeAll(where: { $0.key == moduleOffline.key })
                }
            }
        }
    }
    
    private func remove(moduleOffline: ModuleOffline) {
        let alert = UIAlertController(title: "Alert", message: "Delete \(moduleOffline.name) ModuleOffline?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.downloadManager.removeAsync(moduleOffline) { [weak self] (success, error) in
                if success {
                    self?.modulesToDownload.append(moduleOffline)
                    self?.modulesDownloaded?.removeAll(where: { $0.key == moduleOffline.key })
                } else {
                    DispatchQueue.main.async { [weak self] in
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}


extension DownloadViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return modulesToDownload?.count ?? 0
        case 1:
            return modulesDownloading?.count ?? 0
        case 2:
            return modulesDownloaded?.count ?? 0
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Download"
        case 1:
            return "Downloading"
        case 2:
            return "Downloaded"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "Module Cell", for: indexPath)
        if indexPath.section == 0 {
            if let modules = modulesToDownload {
                let m = modules[indexPath.row]
                cell.textLabel?.text = m.key
                cell.detailTextLabel?.text = m.name
            }
        } else if indexPath.section == 1 {
            if let modules = modulesDownloading {
                let m = modules[indexPath.row]
                cell.textLabel?.text = m.key
                cell.detailTextLabel?.text = m.name
            }
        } else if indexPath.section == 2 {
            if let modules = modulesDownloaded {
                let m = modules[indexPath.row]
                cell.textLabel?.text = m.key
                cell.detailTextLabel?.text = m.name
            }
        }
        return cell
    }
}

extension DownloadViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            download(moduleOffline: modulesToDownload[indexPath.row])
        } else if indexPath.section == 2 {
            remove(moduleOffline: modulesDownloaded[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
