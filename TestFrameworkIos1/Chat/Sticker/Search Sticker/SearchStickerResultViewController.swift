//
//  SearchStickerResultViewController.swift
//  Yippi
//
//  Created by ChuenWai on 17/02/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit


class SearchStickerResultViewController: SearchStickerResultBaseViewController {

    private var suggestedStickers: [Sticker] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func refresh() {
        defer {
            self.table.mj_header.endRefreshing()
        }
        self.table.removePlaceholderViews()
        self.table.mj_footer.makeHidden()
        let query = StickerSearchQuery(bundle_name: searchText, first: TSAppConfig.share.localInfo.limit, after: nil)
        YPApolloClient.fetch(query: query) { [weak self] (response, error) in
            guard let wself = self, error == nil, let responses = response?.data?.stickerSearch?.edges, let pageInfo = response?.data?.stickerSearch?.pageInfo else {
                self?.showError(msg: "please_retry_option".localized)
                return
            }

            if let error = response?.errors, error.count > 0 {
                wself.showError(msg: (error.first?.message).orEmpty)
                return
            }

            if responses.count <= 0 {
                wself.showEmptyResultView()
                return
            }
            wself.hideEmptyResultView()
            wself.stickerSearchResults = responses
            wself.after = pageInfo.endCursor
            wself.suggestedStickers.removeAll()
            if pageInfo.hasNextPage == false {
                wself.table.mj_footer.endRefreshingWithNoMoreData()
            }

        }
    }

    override func loadMore() {
        let query = StickerSearchQuery(bundle_name: searchText, first: TSAppConfig.share.localInfo.limit, after: after)
        YPApolloClient.fetch(query: query) { [weak self] (response, error) in
            guard let wself = self, error == nil, let responses = response?.data?.stickerSearch?.edges, let pageInfo = response?.data?.stickerSearch?.pageInfo else {
                self?.showError(msg: "please_retry_option".localized)
                return
            }

            if let error = response?.errors, error.count > 0 {
                wself.showError(msg: (error.first?.message).orEmpty)
                return
            }

            wself.stickerSearchResults += responses
            wself.after = pageInfo.endCursor
            if pageInfo.hasNextPage == false {
                wself.table.mj_footer.endRefreshingWithNoMoreData()
            } else {
                wself.table.mj_footer.endRefreshing()
            }

        }
    }

    override func getCellCount() -> Int {
        if suggestedStickers.isEmpty {
            return stickerSearchResults.count
        } else {
            return suggestedStickers.count
        }
    }

    override func getCell(cell: StickerTableCell, indexPath: IndexPath) -> StickerTableCell {

        if suggestedStickers.isEmpty {
            guard stickerSearchResults.count > indexPath.row else { return cell }
            let sticker = stickerSearchResults[indexPath.row]?.node
            cell.configureSticker(forSearch: sticker?.bundleId, bundleIcon: sticker?.bundleIcon, bundleName: sticker?.bundleName, description: sticker?.description, delegate: delegate)
        } else {
            cell.configureSticker(suggestedStickers[indexPath.row], delegate: delegate)
        }

        return cell
    }

    override func showEmptyResultView() {
        DispatchQueue.main.async {
            super.showEmptyResultView()
            self.getStickerSuggestion()
        }
    }

    private func getStickerSuggestion() {
        GetStickerByType.init(type: .new_sticker, limit: TSAppConfig.share.localInfo.limit, offset: 0, catId: nil).execute { [weak self] (model) in
            guard let self = self, let model = model, model.data.data.count > 0 else {
                return
            }
            self.table.removePlaceholderViews()
            self.suggestedStickers = model.data.data
            self.table.reloadData()
        } onError: { [weak self] (error) in
            guard let self = self else { return }
            switch error {
                case let .carriesMessage(reason, _, _): self.showError(msg: reason)
                case let .error(message, _): self.showError(msg: message)
                case let .violations(reason, _): self.showError(msg: reason)
                default: self.showError(msg: "please_retry_option".localized)
            }
            self.table.show(placeholderView: .emptyResult)
        }

    }

    private func showError(msg: String) {
        UIViewController.showBottomFloatingToast(with: msg, desc: "")
    }

    override func didSelectItem(at indexPath: IndexPath) {
        var bundleId: String?
        if suggestedStickers.isEmpty {
            bundleId = stickerSearchResults[indexPath.row]?.node?.bundleId

        } else {
            bundleId = suggestedStickers[indexPath.row].bundleID?.stringValue
        }

        self.onSelectStickerCell?(bundleId)
    }

}
