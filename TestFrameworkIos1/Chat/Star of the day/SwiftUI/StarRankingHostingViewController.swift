//
//  StarRankingHostingViewController.swift
//  Yippi
//
//  Created by Jerry Ng on 22/06/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import SwiftUI

//class StarRankingHostingViewController: UIHostingController<LiveStarListView> {
//    
//    override init(rootView: LiveStarListView) {
//        super.init(rootView: rootView)
//        rootView.setOnBackHandler {
//            self.dismiss()
//        }
//    }
//    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return [.portrait, .portraitUpsideDown]
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.makeHidden()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.makeVisible()
//    }
//    
//    @objc required dynamic init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func dismiss() {
//        if let navVC = self.navigationController {
//            navVC.popViewController(animated: true)
//        } else {
//            dismiss(animated: true, completion: nil)
//        }
//    }
//}
