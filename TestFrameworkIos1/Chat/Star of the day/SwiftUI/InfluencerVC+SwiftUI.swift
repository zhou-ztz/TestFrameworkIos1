//
//  InfluencerVC+SwiftUI.swift
//  Yippi
//
//  Created by Jerry Ng on 23/06/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import SwiftUI

struct SwiftUIInfluencerVC: UIViewControllerRepresentable {
    
   // @EnvironmentObject var starRankingViewModel: StarRankingViewModel
    
    func makeUIViewController(context: Context) -> some UIViewController {
//        let vc = InfluencerContainerVC()
//        vc.onRootScrollViewScrolled = { yOffset in
//            self.starRankingViewModel.rankYOffset = yOffset
//            let colorOffset = self.starRankingViewModel.rankYOffset / (((UIScreen.main.bounds.width / 3) * 2) - 52 - (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0))
//            self.starRankingViewModel.navigationViewOpacity = Double(colorOffset)
//        }
//        return vc.fullScreenRepresentation
        return UIViewController().fullScreenRepresentation
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
      //  Coordinator(viewController: self, model: self.starRankingViewModel)
    }
    
    class Coordinator: NSObject {
//        var viewController: SwiftUIInfluencerVC
//        var model: StarRankingViewModel
//        
//        init(viewController: SwiftUIInfluencerVC, model: StarRankingViewModel) {
//            self.viewController = viewController
//            self.model = model
//        }
    }
}
