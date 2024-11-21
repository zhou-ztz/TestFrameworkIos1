//
//  FormController.swift
//  AppsFlyer
//
//  Created by Kit Foong on 29/05/2024.
//

import Foundation
import UIKit

protocol GetVoucherBottomViewDelegate: AnyObject {
    func selectePackage(_ package: VoucherPackage?)
}

class GetVoucherBottomView: TSViewController {
    @IBOutlet weak var grapperView: UIView!
    @IBOutlet weak var wrapView: UIView!
    @IBOutlet weak var voucherImage: UIImageView!
    @IBOutlet weak var voucherTitle: UILabel!
    @IBOutlet weak var voucherDescription: UILabel!
    @IBOutlet weak var rebateOffsetView: OffsetRebateView!
    @IBOutlet weak var packageTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var quantityView: UIStackView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var voucherBtn: UIButton!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    weak var delegate: GetVoucherBottomViewDelegate?
    
    var voucherDetails: VoucherDetailsResponse!
    var quantity: Int = 0
    var minQuantity: Int = 1
    var maxQuantity: Int = 0
    var packages: [VoucherPackage] = []
    var selectedPackage : VoucherPackage? = nil
    
    let columnLayout = LeftAlignFlowLayout(
        minimumInteritemSpacing: 15,
        minimumLineSpacing: 15,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        presetPackageValue(completion: {
            self.setupCollectionView()
        })
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.delegate?.selectePackage(nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update placeholder constraint
        self.collectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height + 20
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        grapperView.backgroundColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1)
        
        wrapView.layer.cornerRadius = 12.0
        voucherImage.layer.cornerRadius = 8.0

        if let imageUrlString = voucherDetails.imageURL?.first ?? voucherDetails.logoURL?.first {
            voucherImage.sd_setImage(with: URL(string: imageUrlString))
            voucherImage.contentMode = .scaleAspectFill
        } else {
            voucherImage.image = UIImage.set_image(named: "rl_placeholder")
            voucherImage.contentMode = .scaleToFill
        }
        
        voucherTitle.text = voucherDetails.name
        if let descriptionLong = voucherDetails.descriptionLong, !descriptionLong.isEmpty {
            voucherDescription.text = descriptionLong.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let descriptionShort = voucherDetails.description, !descriptionShort.isEmpty {
            voucherDescription.text = descriptionShort.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        rebateOffsetView.isHidden = packages.isEmpty
        rebateOffsetView.rebate = packages.first?.rebatePercentage
        rebateOffsetView.offset = packages.first?.offsetPercentage
        
        packageTitle.text = "text_select_package_with_value".localized.replacingOccurrences(of: "%s", with: packages.first?.offsetCurrency ?? "").uppercased()
        quantityLabel.text = "quantity".localized.uppercased()
        
        quantityView.isUserInteractionEnabled = false
        quantityView.backgroundColor = UIColor(hex: 0xF0F0F0)
        
        quantityView.layer.borderWidth = 1.0
        quantityView.layer.cornerRadius = 8.0
        quantityView.layer.borderColor = UIColor(hex: 0xE5E0EB).cgColor
        
        quantity = 1
        maxQuantity = packages.first?.maxQuantity ?? 1
        
        quantityTextField.text = quantity.description
        quantityTextField.keyboardType = .numberPad
        quantityTextField.isUserInteractionEnabled = false
        //quantityTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        minusButton.isEnabled = false
        plusButton.isEnabled = voucherDetails.type == "softpins"
        
        bottomView.layer.shadowColor = UIColor.lightGray.cgColor
        bottomView.layer.shadowOffset = CGSize(width: 0.0, height : -3.0)
        bottomView.layer.shadowOpacity = 0.2
        bottomView.layer.shadowRadius = 3
        
        voucherBtn.setTitle("rw_get_voucher".localized)
        voucherBtn.tintColor = UIColor(hex: 0xD1D1D1)
        voucherBtn.titleLabel?.textColor = UIColor(hex: 0x808080)
        
        voucherBtn.isUserInteractionEnabled = false
    }
    
    private func presetPackageValue(completion: (() -> Void)? = nil) {
        if selectedPackage != nil {
            if let index = selectedPackage?.selectedIndex, var package = packages[safe: index]  {
                package.isSelected = true
                packages[index] = package
            } else {
                for index in packages.indices {
                    if selectedPackage?.price != nil && packages[index].price == selectedPackage?.price {
                        packages[index].isSelected = true
                        break
                    }
                    
                    if selectedPackage?.minAmount != nil && packages[index].minAmount == selectedPackage?.minAmount {
                        packages[index].isSelected = true
                        break
                    }
                    
                    if selectedPackage?.maxAmount != nil && packages[index].maxAmount == selectedPackage?.maxAmount {
                        packages[index].isSelected = true
                        break
                    }
                }
            }
            
            quantity = selectedPackage?.quantity ?? minQuantity
        }
        
        updatePackageUI()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = columnLayout
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(PackageCollectionViewCell.nib(), forCellWithReuseIdentifier: PackageCollectionViewCell.cellIdentifier)
        
        packages = packages.sorted{ (obj1, obj2) -> Bool in
            if let price1 = obj1.price, let price2 = obj2.price {
                return price1.compare(price2, options: .numeric) == .orderedAscending
            }
            
            if let price1 = obj1.minAmount, let price2 = obj2.minAmount {
                return price1.compare(price2, options: .numeric) == .orderedAscending
            }
            
            if let price1 = obj1.maxAmount, let price2 = obj2.maxAmount {
                return price1.compare(price2, options: .numeric) == .orderedAscending
            }
            
            return false
        }
        
        collectionView.reloadData()
    }
    
    @IBAction func minusAction(_ sender: Any) {
        quantity -= 1
        updatePackageUI()
    }
    
    @IBAction func plusAction(_ sender: Any) {
        quantity += 1
        updatePackageUI()
    }
    
    @IBAction func getVoucherAction(_ sender: Any) {
        if let package = selectedPackage, let maxQuantity = package.maxQuantity, quantity > maxQuantity {
            self.showToast(with: "rw_payment_max_quantity_value".localized.replacingOccurrences(of: "%s", with: "\(maxQuantity)"), desc: "")
            return
        }
        
        self.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            self.delegate?.selectePackage(self.selectedPackage)
        })
    }
    
    private func updatePackageUI() {
        minusButton.isEnabled = quantity > minQuantity
        plusButton.isEnabled = quantity < maxQuantity
        
        quantityTextField.text = quantity.description
        
        if selectedPackage != nil {
            selectedPackage?.quantity = quantity
            
            quantityView.isUserInteractionEnabled = voucherDetails.type == "softpins"
            quantityView.backgroundColor = voucherDetails.type == "softpins" ? .white : UIColor(hex: 0xF0F0F0)
            quantityView.layer.borderColor = quantity >= maxQuantity ? AppTheme.primaryColor.cgColor : UIColor(hex: 0xE5E0EB).cgColor
            
            //errorView.isHidden = !(quantity >= maxQuantity)
            errorView.isHidden = false
            errorLabel.text = "rw_payment_max_quantity_value".localized.replacingOccurrences(of: "%s", with: "\(maxQuantity)")
            
            voucherBtn.tintColor = UIColor(hex: 0xED1A3B)
            voucherBtn.titleLabel?.textColor = .white
            
            voucherBtn.isUserInteractionEnabled = true
        } else {
            quantityView.isUserInteractionEnabled = false
            quantityView.backgroundColor = UIColor(hex: 0xF0F0F0)
            
            quantityView.layer.borderColor = UIColor(hex: 0xE5E0EB).cgColor
            errorView.isHidden = true
            
            voucherBtn.tintColor = UIColor(hex: 0xD1D1D1)
            voucherBtn.titleLabel?.textColor = UIColor(hex: 0x808080)
            
            voucherBtn.isUserInteractionEnabled = false
        }
        
        for (index, _) in packages.enumerated() {
            packages[index].isDisable = quantity > maxQuantity
        }
        
        collectionView.reloadData()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, text.containOnlyNumber, let quantity = Int(text), quantity > 0 {
            if quantity > maxQuantity {
                self.quantity = maxQuantity
            } else {
                self.quantity = quantity
            }
        } else {
            self.quantity = minQuantity
        }
        
        self.updatePackageUI()
    }
}

extension GetVoucherBottomView:  UICollectionViewDelegate, UICollectionViewDataSource {
    func labelWidth(_ text: String, _ height: CGFloat) -> CGFloat {
        let size = CGSize(width: 2000, height: height)
        let font = UIFont.systemFont(ofSize: 14)
        let attributes = [NSAttributedString.Key.font: font]
        let labelSize = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return labelSize.width + 25
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PackageCollectionViewCell.cellIdentifier, for: indexPath) as? PackageCollectionViewCell, let package = packages[safe: indexPath.row] {
            cell.updateUI(package: package)
            return cell
        }
        return UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if var package = packages[safe: indexPath.row] {
            for i in packages.indices { packages[i].isSelected = false }
            package.isSelected = !package.isSelected
            if package.isSelected {
                selectedPackage = package
                selectedPackage?.title = voucherDetails.name
                selectedPackage?.description = voucherDescription.text
                selectedPackage?.logoURL = voucherDetails.logoURL?.first
                selectedPackage?.imageURL = voucherDetails.imageURL?.first
                selectedPackage?.selectedIndex = indexPath.row
            } else {
                selectedPackage  = nil
            }
            packages[indexPath.row] = package
            updatePackageUI()
        }
    }
}

