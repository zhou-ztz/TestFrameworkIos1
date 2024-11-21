//
//  LocationPOISearchViewController.swift
//  Yippi
//
//  Created by francis on 31/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit
import CoreLocation
import IQKeyboardManagerSwift
import MJRefresh

class LocationPOISearchViewController: TSViewController {
    
    private let tableview: TSTableView = TSTableView(bgColor: .white)
    private let searchContainerView = UIView()
    private let searchView: TSSearchBar = TSSearchBar()
    
    private var location: CLLocation? {
        willSet {
            locationManager.stopUpdatingLocation()
            guard let _ = newValue else {
                self.updatingLocationIndicator.dismiss()
                self.view.isUserInteractionEnabled = true
                return
            }
            
            throttler.call()
        }
    }
    
    var hasMore = false
    var onLocationSelected: ((TSPostLocationObject) -> Void)?
    var throttler = Throttler(time: .seconds(1.0), mode: .deferred, immediateFire: true, nil)
    
    fileprivate var locationPermissionStatus: CLAuthorizationStatus = .notDetermined {
        willSet {
            switch newValue {
            case .authorizedAlways, .authorizedWhenInUse:
                updatingLocationIndicator.show()
                locationManager.startUpdatingLocation()
            default:
                location = nil
                hasMore = false
                locationManager.stopUpdatingLocation()
            }
        }
        
        didSet {
            switch self.locationPermissionStatus {
            case .denied, .notDetermined, .restricted:
                defer {
                    self.updatingLocationIndicator.dismiss()
                    self.view.isUserInteractionEnabled = true
                }
                // reset
                searchView.text = ""
                datasource = []
                tableview.show(placeholderView: .needLocationAccess)
                tableview.placeholder.onTapActionButton = { [weak self] in
                    self?.showRequestPermission()
                }
                
            default: break // search here
            }
        }
    }
    
    private var datasource: [TSPostLocationObject] = [] {
        willSet {
            guard newValue.isEmpty == true else {
                self.tableview.removePlaceholderViews()
                return
            }
            
            self.tableview.show(placeholderView: .emptyResult)
        }
    }
    fileprivate let updatingLocationIndicator = TSIndicatorWindowTop(state: .loading, title: "loading".localized)
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        throttler.callback = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // 在此处访问 UISearchBar 的 text 属性
                if let location = self.location {
                    self.search(with: self.searchView.text.orEmpty, coordinate: (location.coordinate.latitude, location.coordinate.longitude), complete: { [weak self] locations in
                        self?.hasMore = true
                        self?.datasource = locations
                        self?.tableview.reloadData()
                        self?.footerEndRefresh()
                    })
                } else {
                    self.search(with: self.searchView.text.orEmpty, coordinate: (0.0, 0.0), complete: { [unowned self] locations in
                        self.hasMore = false
                        self.datasource = locations
                        self.tableview.reloadData()
                        self.footerEndRefresh()
                    })
                }
            }
            
            
        }
    }
    
    
    private func footerEndRefresh() {
        switch locationPermissionStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            if hasMore {
                self.tableview.mj_footer.endRefreshing()
            } else {
                self.tableview.mj_footer.endRefreshingWithNoMoreData()
            }
            
        default:
            self.tableview.mj_footer.endRefreshingWithNoMoreData()
        }
    }
    
    /// combines 2 sets of location without duplicate location id
    private func jointLocationSet(set: [TSPostLocationObject], newSet: [TSPostLocationObject]) -> [TSPostLocationObject] {
        var uniqueIds = Set<String>()
        set.forEach { (object) in
            uniqueIds.insert(object.locationID)
        }
        let filtered: [TSPostLocationObject] = newSet.compactMap {
            guard uniqueIds.contains($0.locationID) == false else { return nil }
            
            uniqueIds.insert($0.locationID)
            return $0
        }
        
        let joint = set + filtered
        
        return joint
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        setupSearch()
        
        view.backgroundColor = TSColor.inconspicuous.background
        setCloseButton(backImage: true, titleStr: "check_in".localized)
        navigationController?.automaticallyAdjustsScrollViewInsets = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.isUserInteractionEnabled = false
        updatingLocationIndicator.show()
        locationManager.requestWhenInUseAuthorization()
        
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    
    private func showRequestPermission() {
        self.askPermission(title: "setting_allow_location".localized)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        updatingLocationIndicator.dismiss()
    }
    
    private func setupTable() {
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.separatorInset = UIEdgeInsets.zero
        tableview.tableFooterView = UIView()
        tableview.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableview.mj_header.makeHidden()
        tableview.keyboardDismissMode = .onDrag
    }
    
    private func search(with keyword: String,
                        coordinate: (CLLocationDegrees, CLLocationDegrees) = (0.0, 0.0),
                        complete: (([TSPostLocationObject]) -> Void)? = nil) {
        
        let (lat, lng) = coordinate
        
        TSLocationsSearchNetworkManager().searchLocations(queryString: keyword, lat: lat, lng: lng) { [weak self] (locations, message) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                defer {
                    self.updatingLocationIndicator.dismiss()
                    self.view.isUserInteractionEnabled = true
                }
                guard let locations = locations else {
                    if let _ = message {
                        self.tableview.show(placeholderView: .network)
                    } else {
                        self.tableview.show(placeholderView: .emptyResult)
                    }
                    return
                }
                
                complete?(locations)
                
            }
        }
    }
    
    private func searchGlobal(with keyword: String, complete: (([TSPostLocationObject]) -> Void)? = nil) {
        search(with: keyword, complete: complete)
    }
    
    @objc private func loadMore() {
        searchGlobal(with: searchView.text.orEmpty) { [weak self] (locations) in
            defer { self?.footerEndRefresh() }
            self?.hasMore = false
            guard let self = self else { return }
            self.datasource = self.jointLocationSet(set: self.datasource, newSet: locations)
            self.tableview.reloadData()
        }
    }
    
    private func setupSearch() {
        searchContainerView.addSubview(searchView)
        searchView.placeholder = "search_placeholder".localized
        searchView.searchBarStyle = .minimal
        searchView.backgroundColor = .white
        searchView.returnKeyType = .search
        searchView.tintColor = TSColor.main.theme
        searchView.delegate = self
        
        if let textfield = searchView.value(forKey: "searchField") as? UITextField {
            textfield.textColor = .black
            for item in textfield.subviews {
                if let backgroundview = item.subviews.first {
                    backgroundview.backgroundColor = UIColor.blue
                    backgroundview.layer.cornerRadius = 20
                    backgroundview.layer.masksToBounds = true
                }
            }
            textfield.borderStyle = .none
            textfield.layer.cornerRadius = 20.0
            textfield.backgroundColor = UIColor(hex: 0xEDEDED)
        }
        
        searchView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
            make.height.equalTo(50)
        }
        
        searchContainerView.backgroundColor = .white
        
        view.addSubview(searchContainerView)
        view.addSubview(tableview)
        
        searchContainerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
        tableview.snp.makeConstraints {
            $0.top.equalTo(searchContainerView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        tableview.register(UINib(nibName: "LocationPOICell", bundle: nil),
                           forCellReuseIdentifier: "locationPoiCell")
    }
    
}

extension LocationPOISearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        
        onLocationSelected?(datasource[indexPath.row])
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationPoiCell", for: indexPath) as! LocationPOICell
        
        let source = datasource[indexPath.row]
        cell.configure(primary: source.locationName, secondary: source.address)
        
        return cell
    }
    
}


extension LocationPOISearchViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationPermissionStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
    }
}

extension LocationPOISearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        throttler.call()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        throttler.call()
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
