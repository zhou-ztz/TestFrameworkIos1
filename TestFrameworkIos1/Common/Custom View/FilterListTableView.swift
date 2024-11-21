//
//  FilterListTableView.swift
//  Yippi
//
//  Created by ChuenWai on 04/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


enum filterType {
    case feed
    case live
    case createLive
}

class FilterListTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    private var filterType: filterType
    private var countries: [CountryEntity] = []
    private var languages: [LanguageEntity] = []
    var selectedCell: String? = ""
    var onSelect: EmptyClosure?
    var onDismiss: EmptyClosure?
    
    init(filterType: filterType) {
        self.filterType = filterType
        super.init(frame: .zero, style: .grouped)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.delegate = self
        self.dataSource = self
        self.separatorStyle = .none
        self.backgroundColor = AppTheme.white
        
        self.estimatedRowHeight = 0
        self.estimatedSectionHeaderHeight = 0
        self.estimatedSectionFooterHeight = 0
        
        register(FilterListTableHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        
        switch filterType {
        case .feed:
            countries = CountriesStoreManager().fetch()
            if let selected = UserDefaults.selectedFilterCountry {
                selectedCell = selected
            }
        case .live:
            languages = LanguageStoreManager().fetch()
            if let selected = UserDefaults.selectedFilterLanguage {
                selectedCell = selected
            }
        case .createLive:
            languages = LanguageStoreManager().fetch()
            languages.remove(at: 0)
            if let selected = UserDefaults.selectedCreateLiveFilterLanguage {
                selectedCell = selected
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch filterType {
        case .feed:
            return countries.count
        case .live, .createLive:
            return languages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        let index = indexPath.row
        var displayText: String = ""
        var code: String = ""
        switch filterType {
        case .feed:
            displayText = countries[index].name
            code = countries[index].code
        case .live, .createLive:
            displayText = languages[index].name
            code = languages[index].code
        }
        
        cell.textLabel?.text = displayText
        if code == selectedCell {
            cell.accessoryView = UIImageView(image: UIImage.set_image(named: "blue-tick"))
        } else {
            cell.accessoryView = nil
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch filterType {
        case .feed:
            selectedCell = countries[indexPath.row].code
            if indexPath.row == 0 {
                UserDefaults.selectedFilterCountry = nil
            } else {
                UserDefaults.selectedFilterCountry = selectedCell
            }
        case .live:
            selectedCell = languages[indexPath.row].code
            if indexPath.row == 0 {
                UserDefaults.selectedFilterLanguage = nil
            } else {
                UserDefaults.selectedFilterLanguage = selectedCell
            }
        case .createLive:
            selectedCell = languages[indexPath.row].code
            UserDefaults.selectedCreateLiveFilterLanguage = selectedCell
        }
        onSelect?()
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! FilterListTableHeaderView
        headerView.setText(filterType)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 5))
        view.backgroundColor = .white
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if filterType == .createLive {
            return 5 + TSBottomSafeAreaHeight
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    public func show() {
        if self.superview != nil {
            return
        }
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.addSubview(self)
    }
    
    /// 隐藏分享视图
    public func dismiss() {
        if self.superview == nil {
            return
        }
        self.removeFromSuperview()
        self.onDismiss?()
    }
}

class FilterListTableHeaderView: UITableViewHeaderFooterView {
    private let label = UILabel().configure {
        $0.applyStyle(.regular(size: 14, color: AppTheme.lightGrey))
        $0.textAlignment = .left
    }
    
    private let view = UIView().configure {
        $0.backgroundColor = .white
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        addSubview(view)
        view.addSubview(label)
        view.bindToEdges()
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(15)
            make.top.right.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func setText(_ type: filterType) {
        label.text = type == .feed ? "text_select_country".localized : "text_select_language".localized
    }
}
