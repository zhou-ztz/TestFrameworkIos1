//
//  PostTokenView.swift
//  Yippi
//
//  Created by Francis Yeap on 29/01/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

import Combine

class PostTokenView: UIView {

    @IBOutlet var container: UIView!
    @IBOutlet var gradientView: TSGradientView!
    @IBOutlet var iconImageView: UIStackView!
    @IBOutlet var primaryLabel: UILabel!

    var cancellables = Set<AnyCancellable>()
    private let activityLoader = UIActivityIndicatorView(style: .white)
    private(set) lazy var debouncer: Debouncer =  {
        let debouncer = Debouncer(delay: 0.3)
        return debouncer
    }()

//    var onSuccess: ((SocialTokenBalanceModel.Data?) -> Void)?
    var onError: ((_ errorMsg: String) -> Void)?
    var onDisallow: EmptyClosure?

    var count: Int? = nil {
        willSet {
            primaryLabel.text = String(format: "post_feed_hot_feed_text_count".localized, newValue.stringValue)
        }
    }

    var isEnabled: Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.updateView()
            }
        }
    }

    var allowBean: Bool = false

    private(set) var isLoading = false {
        didSet {
            if isLoading == true {
                activityLoader.makeHidden()
                iconImageView.addArrangedSubview(activityLoader)
                activityLoader.startAnimating()
                isEnabled = false
                UIView.animate(withDuration: 0.2) {
                    self.activityLoader.makeVisible()
                }
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.activityLoader.makeHidden()
                }) { (_) in
                    self.iconImageView.removeArrangedSubview(self.activityLoader)
                    self.activityLoader.removeFromSuperview()
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()

        defer { count = nil }
    }


    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()

        defer { count = nil }
    }

    func fetchHotBalances(shouldToggle: Bool = true, isText: Bool = false) -> Future<SocialTokenBalanceModel.Data?, Error> {
        let request = SocialTokenBalanceRequestType()

        return Future() { [weak self] promise in
            guard let self = self else { return }

            guard self.count == nil else {
                // By kit Foong (When is Text, disable hot feed)
                if isText {
                    self.isEnabled = false
                } else {
                    self.isEnabled = self.count! > 0
                }
                return
            }
            self.isLoading = true

            request.execute(onSuccess: { [weak self] (responseObject) in
                guard let self = self else { return }
                defer {
                    self.isLoading = false
                }
                guard let data = responseObject?.data else {
                    promise(.success(nil))
                    return
                }

                let hotData: SocialTokenBalanceModel.Data? = data.filter { $0.id == SocialTokenType.hot.rawValue }.first
                self.count = hotData?.balances
                // By kit Foong (When is Text, disable hot feed)
                if isText {
                    self.isEnabled = false
                } else {
                    self.isEnabled = (self.count.orZero > 0) && (shouldToggle == true) && self.allowBean
                }
                promise(.success(hotData))

                if self.count.orZero <= 0 {
                    self.onError?("socialtoken_insufficient_balance_error".localized)
                }

            }) { (error) in
                defer {
                    self.isLoading = false
                }
                promise(.failure(error))
            }

        }

    }


    func commonInit() {
        Bundle.main.loadNibNamed(String(describing: PostTokenView.self), owner: self, options: nil)
        container.frame = self.bounds
        container.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(container)

        roundCorner(14)
        container.roundCorner(14)
        gradientView.roundCorner(14)
        container.backgroundColor = UIColor(hexString: "#C0C0C0")

        self.addTap { [weak self] _ in
            guard let self = self else { return }
            if self.isEnabled == true {
                self.isEnabled = !self.isEnabled
            } else {
                if self.allowBean == true {
                    self.debouncer.execute()
                } else {
                    self.onDisallow?()
                }
            }
        }

        updateView()

        debouncer.handler = { [weak self] in
            guard let self = self else { return }
//            self.fetchHotBalances()
//                .sink(receiveCompletion: { error in
//                    guard let error = error as? YPErrorType else { return }
//                    switch error {
//                        case .carriesMessage(let msg, _, _):
//                            self.onError?(msg)
//                        case let .error(message, _):
//                            self.onError?(message)
//                        case let .violations(message, _):
//                            self.onError?(message)
//                        default: break
//                    }
//                }, receiveValue: { data in
//                    self.onSuccess?(data)
//                }).store(in: &self.cancellables)
        }
    }

    func updateView() {
        if isEnabled == true {
            gradientView.colors = [UIColor(red: 41, green: 207, blue: 157), UIColor(red: 78, green: 220, blue: 80)]
        } else {
            gradientView.colors = [.clear, .clear]
        }

        self.layoutSubviews()
    }

}
