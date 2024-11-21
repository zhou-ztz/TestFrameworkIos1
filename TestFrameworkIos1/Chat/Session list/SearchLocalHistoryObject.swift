//
//  SearchLocalHIstoryObject.swift
//  Yippi
//
//  Created by Khoo on 06/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK

enum SearchLocalHistoryType : Int {
    case searchLocalHistoryTypeEntrance
    case searchLocalHistoryTypeContent
}

protocol SearchObjectRefresh: NSObjectProtocol {
    func refresh(_ object: SearchLocalHistoryObject?)
}

class SearchLocalHistoryObject: NSObject {
    var content: String?
    var uiHeight: CGFloat = 0.0
    var type: SearchLocalHistoryType!
    private(set) var message: NIMMessage?

    init(message: NIMMessage?) {
        super.init()
        self.message = message
        calculateHistoryItemHeight()
    }
    
    func calculateHistoryItemHeight() {
        guard let message = message else { return }
        let content = message.text
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: CGFloat(Constants.Layout.SearchCellContentFontSize))
        label.text = content
        label.lineBreakMode = .byTruncatingTail

        var itemTextSize: CGSize? = nil
        if let font = UIFont(name: "Helvetica Neue", size: 12.0) {
            itemTextSize = content?.boundingRect(with: CGSize(width: CGFloat(Constants.Layout.SearchCellContentMaxWidth * CGFloat(Constants.Layout.UISreenWidthScale)), height: CGFloat(Constants.Layout.MessageCellMaxHeight)), options: .usesLineFragmentOrigin, attributes: [
                NSAttributedString.Key.font: font
            ], context: nil).size
        }
        let labelHeight = max(Constants.Layout.SearchCellContentMinHeight, itemTextSize?.height ?? 0)
        let height = labelHeight + CGFloat(Constants.Layout.SearchCellContentTop) + CGFloat(Constants.Layout.SearchCellContentBottom)
        uiHeight = height
    }
}
