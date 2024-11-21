//
//  FilterableTableViewController.swift
//  Yippi
//
//  Created by Jerry Ng on 22/04/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit


private struct SelectorStyle {
    let labelColor = UIColor.lightGray
    let selectedLabelColor = AppTheme.aquaBlue

    let titleColor = UIColor.darkGray
    let titleFont = UIFont.boldSystemFont(ofSize: 12)

    let itemsPerGrid = 3
}

class FilterableTableViewController: TSViewController {
    
    public let filterTitleLabel: UILabel = UILabel().configure {
        $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        $0.text = "Filter"
    }
    private let filterOptionStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 8
    }
    private let filterOptionLabel: UILabel = UILabel().configure {
        $0.applyStyle(.semibold(size: 12, color: UIColor(hex: 0x888888)))
    }
    private let filterOptionImageView: UIImageView = UIImageView(image: UIImage.set_image(named: "ic_drop_down")).configure {
        $0.tintColor = UIColor(hex: 0x9b9b9b)
    }
    public let filterOptionBubbleView: UIView = UIView().configure {
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = UIColor(hex: 0xD1D1D1).cgColor
    }
    
    public let tableContainerView = UIView()
    public var tableView: UITableView!
    
    private var selectorView: FilterOptionWrapperView?
    public var filterOptions: [String] = []
    public var preselectedOption: String {
        didSet {
           // if preselectedOption == filterOptions.first {
            filterOptionBubbleView.backgroundColor = .white
            filterOptionLabel.textColor = UIColor(hex: 0x888888)
          //  } else {
          //      filterOptionBubbleView.backgroundColor = AppTheme.dodgerBlue
          //      filterOptionLabel.textColor = .white
          //  }
        }
    }
    
    public var onFilterOptionChanged: ((String)->())? = nil
    
    init() {
        self.tableView = TSTableView(frame: .zero, style: .plain)
        self.preselectedOption = ""
        super.init(nibName: nil, bundle: nil)
    }
    
    init(tableView: UITableView, filterOptions: [String], preselectedOption: String) {
        self.tableView = tableView
        self.filterOptions = filterOptions
        self.preselectedOption = preselectedOption
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFilterSection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func configureFilterSection() {
        self.view.backgroundColor = .white
        let baseStackView = UIStackView()
        baseStackView.axis = .vertical
        baseStackView.distribution = .fill
        baseStackView.alignment = .fill
        baseStackView.spacing = 8
        
        self.view.addSubview(baseStackView)
        baseStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.left.bottom.right.equalToSuperview()
        }
        
        let filterSectionView = UIView()
        filterSectionView.backgroundColor = .white
        filterOptionStackView.addArrangedSubview(filterOptionLabel)
        filterOptionStackView.addArrangedSubview(filterOptionImageView)
        filterSectionView.addSubview(filterOptionBubbleView)
        filterSectionView.addSubview(filterOptionStackView)
        //filterSectionView.addSubview(filterTitleLabel)
        
        tableContainerView.addSubview(tableView)
        tableView.bindToEdges()
        
        //baseStackView.addArrangedSubview(filterSectionView)
        baseStackView.addArrangedSubview(tableContainerView)
        
        filterSectionView.snp.makeConstraints {
            $0.height.equalTo(34)
        }
        filterOptionStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(28)
        }
        filterOptionBubbleView.snp.makeConstraints {
            $0.centerY.equalTo(filterOptionStackView.snp.centerY)
            $0.height.equalTo(25)
            $0.left.equalTo(filterOptionStackView.snp.left).offset(-12)
            $0.right.equalTo(filterOptionStackView.snp.right).offset(12)
        }
        filterOptionBubbleView.roundCorner(12.5)
//        filterTitleLabel.snp.makeConstraints {
//            $0.centerY.equalToSuperview()
//            $0.left.equalToSuperview().inset(16)
//        }
//        filterOptionBubbleView.roundCorner(12.5)
//        filterTitleLabel.snp.makeConstraints {
//            $0.centerY.equalToSuperview()
//            $0.left.equalToSuperview().inset(16)
//        }
        filterOptionImageView.snp.makeConstraints {
            $0.width.equalTo(15)
            $0.height.equalTo(15)
        }
        
        filterOptionLabel.text = preselectedOption
        
        setOptionsHandlers()
    }
    
    private func setOptionsHandlers() {
        
//        filterOptionStackView.addAction { [weak self] in
//            guard let self = self else { return }
//            UIView.animate(withDuration: 0.2) {
//                self.filterOptionImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
//            }
//            guard self.selectorView == nil else {
//                self.selectorView?.hide()
//                return
//            }
//            self.selectorView = FilterOptionWrapperView(options: self.filterOptions, preselectedOption: self.preselectedOption, animatable: true, onSelect: { [weak self] (code) in
//                self?.filterOptionLabel.text = code
//                self?.preselectedOption = code
//                self?.onFilterOptionChanged?(code)
//                self?.tableView.mj_header.beginRefreshing()
//            })
//            self.tableContainerView.addSubview(self.selectorView!)
//            self.selectorView!.bindToEdges()
//            
//            self.selectorView!.notifyComplete = { [weak self] in
//                self?.selectorView = nil
//                UIView.animate(withDuration: 0.2) {
//                    self?.filterOptionImageView.transform = .identity
//                }
//            }
//            
//            self.view.layoutIfNeeded()
//        }
        
        filterOptionStackView.addAction { [weak self] in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//                let bottomSheet = TransactionHistoryBottomSheetVC()
//                bottomSheet.delegate = self
//                bottomSheet.walletType = .rebate
//                bottomSheet.modalPresentationStyle = .custom
//                let transitionDelegate = HalfScreenTransitionDelegate()
//                transitionDelegate.heightPercentage = 0.3
//                bottomSheet.transitioningDelegate = transitionDelegate
//                self?.present(bottomSheet, animated: true)
//            }
        }
        
    }
}

class FilterOptionSelectorView: UIView {

    private let styles = SelectorStyle()
    private let contentView = UIView()
    private let optionGridView = UIStackView().configure { (v) in
        v.axis = .vertical
        v.alignment = .fill
        v.spacing = 0
        v.distribution = .fillEqually

    }
    private var selectedOption: String?
    private var options: [String] = [String]()
    private var selectionViews: [SelectionView] = []
    private var selectionHandler: ((String) -> Void)?

    init(options: [String], selected: String, selectionHandler: ((String) -> Void)?) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white

        self.options = options
        self.selectedOption = self.options.first(where: { $0.uppercased() == selected.uppercased() })
        self.selectionHandler = selectionHandler
        prepareUI()
        updateUI()
    }

    required init?(coder: NSCoder) {
        fatalError("view not supported")
    }

    private func prepareUI() {
        addSubview(contentView)
        contentView.bindToEdges()
        contentView.addSubview(optionGridView)
        optionGridView.bindToEdges(inset: 10)
    }

    private func updateUI() {
        selectionViews = []
        optionGridView.removeAllSubviews()
        var pointerGrid: UIStackView?

        for (i, optionString) in options.enumerated() {
            let (qoutient, remainder) = i.quotientAndRemainder(dividingBy: self.styles.itemsPerGrid)
            let activeView = SelectionView(with: optionString)

            if remainder == 0 { // start new grid
                let horizontalGrid = UIStackView().configure { (v) in
                    v.axis = .horizontal
                    v.spacing = 10
                    v.alignment = .fill
                    v.distribution = .fillEqually
                    
                }
                pointerGrid = horizontalGrid
                horizontalGrid.addArrangedSubview(activeView)

                optionGridView.addArrangedSubview(horizontalGrid)
            } else {
                pointerGrid?.addArrangedSubview(activeView)
            }

            selectionViews.append(activeView)

            if i == (options.count - 1) && pointerGrid != nil {
                optionGridView.addArrangedSubview(pointerGrid!)

                for i in remainder..<(self.styles.itemsPerGrid - 1) {
                    pointerGrid!.addArrangedSubview(UIView())
                }
            }
            activeView.selected = optionString == selectedOption.orEmpty

            activeView.onTap = { [weak self] currentView in
                guard let self = self else { return }
                currentView.selected = true
                self.selectionViews.forEach({ (v) in
                    guard v != currentView else { return }
                    v.selected = false
                })
                self.selectionHandler?(optionString)
            }
        }
    }
}

class FilterOptionWrapperView: UIView {
    
    private let scrollView = UIScrollView()
    private let content: UIStackView = UIStackView()
    private var animatable: Bool = false
    var notifyComplete: EmptyClosure?

    init(options: [String], preselectedOption: String, animatable: Bool = true, onSelect: ((String) -> Void)?) {
        super.init(frame: .zero)

        self.animatable = animatable
        prepareViews()
        
        // set options
        setupFilterOptions(preselect: preselectedOption, options: options) { [weak self] (code) in
            onSelect?(code)
            self?.hide()
        }
    }
    
    private func prepareViews()  {
        addSubview(scrollView)
        scrollView.addSubview(content)

        content.alignment = .fill
        content.axis = .vertical
        content.spacing = 0
        content.distribution = .fill

        scrollView.snp.makeConstraints { (v) in
            v.top.left.bottom.right.equalToSuperview()
        }

        content.snp.makeConstraints { (v) in
            v.top.left.right.equalToSuperview()
            v.bottom.lessThanOrEqualToSuperview()
            v.width.equalTo(UIScreen.main.bounds.width)
        }
        
        scrollView.addTap { [weak self] (v) in
            guard v.superview != nil else { return }
            self?.hide()
        }
    }

    private func setupFilterOptions(preselect: String, options: [String], onSelected: ((String) -> Void)?) {
        let optionView = FilterOptionSelectorView(options: options, selected: preselect, selectionHandler: onSelected)
        content.addArrangedSubview(optionView)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        show()
    }
    
    private func show() {
        guard animatable == true else { return }
        self.layoutIfNeeded()
        content.transform = CGAffineTransform(translationX: 0, y: -self.content.height)
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
            self.content.transform = .identity
            self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }, completion: nil)
            
    }
    
    func hide() {
        guard animatable == true else { return }
        //        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.15, delay: 0.2, options: [.curveEaseOut]) {
            self.content.transform = CGAffineTransform(translationX: 0, y: -self.content.height)
            self.backgroundColor = .clear
            self.layoutIfNeeded()
        } completion: { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.removeFromSuperview()
                self.notifyComplete?()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

//extension FilterableTableViewController: TransactionHistoryBottomSheetDelegate {
//    func sendData(data: String, walletType: WalletType, selectedIndex: Int) {
//            self.filterOptionLabel.text = data
//            self.preselectedOption = data
//            self.onFilterOptionChanged?(data)
//            self.tableView.mj_header.beginRefreshing()
//    }
//}

