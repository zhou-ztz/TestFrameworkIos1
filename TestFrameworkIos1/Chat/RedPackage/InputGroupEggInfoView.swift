//
//  InputGroupEggInfoView.swift
//  Yippi
//
//  Created by francis on 25/06/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class InputGroupEggInfoView: UIView {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var randomLabel: UILabel!
    
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var isRandomSwitch: UISwitch!
    @IBOutlet var view: UIView!
    
    var changedHandler: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        self.frame = view.frame
        addSubview(view)
        
        isRandomSwitch.dropShadow()
        quantityTextField.keyboardType = .numberPad
        
        quantityLabel.text = "quantity".localized
        randomLabel.text = "text_random".localized
        quantityTextField.textAlignment = .right
        quantityTextField.placeholder = "enter_quantity".localized
        
        quantityTextField.add(event: .editingChanged) { [weak self] in
            self?.changedHandler?()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isRandomSwitch.roundCorner(isRandomSwitch.bounds.size.height / 2)
    }
    
    func reset() {
        isRandomSwitch.setOn(false, animated: true)
        quantityTextField.text = ""
    }
    
}

