//
//  SelectionInputPricesView.swift
//  Yippi
//
//  Created by francis on 25/06/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit

protocol selectionInputDelegate: NSObjectProtocol {
    /// 返回用户输入字符串
    /// - 返回的字符串会过滤一次。见textFieldChange方法
    /// - Parameter input: 输入的字符串
    func userInput(input: String?)
}

class SelectionInputPricesView: UIView {
    
    weak var inputDelegate: selectionInputDelegate? = nil
    private let headerLabel = UILabel().configure {
        $0.setFontSize(with: 14.0, weight: .norm)
        $0.textColor = UIColor(red: 74, green: 74, blue: 74)
    }
    
    private var inputPrices: [Int] = []
    private var inputStackView = UIStackView().configure { stackview in
        stackview.spacing = 16.0
        stackview.axis = .horizontal
        stackview.distribution = .fillEqually
        stackview.alignment = .center
    }
    
    private var containerView = UIStackView().configure { stackview in
        stackview.spacing = 9.0
        stackview.axis = .vertical
        stackview.alignment = .fill
        stackview.distribution = .fillProportionally
    }
    
    private var amountView = UIStackView().configure { stackview in
        stackview.spacing = 16
        stackview.axis = .horizontal
        stackview.distribution = .equalSpacing
        stackview.alignment = .center
    }
    private let remainingYippsView = RemainingYippsView()

    private var buttons: [TSButton] = []
    private var handler: ((_ selectedPrice: Int) -> ())?
    
    private(set) var selectedInputIndex: Int?
    
    /// 自定义金额视图
    let customMoneyView: UIView = UIView().configure {
        $0.backgroundColor = .white
    }
    var moneyTextfiled = UITextField().configure {
        $0.placeholder = "0.00".localized
        //$0.text = "0.00"
        $0.keyboardType = .numberPad
        $0.textAlignment = .left
        $0.textColor = TSColor.normal.blackTitle
        $0.font = UIFont.systemFont(ofSize: 38)
        $0.addTarget(self, action: #selector(textFieldChange(_:)), for: .allEditingEvents)
    }
    
    init(inputPrices: [Int] = [1,2,5,10],
         handler: ((_ price: Int) -> ())? ) {
        
        self.inputPrices = inputPrices
        self.handler = handler
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = .white
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(16)
            $0.right.bottom.equalToSuperview().offset(-16)
        }
        
        containerView.addArrangedSubview(amountView)
        amountView.addArrangedSubview(headerLabel)
        headerLabel.snp.makeConstraints {
            $0.left.equalTo(10)
        }
        headerLabel.text = "text_amount".localized
        containerView.addArrangedSubview(customMoneyView)
        containerView.addArrangedSubview(inputStackView)
        customMoneyView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(53)
        }
        customMoneyView.addSubview(moneyTextfiled)
        moneyTextfiled.delegate = self
        moneyTextfiled.snp.makeConstraints {
            $0.left.equalTo(10)
            $0.right.equalTo(-24)
            $0.top.equalTo(5)
            $0.bottom.equalTo(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareButtons() {
        inputStackView.removeAllArrangedSubviews()
        buttons = []
        
        var index = 0
        self.inputPrices.forEach ({ [weak self] input in
            defer { index += 1 }
            let button = TSButton(type: .custom)
            button.tag = index
            button.setTitle("\(input)", for: .normal)
            
            button.roundCorner(15)
            //button.layer.borderWidth = 1
            
            button.addTap(action: { [weak self] (_) in
                self?.handler?(button.tag)
                self?.select(index: button.tag)
                
            })
            
            buttons.append(button)
            inputStackView.addArrangedSubview(button)
        })
        
        unSelectAll()
    }
    
    func showRemainingYipps(handler: EmptyClosure?) {
        amountView.addArrangedSubview(remainingYippsView)
        remainingYippsView.addAction {
            handler?()
        }
    }
    
    func refreshRemainingYipps() {
        remainingYippsView.refreshBalance()
    }
    
    func hideHeader() {
        headerLabel.makeHidden()
    }
    
    func unSelectAll() {
        selectedInputIndex = nil
        
        buttons.forEach({ button in
            //button.layer.borderColor = TSColor.normal.imagePlaceholder.cgColor
            button.backgroundColor = UIColor(red: 249, green: 249, blue: 249)
            button.setTitleColor(UIColor(red: 184, green: 184, blue: 184), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        })
    }
    
    func select(index: Int) {
        unSelectAll()
        selectedInputIndex = index
        
        let button = buttons[index]
        button.layer.borderColor = AppTheme.sunflowerYellow.cgColor
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = TSColor.main.theme
    }
    
    
    /// 过滤textField输入字符串，做返回处理
    /// - 字符串首字符为0，点击textfield第一次获得的""，以及非数字字符，代理返回为nil
    /// - 满足👆条件情况下，字符数大于8删除首字符（因为是做金额计算，不做限制会出bug）
    /// - Parameter changetext: 变动的textfield
    @objc func textFieldChange(_ changetext: UITextField) {
        
        var input = changetext.text
        //有”，“先去掉
        if let text = changetext.text, text.contains(",") {
            input = text.replacingOccurrences(of: ",", with: "")
        }
        self.inputDelegate?.userInput(input: input)
    }
    
}

extension SelectionInputPricesView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        
        var newText = oldText.replacingCharacters(in: r, with: string)
        //有”，“先去掉
        if newText.contains(",") {
            let currentText = newText.replacingOccurrences(of: ",", with: "")
            newText = currentText
        }
        
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        //小数点的个数
        let numberOfDots = newText.components(separatedBy: ".").count - 1
        
        //防止首位为0
        let numbers = newText.components(separatedBy: ".")
        if numbers.count >= 1 {
            if let str = numbers.first, str.count >= 2, let index = str.first , index == "0"{
                return false
            }
        }
        
        //第一次进来
        if !newText.contains(".") && oldText.count == 0 {
            let text = (Double(newText) ?? 0) / 100.00
            textField.text = text.tostring(decimal: 2, grouping: false)
            self.handler?(-1)
            return false
        }

        if let dotIndex = newText.index(of: ".") {
            let num = newText.distance(from: dotIndex, to: newText.endIndex) - 1
            if num >= 3 {
                let text = (Double(newText) ?? 0) * 10.00
                textField.text = text.tostring(decimal: 2)
                self.handler?(-1)
                return false
            }else if num < 2{
                let text = (Double(newText) ?? 0) / 10.00
                textField.text = text.tostring(decimal: 2)
                self.handler?(-1)
                return false
            }else if num == 2 { //在小数点前删除、插入数字时，需要处理 ”，“
                let text = Double(newText) ?? 0
                textField.text = text.tostring(decimal: 2)
                self.handler?(-1)
                return false
            }
        }
        
        
        let numberOfDecimalDigits: Int
        if let dotIndex = newText.index(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }
        
        return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
    }
    
}

class RemainingYippsView: UIView {
    
    private var containerView = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 6
        $0.alignment = .center
    }
    
    private let yippsIcon = UIImageView(image: UIImage.set_image(named: "ic_total_tips"))
    private let amountLabel = UILabel().configure {
        $0.applyStyle(.semibold(size: 14, color: .black))
    }
    private let nextIcon = UIImageView(image: UIImage.set_image(named: "ic_arrow_next")).configure {
        $0.tintColor = .black
    }
    
    init() {
        super.init(frame: .zero)
        addSubview(containerView)
        containerView.bindToEdges()
        
        containerView.addArrangedSubview(yippsIcon)
        yippsIcon.snp.makeConstraints { $0.height.width.equalTo(15) }
        containerView.addArrangedSubview(amountLabel)
        containerView.addArrangedSubview(nextIcon)
        
        amountLabel.text = CurrentUserSessionInfo!.yippsTotal.tostring(decimal: 2) + " " + TSAppConfig.share.localInfo.goldName
    }
    
    func refreshBalance() {
        amountLabel.text = CurrentUserSessionInfo!.yippsTotal.tostring(decimal: 2) + " " + TSAppConfig.share.localInfo.goldName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
