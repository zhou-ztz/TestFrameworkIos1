//
//  BaseRecorderContainer.swift
//  Yippi
//
//  Created by Yong Tze Ling on 13/11/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import YYWebImage
import OpenGLES

class BaseRecorderContainer: UIView {
    
    weak var delegate: MiniVideoRecordContainerDelegate?
    
    var isContainerHidden: Bool = false {
        didSet {
            self.container.isHidden = isContainerHidden
        }
    }
    
    var speed: CGFloat = 1.0
    var zoomFactor: CGFloat = 1.0
    var timer: Int = 0
    var maxDuration: CGFloat = 15.0
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(container)
    
        container.bindToEdges()
        
        container.addSubview(stackview)
        container.addSubview(closeButton)
        container.addSubview(albumButton)
        
        let focusGesture = UITapGestureRecognizer(target: self, action: #selector(focusGestureRecogniser(_:)))
        focusGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(focusGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc func flipDidTapped() {
        
        self.delegate?.flipButtonDidTapped()
    }
    
    @objc func flashDidTapped(_ sender: UIButton) {
        self.delegate?.flashButtonDidTapped()
    }
    
    @objc func timerDidTapped(_ sender: UIButton) {
    
        switch timer {
        case 0:
            timer = 3
            sender.setImage(UIImage.set_image(named: "ic_timer_3s"), for: .normal)
        case 3:
            timer = 7
            sender.setImage(UIImage.set_image(named: "ic_timer_7s"), for: .normal)
        default:
            timer = 0
            sender.setImage(UIImage.set_image(named: "ic_timer_video"), for: .normal)
        }
    }
    
    @objc private func focusGestureRecogniser(_ recognizer: UITapGestureRecognizer) {
        //对焦
        let point = recognizer.location(in: self)
        self.delegate?.focusbuttonDidTapped(point)
        focusView.center = point
        focusView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        self.addSubview(focusView)

        UIView.animate(withDuration: 0.5, animations: {
            self.focusView.transform = .identity
        }) { _ in
            self.focusView.removeFromSuperview()
        }
    }
    
    @objc func durationDidTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            maxDuration = 60
        } else {
            maxDuration = 15
        }
        selectedDurationLabel.text = String(format: "mv_creator_display_selected_video_length".localized, Int(maxDuration).stringValue)
        
        self.delegate?.durationButtonDidTapped()
        
        if selectedDurationLabel.superview != nil {
            return
        }
        self.addSubview(selectedDurationLabel)
        selectedDurationLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.selectedDurationLabel.removeFromSuperview()
        }
    }
    
    @objc func closeButtonDidTapped() {
        self.delegate?.closebuttonDidTapped(self.progressBar.hasProgress == true)
    }
    
    func setupRecorder() {

    }
    
    func countdownTimerChecker(countDownStart: () -> Void,
                               countDownEnd: @escaping () -> Void ) {
        guard self.timer > 0 else {
            countDownEnd()
            return
        }
        
        countDownStart()
        
        var countDown = self.timer
        self.addSubview(countdownLabel)
        countdownLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        showCountdownAnimation(countDown)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            
            guard let self = self else { return }
            
            if countDown == 1 {
                timer.invalidate()
                self.countdownLabel.removeFromSuperview()
                countDownEnd()
            } else {
                countDown -= 1
                self.showCountdownAnimation(countDown)
            }
        }
    }
    
    private func showCountdownAnimation(_ countDown: Int) {
        self.countdownLabel.text = "\(countDown)"

        UIView.animate(withDuration: 0.5, animations: {
            self.countdownLabel.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        }) { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.countdownLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
            })
        }
    }
    
    private func startAuthorization() {
    
    }
    // MARK: -
    
//    var recorder: IESMMRecoder?

    
//    let previewView: UIView = UIView()
    
    lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var progressBar: MarkableProgressView = {
        let bar = MarkableProgressView(frame: .zero)
        bar.roundCorner(3.5)
        return bar
    }()
    
    lazy var flipButton: MVButton = {
        let button = MVButton(title: "mv_creator_action_flip_camera".localized, image: UIImage.set_image(named: "ic_change_camera"))
        button.addTarget(self, action: #selector(flipDidTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var speedButton: MVButton = {
        let button = MVButton(title: "mv_creator_action_speed".localized, image: UIImage.set_image(named: "ic_speed_off"))
        button.setImage(UIImage.set_image(named: "ic_speed_on"), for: .selected)
        button.addAction { [weak self] in
            button.isSelected = !button.isSelected
            self?.speedSegmentControl.isHidden = !button.isSelected
        }
        return button
    }()

    lazy var timerButton: MVButton = {
        let button = MVButton(title: "mv_creator_action_timer".localized, image: UIImage.set_image(named: "ic_timer_video"))
        button.addTarget(self, action: #selector(timerDidTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var flashButton: MVButton = {
        let button = MVButton(title: "mv_creator_action_flash".localized, image: UIImage.set_image(named: "ic_flash_off"))
        button.setImage(UIImage.set_image(named: "ic_flash_on"), for: .selected)
        button.addTarget(self, action: #selector(flashDidTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var durationButton: MVButton = {
        let button = MVButton(title: "mv_creator_action_video_length".localized, image: UIImage.set_image(named: "ic_length_15"))
        button.setImage(UIImage.set_image(named: "ic_length_60"), for: .selected)
        button.addTarget(self, action: #selector(durationDidTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var stackview: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.alignment = .fill
        stackview.distribution = .fillEqually
        stackview.spacing = 10
        return stackview
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.set_image(named: "ic_close_shadow"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var albumButton: UIButton = {
        let button = TSShareButton(normalImage: UIImage.set_image(named: "ic_image_picker")!, title: "mv_creator_action_album".localized, titleFont: 10, titleColor: .white)
        button.addAction { [weak self] in
            self?.delegate?.albumButtonDidTapped()
        }
        return button
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.set_image(named: "ic_done"), for: .normal)
        button.addAction { [weak self] in
            self?.delegate?.editButtonDidTapped()
        }
        return button
    }()
    
    lazy var editStackView: UIStackView = {
       let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.distribution = .fillEqually
        stackview.alignment = .center
        stackview.isHidden = true
        return stackview
    }()
    
    
    lazy var speedSegmentControl: SpeedSegmentControl = {
        let control = SpeedSegmentControl()
        control.isHidden = !self.speedButton.isSelected
        return control
    }()
    
    lazy var focusView: UIImageView = {
        let view = UIImageView(image: UIImage.set_image(named: "ico_video_focusing"))
        view.contentMode = .center
        return view
    }()
    
    lazy var countdownLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 100)
        label.textColor = .white
        return label
    }()
    
    lazy var videoDurationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.isHidden = true
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 0.4
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.masksToBounds = false
        return label
    }()

    lazy var selectedDurationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        label.textColor = .white
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 0.4
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.masksToBounds = false
        return label
    }()
}


class SpeedSegmentControl: UISegmentedControl {
    
    private let speedValues: [CGFloat] = [0.3, 0.5, 1.0, 3.0, 5.0]
    var speedDidSelect: ((CGFloat) -> Void)?
    
    private let speedTitles: [String] = ["mv_creator_video_speed_03".localized, "mv_creator_video_speed_05".localized, "mv_creator_video_speed_1".localized, "mv_creator_video_speed_2".localized, "mv_creator_video_speed_3".localized]
    init() {
        super.init(items: speedTitles)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        if #available(iOS 13.0, *) {
            self.selectedSegmentTintColor = .white
        } else {
            self.tintColor = .white
        }
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.4)], for: .selected)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.selectedSegmentIndex = 2
        self.addTarget(self, action: #selector(segmentControlValueDidChanged(_:)), for: .valueChanged)
    }
    
    func setTitles() {
        speedTitles.enumerated().forEach {
            setTitle($0.element, forSegmentAt: $0.offset)
        }
    }
    
    @objc func segmentControlValueDidChanged(_ segment: UISegmentedControl) {
        let speed = speedValues[segment.selectedSegmentIndex]
        speedDidSelect?(speed)
    }
    
    func selectedScale(_ scale: CGFloat) {
        speedValues.enumerated().forEach { item in
            if item.element == scale {
                self.selectedSegmentIndex = item.offset
            }
        }
    }
}

class MVButton: UIButton {
    
    init(title: String, image: UIImage?) {
        super.init(frame: .zero)
        
        self.setTitle(title, for: .normal)
        self.setImage(image, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.imageView?.contentMode = .center
        self.titleLabel?.font = UIFont.systemRegularFont(ofSize: 9)
        self.titleLabel?.textAlignment = NSTextAlignment.center
        self.titleLabel?.lineBreakMode = .byWordWrapping
        
        guard let image = image else {
            return
        }
        
        let titleSize = title.sizeOfString(usingFont: UIFont.systemRegularFont(ofSize: 9))
        let spacing: CGFloat = 0.0
        
        titleEdgeInsets = UIEdgeInsets(top: spacing, left: -image.size.width, bottom: -image.size.height, right: 0)
        imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0, bottom: 0, right: -titleSize.width)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
