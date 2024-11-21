//
//  PopupContentView.swift
//  Yippi
//
//  Created by Francis Yeap on 28/01/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class PopupContentView: UIView {

    @IBOutlet var container: UIView!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    
    init(title: String = "", desc: String = "", image: UIImage? = nil, buttonTitle: String) {
        super.init(frame: .zero)
        
        commonInit()
        
        titleLabel.text = title
        descTextView.text = desc
        descTextView.isScrollEnabled = true
        
        DispatchQueue.main.async {
            self.descTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        }
        
        if let image = image {
            imageView.image = image
        } else {
            imageContainer.makeHidden()
        }
        
        button.setTitle(buttonTitle, for: .normal)
    }
    
    func setButtonAction(_ handler: @escaping EmptyClosure) {
        button.removeGestures()
        
        button.addTap { (_) in
            handler()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(String(describing: PopupContentView.self), owner: self, options: nil)
        container.frame = self.bounds
        container.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(container)
        
        button.roundCorner(25)
        button.setBackgroundColor(TSColor.main.theme, for: .normal)
        imageView.contentMode = .scaleAspectFit
    }
    

}
