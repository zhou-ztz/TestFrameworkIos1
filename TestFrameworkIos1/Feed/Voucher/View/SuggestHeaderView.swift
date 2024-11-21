//
//  SuggestHeaderView.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 22/07/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
protocol SuggestSearchViewDelegate: class {
    func searchDidClickReturn(text: String)
    func searchDidClickCancel()
}


class SuggestHeaderView: UIView {

    @IBOutlet weak var serchView: UIView!
    @IBOutlet weak var suggestedVoucher: UILabel!
    @IBOutlet var view: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    weak var delegate: SuggestSearchViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        Bundle.main.loadNibNamed(String(describing: SuggestHeaderView.self), owner: self, options: nil)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
        
        backgroundColor = .white
        
        searchTextField.delegate = self
        searchTextField.font = UIFont.systemFont(ofSize: 14)
        searchTextField.textColor = TSColor.main.content
        searchTextField.placeholder = "placeholder_search_message".localized
        searchTextField.layer.cornerRadius = 18
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.returnKeyType = .search
        searchTextField.leftViewMode = .always
        searchTextField.clearButtonMode = .whileEditing
        
    }
    
    func updateLabelText(isSuggest: Int) {
        if isSuggest == 1 {
            suggestedVoucher.text = "rw_text_suggested_vouchers".localized
        } else {
            suggestedVoucher.text = "text_result".localized
        }
        setNeedsDisplay()
        layoutIfNeeded()
    }
}

extension SuggestHeaderView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.searchDidClickReturn(text: textField.text ?? "")
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, text.count == 0 {
            self.delegate?.searchDidClickCancel()
        }
        
    }
}
