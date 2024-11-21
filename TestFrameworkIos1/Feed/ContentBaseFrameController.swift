//
//  ContentBaseFrameController.swift
//  Yippi
//
//  Created by Francis Yeap on 16/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit

class ContentBaseFrameController: TSViewController {
    
    let contentView: UIView = UIView()
    let scrollview: UIScrollView = UIScrollView().build {
        $0.backgroundColor = .white
        $0.decelerationRate = .fast
    }
    var tableStack = UIStackView().configure { _stack in
        _stack.distribution = .fill
        _stack.alignment = .fill
        _stack.spacing = 5
        _stack.axis = .vertical
        _stack.backgroundColor = .white
    }
    let mainStackView = UIStackView().configure { _stack in
        _stack.distribution = .fill
        _stack.alignment = .fill
        _stack.spacing = 5
        _stack.axis = .vertical
        _stack.backgroundColor = .white
    }
    
    weak var parentVC: UIViewController?
    
    override var navigationController: UINavigationController? {
        if super.navigationController == nil {
            if parentVC?.isKind(of: UINavigationController.self) == true {
                return parentVC as? UINavigationController
            }
            return parentVC?.navigationController
        }
        return super.navigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSkelViews()

        view.backgroundColor = .white
        
        scrollview.isScrollEnabled = false
    }
    
    func prepareSkelViews() {
        view.addSubview(scrollview)
        scrollview.bindToSafeEdges()
        
        scrollview.addSubview(mainStackView)
        mainStackView.bindToEdges()
        mainStackView.addArrangedSubview(contentView)

        contentView.snp.makeConstraints {
            $0.width.equalTo(self.view)
            $0.bottom.equalTo(self.view)
        }
    }

}
