//
//  SpeechToTextView.swift
//  Yippi
//
//  Created by Francis on 18/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import Speech
import SnapKit
import Lottie

typealias onFinishedHandler = (_ success:Bool) -> Void


protocol SpeechToTextDelegate: class {
    func onClose()
    func onFinished(with text: String, completion: onFinishedHandler)
    func onSend()
    func onStateChanged(state: SpeechToText.SpeechToTextState)
    func onClear()
}

struct SpeechToText {
    enum SpeechToTextState {
        case recording
        case ready
        case idle
        case loading
    }
    var state: SpeechToTextState
}

class SpeechToTextView: UIView, SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate {
        
    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet var view: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var recordingIndicatorLabel: UILabel!
    fileprivate var player: AVAudioPlayer?
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var speakButton: UIImageView!
    
    private let speakingButton: AnimationView = AnimationView().configure {
        $0.animation =  Animation.named("speaking")
        $0.loopMode = .loop
        $0.contentMode = .scaleToFill
        $0.animationSpeed = 0.095
    }

    public var state: SpeechToText.SpeechToTextState = .idle {
        didSet {
            updateState()
        }
    }

    private var bufferRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        
    private let audioEngine = AVAudioEngine()

    private var recognitionRequest: SFSpeechURLRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioRecorder: AVAudioRecorder?
    private var audioSession = AVAudioSession.sharedInstance()
    private var timer: Timer?
    var language: String
    
    weak var delegate:SpeechToTextDelegate?
    public var speechRecognizer: SFSpeechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en"))!
    
    init(frame: CGRect, language: String) {
        self.language = language
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func setup() {
        let bundle = Bundle(for: type(of: self))
        UINib(nibName: "SpeechToTextView", bundle: bundle).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = bounds
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))!
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in

            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.view.isUserInteractionEnabled = true
                case .denied:
                    self.view.isUserInteractionEnabled = false
                    self.recordingIndicatorLabel.text = "im_denied_access_speech".localized
                case .restricted:
                    self.view.isUserInteractionEnabled = false
                    self.recordingIndicatorLabel.text = "im_speech_recognition_restricted".localized
                case .notDetermined:
                    self.view.isUserInteractionEnabled = false
                    self.recordingIndicatorLabel.text = "im_speech_recognition_not_authorized".localized
                default:
                    self.view.isUserInteractionEnabled = false
                }
            }
        }

        self.state = .idle
                        
        loadingView.contentMode = .scaleAspectFit
        loadingView.image = UIImage.set_image(named: "ic_speech_to_text_waiting")
        
        buttonsContainer.addSubview(speakingButton)
        speakingButton.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(85)
        }

        speakingButton.addTap { [weak self]  (_) in
            self?.stopRecording()
            self?.state = .ready
        }

        speakButton.contentMode = .scaleAspectFit
        speakButton.image = UIImage.set_image(named: "ic_speech_to_text_record")
        
        speakButton.addTap { [weak self]  (_) in
            switch self?.state {
            case .recording:
                self?.state = .ready
            default:
                self?.state = .recording
            }
        }
        
        closeButton.addTap { [weak self]  (_) in
            switch self?.state {
            case .ready:
                self?.delegate?.onClear()
            default:
                self?.stopRecording()
                self?.delegate?.onClose()
            }
            self?.state = .idle
        }
        sendButton.setTitle("send".localized, for: .normal)
        sendButton.addTap { [weak self] (_) in
            self?.delegate?.onSend()
            self?.state = .idle
        }
    }
        
    public func setLanguage(code: String) {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: code))!
        
        let languageName = LocalizationManager.getDisplayNameForLanguageIdentifier(identifier: code)
        
        let dict = [
            "locale": code,
            "name": languageName
        ]

        UserDefaults.standard.set(dict, forKey: "SpeechTypingLanguage")
    }
    
    private func updateState() {
        switch state {
        case .recording:
            try? startRecording()
            loadingView.makeHidden()
            sendButton.makeHidden()
            speakButton.makeHidden()
            speakingButton.play()
            speakingButton.makeVisible()
            closeButton.makeHidden()
            recordingIndicatorLabel.makeVisible()
            recordingIndicatorLabel.text = "speech_to_text_state_recording".localized
            self.delegate?.onStateChanged(state: .recording)

        case .idle:
            loadingView.makeHidden()
            speakButton.makeVisible()
            speakingButton.makeHidden()
            speakingButton.stop()
            sendButton.makeHidden()
            closeButton.makeVisible()
            closeButton.setTitle("close".localized, for: .normal)
            recordingIndicatorLabel.makeVisible()
            recordingIndicatorLabel.text = "speech_to_text_state_idle".localized
            self.delegate?.onStateChanged(state: .idle)

        case .ready:
            sendButton.makeVisible()
            loadingView.makeHidden()
            speakButton.makeVisible()
            speakingButton.makeHidden()
            speakingButton.stop()
            closeButton.makeVisible()
            closeButton.setTitle("clear".localized, for: .normal)
            recordingIndicatorLabel.makeVisible()
            recordingIndicatorLabel.text = "speech_to_text_state_done".localized
            self.delegate?.onStateChanged(state: .ready)

        case .loading:
            loadingView.makeVisible()
            sendButton.makeHidden()
            speakButton.makeHidden()
            speakingButton.makeHidden()
            speakingButton.stop()
            closeButton.makeHidden()
            recordingIndicatorLabel.makeVisible()
            recordingIndicatorLabel.text = "Loading..."
            self.delegate?.onStateChanged(state: .loading)
        }
    }
        
    @objc private func startRecording() throws {
        recognitionTask?.cancel()
        self.recognitionTask = nil

        switch state {
        case .recording:  break
        default: state = .recording
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        try audioSession.setPreferredIOBufferDuration(10.0)
        let inputNode = audioEngine.inputNode

        bufferRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let bufferRecognitionRequest = bufferRecognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        bufferRecognitionRequest.shouldReportPartialResults = true

        if #available(iOS 13, *) {
            bufferRecognitionRequest.requiresOnDeviceRecognition = false
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: bufferRecognitionRequest) { result, error in
            
            var isFinal = false
            
            if let result = result {
                isFinal = result.isFinal
                self.delegate?.onFinished(with: result.bestTranscription.formattedString, completion: {_ in })
            }
            
            if error != nil || isFinal {
                if let result = result {
                    self.delegate?.onFinished(with: result.bestTranscription.formattedString, completion: { updated in
                        if updated {
                            self.state = .ready
                            self.sendButton.isUserInteractionEnabled = true
                        }
                    })
                } else {
                    self.delegate?.onFinished(with: "", completion: { updated in
                        if updated {
                            self.state = .idle
                            self.sendButton.isUserInteractionEnabled = false
                        }
                    })
                }
                
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.bufferRecognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        var duration: TimeInterval = 10.0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            if duration <= 0 {
                timer.invalidate()
                self?.timer = nil

                self?.stopRecording()
                return
            }
            duration -= 1.0
        })
        timer?.fire()

        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.bufferRecognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
            bufferRecognitionRequest?.endAudio()
        }
        timer?.invalidate()
        timer = nil
    }
}
