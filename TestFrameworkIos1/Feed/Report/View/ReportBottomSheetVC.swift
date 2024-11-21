//
//  ReportBottomSheetVC.swift
//  Yippi
//
//  Created by Ng Kit Foong on 21/09/2022.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit

class ReportBottomSheetVC: TSViewController {
    @IBOutlet weak var reportTitle: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var reportCategory : [ReportTypeEntity] = []
    weak var delegate: ReportBottomSheetDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.roundCorners([.topLeft, .topRight], radius: 10)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        closeBtn.setTitle("", for: .normal)
        reportTitle.text = "report_bottom_sheet_title".localized
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ReportBottomSheetVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportCategory.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReportCategoryTableViewCell.cellIdentifier, for: indexPath) as! ReportCategoryTableViewCell
        cell.configure(with: reportCategory[indexPath.row].localiseKey)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.sendData(data: reportCategory[indexPath.row].localiseKey)
        self.dismiss(animated: true, completion: nil)
    }
}
