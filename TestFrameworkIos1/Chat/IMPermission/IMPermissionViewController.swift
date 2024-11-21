//
//  IMPermissionViewController.swift
//  Yippi
//
//  Created by Kit Foong on 26/04/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class IMPermissionViewController: TSViewController {

    @IBOutlet weak var permissionImageView: UIImageView!
    @IBOutlet weak var permissionTitleLabel: UILabel!
    @IBOutlet weak var permissionDescLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    
    var permissionType: TSPermissionType
    
    init(permissionType: TSPermissionType) {
        self.permissionType = permissionType
        super.init(nibName: "IMPermissionViewController", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        switch permissionType {
        case .album:
            permissionImageView.image = UIImage.set_image(named: "album_no_access")
            permissionTitleLabel.text = "title_album_denied".localized
            break
        case .audio:
            break
        case .camera:
            permissionImageView.image = UIImage.set_image(named: "camera_no_access")
            permissionTitleLabel.text = "title_camera_denied".localized
            break
        case .cameraAlbum:
            break
        case .contacts:
            break
        case .location:
            permissionImageView.image = UIImage.set_image(named: "location_no_access")
            permissionTitleLabel.text = "title_location_denied".localized
            break
        case .videoCall:
            break
        default:
            break
        }
        
        settingButton.applyStyle(.custom(text: "title_go_to_setting".localized, textColor: TSColor.main.white, backgroundColor: TSColor.main.theme, cornerRadius: 25))
    }
    
    @IBAction func settingButtonAction(_ sender: Any) {
        let url = URL(string: UIApplication.openSettingsURLString)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
}
