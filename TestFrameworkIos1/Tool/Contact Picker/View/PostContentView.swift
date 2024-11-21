//
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit
import SnapKit

class PostContentView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var postDescLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var labelStackView: UIStackView!
    
    private var _model: TSmessagePopModel?
    var model: TSmessagePopModel? {
        set {
            _model = newValue
            guard let value = newValue else {
                return
            }
            bodyLabel.text = value.owner
            
            if value.content.isEmpty {
                postContentLabel.text = "feed_no_desc".localized
            } else {
                HTMLManager.shared.removeHtmlTag(htmlString: value.content, completion: { [weak self] (content, _) in
                    guard let self = self else { return }
                    postContentLabel.text = content.removeNewLineChar()
                })
            }
            
            postDescLabel.text = value.noteContent
            switch value.contentType {
            case .url:
                if let url = URL(string: value.content) {
                    postDescLabel.text = url.host
                }
            default: break
            }
            //if !value.coverImage.isEmpty {
            imageView.sd_setImage(with: URL(string: value.coverImage), placeholderImage: UIImage.set_image(named: "default_image"), completed: nil)
            //} else {
            //    imageView.makeHidden()
            //}
            updateUI()
        }
        
        get {
            return _model
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
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PostContentView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shadowView.layer.cornerRadius = 4
        shadowView.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).cgColor
        shadowView.layer.borderWidth = 1
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.roundCorner(4)
        shadowView.backgroundColor = SmallColor().repostBackground
        bodyLabel.applyStyle(.bold(size: 14, color: AppTheme.black))
        postContentLabel.applyStyle(.regular(size: 12, color: NormalColor().minor))
        postDescLabel.applyStyle(.regular(size: 12, color: TSColor.main.theme))
        postDescLabel.numberOfLines = 2
        postContentLabel.numberOfLines = 2
        postContentLabel.lineBreakMode = .byTruncatingTail
        postDescLabel.lineBreakMode = .byWordWrapping
    }
    
    private func updateUI() {
        guard let model = _model else { return }
        switch model.contentType {
        case .url:
            bodyLabel.numberOfLines = 2
            bodyLabel.removeConstraints(bodyLabel.constraints)
            postContentLabel.isHidden = true
            postDescLabel.textColor = NormalColor().minor
        default:
            break
        }
        if model.content.isEmpty {
            postContentLabel.isHidden = true
            bodyLabel.removeConstraints(bodyLabel.constraints)
        }
        
        postDescLabel.isHidden = (postDescLabel.text ?? "").isEmpty
        postContentLabel.isHidden = (postContentLabel.text ?? "").isEmpty
    }
}
