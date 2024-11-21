//
//  TeenPinViewController.swift
//  Yippi
//
//  Created by Kit Foong on 11/03/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class TeenPinViewController: TSViewController {
    @IBOutlet weak var teenPinTitle: UILabel!
    @IBOutlet weak var teenPinUIView: UIView!
    
//    private let pinView: SecurityPinView = SecurityPinView(codeLength: 3)
    
    private let lblError: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 12, color: .red))
        $0.textAlignment = .center
        $0.makeHidden()
    }
    
    var onGetSecurityPin: ((String) -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
//        pinView.clear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        pinView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        pinView.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        setUI()
    }
    
    func setUI() {
        teenPinTitle.text = UserDefaults.teenModeIsEnable ? "security_pin_enter_current_pin".localized : "security_pin_set_new_pin".localized
        
//        teenPinUIView.addSubview(pinView)
//        teenPinUIView.addSubview(lblError)
//        
//        pinView.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.centerY.equalToSuperview()
//        }
//        
//        lblError.snp.makeConstraints {
//            $0.top.equalTo(pinView.snp.bottom).offset(16)
//            $0.centerX.equalToSuperview()
//        }
//        
//        pinView.onCompleteHandler = { [weak self] code in
//            guard let self = self else { return }
//            if UserDefaults.teenModeIsEnable {                
//                if UserDefaults.teenModePassword != code {
//                    self.onShowError("error_password_incorrect".localized)
//                    return
//                }
//                
//                UserDefaults.teenModePassword = nil
//                UserDefaults.teenModeIsEnable = false
//            } else {
//                UserDefaults.teenModePassword = code
//                UserDefaults.teenModeIsEnable = true
//            }
//            self.onGetSecurityPin?(code)
//            self.navigationController?.popViewController(animated: true)
//        }
//        
        onHideError()
    }
    
    func onShowError(_ error: String) {
        Device.vibrate()
//        pinView.clear()
        lblError.text = error
        lblError.makeVisible()
    }
    
    func onHideError() {
        lblError.text = nil
        lblError.makeHidden()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
//        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRect = keyboardFrame.cgRectValue
//            let bottomMargin = keyboardRect.height + 16
//        }
    }
}
