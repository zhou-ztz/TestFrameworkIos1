//
//  SearchArtistResultViewController.swift
//  Yippi
//
//  Created by ChuenWai on 17/02/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class SearchArtistResultViewController: SearchStickerResultBaseViewController {

    private var suggestedArtists: [Sticker] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func refresh() {
        defer {
            self.table.mj_header.endRefreshing()
        }
        self.table.mj_footer.makeHidden()
        self.table.removePlaceholderViews()
        let query = ArtistSearchQuery(artist_name: searchText, first: TSAppConfig.share.localInfo.limit, after: nil)
        YPApolloClient.fetch(query: query) { [weak self] (response, error) in
            guard let wself = self, error == nil, let results = response?.data?.artistSearch?.edges, let pageInfo = response?.data?.artistSearch?.pageInfo else {
                self?.showError(msg: "please_retry_option".localized)
                return
            }

            if let error = response?.errors, error.count > 0 {
                wself.showError(msg: (error.first?.message).orEmpty)
                return
            }

            if results.count <= 0 {
                wself.showEmptyResultView()
                return
            }
            wself.hideEmptyResultView()
            wself.artistSearchResults = results
            wself.after = pageInfo.endCursor
            wself.suggestedArtists.removeAll()
            if pageInfo.hasNextPage == false {
                wself.table.mj_footer.endRefreshingWithNoMoreData()
            }

        }
    }

    override func loadMore() {
        let query = ArtistSearchQuery(artist_name: searchText, first: TSAppConfig.share.localInfo.limit, after: after)
        YPApolloClient.fetch(query: query) { [weak self] (response, error) in
            guard let wself = self, error == nil, let results = response?.data?.artistSearch?.edges, let pageInfo = response?.data?.artistSearch?.pageInfo else {
                self?.showError(msg: "please_retry_option".localized)
                return
            }

            if let error = response?.errors, error.count > 0 {
                wself.showError(msg: (error.first?.message).orEmpty)
                return
            }

            wself.artistSearchResults += results
            wself.after = pageInfo.endCursor
            if pageInfo.hasNextPage == false {
                wself.table.mj_footer.endRefreshingWithNoMoreData()
            } else {
                wself.table.mj_footer.endRefreshing()
            }
        }
    }

    override func getCellCount() -> Int {
        if suggestedArtists.isEmpty {
            return artistSearchResults.count
        } else {
            return suggestedArtists.count
        }
    }

    override func getCell(cell: StickerTableCell, indexPath: IndexPath) -> StickerTableCell {

        if suggestedArtists.isEmpty {
            guard artistSearchResults.count > indexPath.row else { return cell}
            let artist = artistSearchResults[indexPath.row]?.node
            cell.configureArtist(forSearch: artist?.artistId, artistName: artist?.artistName, stickerCount: artist?.stickerSet, delegate: delegate)
        } else {
            cell.configureArtist(suggestedArtists[indexPath.row], delegate: delegate)
        }

        return cell
    }

    override func showEmptyResultView() {
        DispatchQueue.main.async {
            super.showEmptyResultView()
            self.getArtistSuggestion()
        }
    }

    private func getArtistSuggestion() {
        GetStickerByType.init(type: .new_artist, limit: 10, offset: 0, catId: nil).execute { [weak self] (model) in
            guard let self = self, let model = model, model.data.data.count > 0 else {
                return
            }
            self.table.removePlaceholderViews()
            self.suggestedArtists = model.data.data
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
        var artistId: String?
        var artistName: String?

        if suggestedArtists.isEmpty {
            artistId = artistSearchResults[indexPath.row]?.node?.artistId
            artistName =  artistSearchResults[indexPath.row]?.node?.artistName
        } else {
            artistId = suggestedArtists[indexPath.row].artistID?.stringValue
            artistName =  suggestedArtists[indexPath.row].artistName
        }

        self.onSelectArtistCell?(artistId, artistName)
    }

}
