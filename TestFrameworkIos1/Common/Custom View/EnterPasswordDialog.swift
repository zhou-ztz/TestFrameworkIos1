// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit


@objcMembers
@objc public class EnterPasswordDialog: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    fileprivate let dialogTitle: String
    fileprivate let message: String
    fileprivate let buttonText: String
    fileprivate let buttonAction: DidEnterPasswordClosure?
    weak var popup: TSAlertController?
    
    init(title: String, message: String, buttonText: String, buttonAction: DidEnterPasswordClosure?) {
        self.dialogTitle = title
        self.message = message
        self.buttonText = buttonText
        self.buttonAction = buttonAction
        
        super.init(nibName: "EnterPasswordDialog", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    fileprivate func setupView() {
        titleLabel.text = dialogTitle
        detailsLabel.text = message
        
        titleLabel.applyStyle(.semibold(size: 21, color: AppTheme.red))
        detailsLabel.applyStyle(.regular(size: 14, color: AppTheme.darkGrey))
        submitButton.applyStyle(.default(text: buttonText, color: AppTheme.secondaryColor))
        submitButton.roundCorner(submitButton.bounds.height / 2)
        backgroundView.roundCorner(18)
        
        passwordTextfield.isSecureTextEntry = true
        passwordTextfield.becomeFirstResponder()
    }

    @IBAction func submitButtonClicked(_ sender: Any) {
        self.buttonAction?(passwordTextfield.text ?? "")
        popup?.dismiss()
    }
}



