//
//  MutiplePictureViewController.swift
//  Yippi
//
//  Created by ChuenWai on 23/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class MultiplePictureViewController: TSViewController {

    let pictureView = PicturesTrellisView()
    var index: Int = 0
    var pictureModel: PaidPictureModel = PaidPictureModel()
    var onPictureViewTapped: ((PictureViewer, Int, String) -> Void)?

    init(currentIndex: Int, pictureModel: PaidPictureModel) {
        super.init(nibName: nil, bundle: nil)

        self.index = currentIndex
        self.pictureModel = pictureModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(pictureView)
        pictureView.bindToEdges()

        pictureView.models = [pictureModel]
        pictureView.onTapPictureView = { [weak self] (trellis, tappedIndex, transitionId) in
            self?.onPictureViewTapped?(trellis, tappedIndex, transitionId)
        }
    }

}
