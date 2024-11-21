//
// Created by Francis Yeap on 04/12/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation
import YYText

enum TruncatableLabelShowStyle {
    case TruncatableLabelShowLess
    case TruncatableLabelShowMore
}
class TruncatableLabel: UIView {

    var numberOfLines: UInt = 3
    var aliasColor: UIColor = AppTheme.white
    var hashTagColor: UIColor = AppTheme.white
    var httpTagColor: UIColor = AppTheme.white
    
    private let stack = UIStackView().configure { v in
        v.axis = .vertical
        v.spacing = 2.0
        v.distribution = .equalSpacing
        v.alignment = .fill
        v.translatesAutoresizingMaskIntoConstraints = false
    }
    let label = YYLabel()
    let collapseViewWrapper = UIView()
    let collapsingLabel = UILabel()
    private(set) var customText = NSMutableAttributedString()
    var onUsernameTapped: ((String) -> Void)?
    var onHashTagTapped: ((String) -> Void)?
    var onHttpTagTapped: ((String) -> Void)?
    var onTextNumberOfLinesTapped: ((TruncatableLabelShowStyle) -> Void)?
    var onHeightChanged: EmptyClosure?
    
    var maximumHeight: CGFloat = UIScreen.main.bounds.height / 3
    
    let scrollView = UIScrollView().configure {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        addSubview(stack)
        stack.bindToEdges()
        
        stack.addArrangedSubview(scrollView)
        stack.addArrangedSubview(collapseViewWrapper)
        
        scrollView.addSubview(label)
        
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
    
        label.setContentHuggingPriority(.required, for: .vertical)
        label.numberOfLines = self.numberOfLines
        
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }

        collapseViewWrapper.addSubview(collapsingLabel)
        collapsingLabel.snp.makeConstraints { (v) in
            v.top.right.bottom.equalToSuperview()
            v.left.greaterThanOrEqualToSuperview()
        }
        collapseViewWrapper.isHidden = true

        collapsingLabel.text = "hide".localized
        collapsingLabel.textColor = AppTheme.white.withAlphaComponent(0.8)
        collapsingLabel.font = UIFont.boldSystemFont(ofSize: 12)

        collapsingLabel.addTap { [unowned self] (_) in
            self.label.numberOfLines = self.numberOfLines
            self.collapseViewWrapper.isHidden = self.label.numberOfLines > 0
            self.setAllowTruncation()
            self.layoutScrollView()
            self.onTextNumberOfLinesTapped?(.TruncatableLabelShowLess)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.preferredMaxLayoutWidth = stack.frame.width
        self.layoutScrollView()
    }


    func setText(text: String, textColor: UIColor = .white, allowTruncation: Bool = false) {
        customText = NSMutableAttributedString(string: text)
        customText.addAttributeTextColor(label.textColor, range: NSRange(text.startIndex..<text.endIndex, in: text))
        customText.yy_font = self.label.font.withSize(14)
        customText.yy_color = textColor

        self.label.numberOfLines = self.numberOfLines
        self.label.attributedText = customText
        self.collapseViewWrapper.isHidden = true

        prepareAlias(for: customText.string)
        prepareHashTags(for: customText.string)
        prepareHttpTag(for: customText.string)
        if allowTruncation { setAllowTruncation() }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func setAttributeText(attString: NSMutableAttributedString, textColor: UIColor = .white, allowTruncation: Bool = false) {
        customText = attString
        customText.addAttributeTextColor(textColor, range: NSRange(attString.string.startIndex..<attString.string.endIndex, in: attString.string))
        customText.yy_font = self.label.font.withSize(14)
        customText.yy_color = textColor
        
        self.label.numberOfLines = self.numberOfLines
        self.label.attributedText = customText
        self.collapseViewWrapper.isHidden = true

        prepareAlias(for: customText.string)
        prepareHashTags(for: customText.string)
        prepareHttpTag(for: customText.string)
        if allowTruncation { setAllowTruncation() }
        
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func prepareAlias(for text: String) {
        // By Kit Foong (Updated new Regex pattern, refer from Active Label. Previously didn't cater when got space for username)
        guard let regex = try? NSRegularExpression(pattern: "\\u00ad@((?:[^/]+?))\\u00ad", options: []) else { return }
        //guard let regex = try? NSRegularExpression(pattern: "@\\S\\w*", options: []) else { return }
        let matches = regex.enumerateMatches(in: text,
                range: NSRange(text.startIndex..<text.endIndex, in: text)
        ) { (matchResult, _, stop) -> () in
            guard let match = matchResult else { return }
            self.customText.yy_setTextHighlight(match.range, color: aliasColor, backgroundColor: .clear, tapAction: { [weak self] (v, username, range, _) -> () in
                self?.onUsernameTapped?(username.string.subString(with: range))
            })

            self.label.attributedText = self.customText
        }
    }

    private func prepareHashTags(for text: String) {
        guard let regex = try? NSRegularExpression(pattern: "#\\S\\w*", options: []) else { return }
        let matches = regex.enumerateMatches(in: text,
                range: NSRange(text.startIndex..<text.endIndex, in: text)
        ) { (matchResult, _, stop) -> () in
            guard let match = matchResult else { return }
            self.customText.yy_setTextHighlight(match.range, color: hashTagColor, backgroundColor: .clear, tapAction: { [weak self] (v, tags, range, _) -> () in
                self?.onHashTagTapped?(tags.string.subString(with: range))
            })

            self.label.attributedText = self.customText
        }
    }
    
    private func prepareHttpTag(for text: String) {
        guard let regex = try? NSRegularExpression(pattern: "((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)", options: []) else {
            return
        }
        let matches = regex.enumerateMatches(in: text,
                range: NSRange(text.startIndex..<text.endIndex, in: text)
        ) { (matchResult, _, stop) -> () in
            guard let match = matchResult else { return }
            self.customText.yy_setTextHighlight(match.range, color: httpTagColor, backgroundColor: .clear, tapAction: { [weak self] (v, tags, range, _) -> () in
                self?.onHttpTagTapped?(tags.string.subString(with: range))
            })

            self.label.attributedText = self.customText
        }
    }

    func setAllowTruncation() {
        let moretext = NSMutableAttributedString(string: " \("rw_text_expand".localized)")
        let highlight = YYTextHighlight()

        highlight.setColor(AppTheme.white)

        moretext.yy_setTextHighlight(highlight, range: moretext.yy_rangeOfAll())
        moretext.setAllTextFont(font: self.label.font)
        moretext.yy_setColor(AppTheme.feedExpandBlue, range: moretext.yy_rangeOfAll())

        let moreAttachment = YYLabel()
        moreAttachment.attributedText = moretext
        moreAttachment.sizeToFit()

        let expandtruncationToken = NSMutableAttributedString.yy_attachmentString(withContent: moreAttachment, contentMode: .center, attachmentSize: moreAttachment.frame.size, alignTo: self.label.font, alignment: .center)
        
        highlight.tapAction = { [weak self] (_, text, _, _) in
            guard let self = self else { return }
            if self.label.numberOfLines == 0 {
                self.label.truncationToken = expandtruncationToken
                self.label.numberOfLines = self.numberOfLines
            } else {
                self.label.numberOfLines = 0
                self.label.layoutIfNeeded()
                self.label.truncationToken = nil
            }
            
            self.collapseViewWrapper.isHidden = self.label.numberOfLines > 0
            self.onHeightChanged?()
            self.layoutScrollView()
            self.onTextNumberOfLinesTapped?(.TruncatableLabelShowMore)
        }
        self.label.truncationToken = expandtruncationToken
    }

    
    private func layoutScrollView() {
        self.scrollView.snp.updateConstraints {
            let labelHeight = self.label.text?.height(withConstrainedWidth: self.scrollView.bounds.width, font: self.label.font) ?? 0.0
            var finalHeight: CGFloat = 0.0
            
            if self.label.numberOfLines == 0 {
                finalHeight = labelHeight
            } else {
                finalHeight = min(labelHeight, 40)
            }
            
            let height = min(finalHeight, maximumHeight)
            $0.height.equalTo(height)
        }
    }
}
