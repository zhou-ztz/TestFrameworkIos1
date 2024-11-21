import UIKit

class PopupMenuCell: UITableViewCell {
    
    var isShowSeparator : Bool = true {
        didSet{
            setNeedsDisplay()
        }
    }
    var separatorColor : UIColor = UIColor.lightGray{
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRect(x: 20, y: 10, width: 24, height: 24)
        self.textLabel?.textAlignment = .left
        
        if let frame = self.textLabel?.frame {
            self.textLabel?.frame = CGRect(x: frame.origin.x - 15, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if isShowSeparator == false {
            return
        }
        
        let bezierPath = UIBezierPath.init(rect: CGRect.init(x: 0, y: rect.size.height - 0.5, width: rect.size.width, height: 0.5))
        separatorColor.setFill()
        bezierPath.fill(with: CGBlendMode.normal, alpha: 1)
        bezierPath.close()
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isShowSeparator = true
        separatorColor = UIColor.lightGray
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
