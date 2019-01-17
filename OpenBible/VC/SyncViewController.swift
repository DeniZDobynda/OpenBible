//
//  SyncViewController.swift
//  OpenBible
//
//  Created by Denis Dobanda on 15.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class SyncViewController: UIViewController {

    private var type = "_thedenizbiblesync._tcp."
    
    private var services = [NetService]()
    private var manager: SyncManager?
    private var sharedKeys: [String]?
    private var sharedValues: [String]?
    private var browser = Bonjour()
    private let refreshControl = UIRefreshControl()
    
    
    @IBOutlet private weak var servicesTable: UITableView!
    @IBOutlet private weak var infoTable: UITableView!
    @IBOutlet private weak var progressBar: UIProgressView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var syncButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshOnDemand(_:)), for: UIControl.Event.valueChanged)
        servicesTable.addSubview(refreshControl)
        
        infoTable.isHidden = true
        progressBar.isHidden = true
        backButton.isHidden = true
        syncButton.isHidden = true
        servicesTable.dataSource = self
        servicesTable.delegate = self
        infoTable.dataSource = self
        infoTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager?.closeNetworkCommunication()
        manager = nil
        services = []
        scan()
    }
    
    private func scan() {
        services = []
        var names = [String]()
        _=browser.findService(type, domain: Bonjour.LocalDomain) { (new) in
            for s in new {
                if !names.contains(s.name) {
                    self.services.append(s)
                    names.append(s.name)
                }
            }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.servicesTable.reloadData()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeConnectionAndRestoreView()
    }
    
    private func closeConnectionAndRestoreView() {
        manager?.closeNetworkCommunication()
        manager = nil
        services = []
        infoTable.isHidden = true
        servicesTable.isHidden = false
        backButton.isHidden = true
        syncButton.isHidden = true
        sharedKeys = nil
        sharedValues = nil
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        closeConnectionAndRestoreView()
        scan()
    }
    
    @IBAction func syncAction(_ sender: UIButton) {
        manager?.sync()
    }
    
    private func setSelected(service: NetService) {
        manager = SyncManager()
        manager!.service = service
        manager!.delegate = self
        manager!.initialize()
        servicesTable.isHidden = true
        infoTable.isHidden = false
        backButton.isHidden = false
        syncButton.isHidden = false
    }
    
    @objc func refreshOnDemand(_ sender: AnyObject) {
        scan()
    }
    
}

extension SyncViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == servicesTable {
            return services.count
        } else if tableView == infoTable {
            return sharedValues?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == servicesTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Services Table Cell", for: indexPath)
            cell.textLabel?.text = services[indexPath.row].name
            return cell
        } else if tableView == infoTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Info Table Cell", for: indexPath)
            if let c = cell as? ServiceTableViewCell {
                c.name = sharedValues?[indexPath.row]
                c.select = true
                c.index = indexPath.row
                c.delegate = self
            }
            return cell
        }
        return UITableViewCell()
    }
    
    
}

extension SyncViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == servicesTable {
            tableView.deselectRow(at: indexPath, animated: true)
            setSelected(service: services[indexPath.row])
        }
    }
}

extension SyncViewController: SyncManagerDelegate {
    func syncManagerDidStartSync() {
        DispatchQueue.main.async { [weak self] in
            self?.progressBar.isHidden = false
            self?.progressBar.progress = 0.0
        }
    }
    
    func syncManagerDidSync(_ progress: Float) {
        DispatchQueue.main.async { [weak self] in
            self?.progressBar.progress = progress
        }
    }
    
    func syncManagerDidEndSync() {
        DispatchQueue.main.async { [weak self] in
            self?.progressBar.progress = 1.0
        }
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (t) in
            DispatchQueue.main.async { [weak self] in
                self?.progressBar.isHidden = true
                t.invalidate()
            }
        }
    }
    
    func syncManagerDidGetUpdate() {
        if let dict = manager?.sharedObjects {
            sharedKeys = []
            sharedValues = []
            for (key, value) in dict {
                sharedKeys!.append(key)
                sharedValues!.append(value)
            }
        } else {
            sharedValues = nil
            sharedKeys = nil
        }
        DispatchQueue.main.async {
            self.infoTable.reloadData()
        }
    }
    
    func syncManagerDidTerminate() {
        DispatchQueue.main.async { [weak self] in
            self?.closeConnectionAndRestoreView()
        }
    }
}

extension SyncViewController: SharingObjectTableCellDelegate {
    func sharingTableCellWasSelected(_ state: Bool, at index: Int) {
        manager?.selectedObjects?[index] = state
    }
}
