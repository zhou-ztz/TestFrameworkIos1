//
//  IMTextSizeSettingViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/15.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit


class IMTextSizeSettingViewController: TSViewController {
    @IBOutlet weak var headImage1: UIImageView!
    @IBOutlet weak var bgImage1: UIImageView!
    @IBOutlet weak var textL1: UILabel!
    @IBOutlet weak var headImage2: UIImageView!
    @IBOutlet weak var bgImage2: UIImageView!
    @IBOutlet weak var textL2: UILabel!
    @IBOutlet weak var headImage3: UIImageView!
    @IBOutlet weak var bgImage3: UIImageView!
    @IBOutlet weak var textL3: UILabel!
    
    @IBOutlet weak var smartL: UILabel!
    @IBOutlet weak var standardL: UILabel!
    @IBOutlet weak var bigSizeL: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setCloseButton(backImage: true, titleStr: "title_text_size".localized)
        textL2.numberOfLines = 2
        textL3.numberOfLines = 0
        
        self.view.bringSubviewToFront(textL3)
        bgImage1.contentMode = .scaleToFill
        bgImage2.contentMode = .scaleToFill
        bgImage3.contentMode = .scaleToFill
        headImage1.image = UIImage.set_image(named: "text_size_imgAvatar")
        headImage2.image = UIImage.set_image(named: "text_size_imgAvatar")
        headImage3.image = UIImage.set_image(named: "text_size_imgAvatar")
        
        bgImage1.image = UIImage.set_image(named: "sender_bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 18), resizingMode: .stretch)
        bgImage2.image = UIImage.set_image(named: "receiver_bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 10), resizingMode: .stretch)
        bgImage3.image = UIImage.set_image(named: "receiver_bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 10), resizingMode: .stretch)
        slider.setMinimumTrackImage(UIImage.set_image(named: "textSizeSlider-1") ,  for: .normal)
        slider.setMaximumTrackImage(UIImage.set_image(named: "textSizeSlider-1"), for: .normal)
        
        let myTextSize = UserDefaults.standard.integer(forKey: "textSize")
     
        let fontSize = self.fontSize(roundValue: myTextSize)
        
        textL1.font = UIFont.systemFont(ofSize: fontSize)
        textL2.font = UIFont.systemFont(ofSize: fontSize)
        textL3.font = UIFont.systemFont(ofSize: fontSize)
        slider.setValue(Float(myTextSize), animated: false)
   
        smartL.font = UIFont.systemFont(ofSize: FontSize.defaultTextFontSize * 0.9 )
        standardL.font = UIFont.systemFont(ofSize: FontSize.defaultTextFontSize)
        bigSizeL.font = UIFont.systemFont(ofSize: FontSize.defaultTextFontSize * 1.4 )
       
        self.view.backgroundColor = AppTheme.inputContainerGrey
        
        let button = UIBarButtonItem(title: "done".localized, style: .plain, target: self, action: #selector(doneButtonDidTouchUp))
        button.tintColor = TSColor.main.theme
        navigationItem.rightBarButtonItems = [button]
    }
    
    @objc func doneButtonDidTouchUp()
    {
        let textSize = slider.value
        UserDefaults.standard.setValue(Int(textSize), forKey: "textSize")
        self.navigationController?.popViewController(animated: true)
    }


    func fontSize(roundValue: Int) -> CGFloat {
        var fontSize = FontSize.defaultTextFontSize
        switch roundValue {
            case 0:
                fontSize = fontSize  * 0.90
                break;
            case 1:
                fontSize = fontSize * 1
                break
            case 2:
                fontSize = fontSize * 1.10
                break
            case 3:
                fontSize = fontSize * 1.20
                break
            case 4:
                fontSize = fontSize * 1.30
                break
            case 5:
                fontSize = fontSize * 1.40
                break
            default:
                fontSize = fontSize * 1
                break
        }
        return fontSize
    }
    
    @IBAction func sliderValue(_ sender: UISlider) {
        
        let roundValue = roundf(sender.value/1)*1
        sender.value = roundValue
        let fontSize = self.fontSize(roundValue: Int(roundValue))
        textL1.font = UIFont.systemFont(ofSize: fontSize)
        textL2.font = UIFont.systemFont(ofSize: fontSize)
        textL3.font = UIFont.systemFont(ofSize: fontSize)
       
    }
    
   
    
}
