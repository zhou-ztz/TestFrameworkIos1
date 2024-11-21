//
//  SpeechVoiceDetectManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/3/9.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import Speech


enum SpeechToTextState {
    case recording
    case ready
    case idle
    case loading
}
enum SpeechToTextRequestAuthorizationState {
    case authorized
    case denied
    case restricted
    case notDetermined
}
class SpeechVoiceDetectManager: NSObject, SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate {
    
    static let shared = SpeechVoiceDetectManager()
    
    var onReceiveValue: ((String?, Bool) -> Void)?
    var onStateChanged: ((SpeechToTextState) -> Void)?
    var onDurationChanged: ((Int) -> Void)?
    var onRecordEnd: (() -> Void)?
    var onRequestAuthorizationStateChanged: ((SpeechToTextRequestAuthorizationState, String? ) -> Void)?
    //语音是否录制完毕
    public var isRecordEnd: Bool = false
    //是否有识别到内容
    public var hasRecognizedText: Bool = false
    
    public var speechRecognizer: SFSpeechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en"))!
    public var state: SpeechToTextState = .idle {
        didSet {
            updateState()
        }
    }

    private var bufferRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        
    private var audioEngine: AVAudioEngine? = AVAudioEngine()
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var timer: Timer?
    
    private var currentSelectedLangCode: SupportedLanguage = SupportedLanguage(code: "en", name: "English")
    
    override init() {
        super.init()

        var langIdentifier = ""
        if #available(iOS 16, *) {
            langIdentifier = NSLocale.current.language.languageCode?.identifier ?? "en"
        } else {
            langIdentifier = NSLocale.current.languageCode ?? ""
            // Fallback on earlier versions
        }
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: langIdentifier)) ?? SFSpeechRecognizer(locale: Locale(identifier: "en"))!
        speechRecognizer.delegate = self
        
    }
    public func getAuthorization(authResult: @escaping ((SFSpeechRecognizerAuthorizationStatus) -> Void)) {
        SFSpeechRecognizer.requestAuthorization { authStatus in

            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("authorized")
                    authResult(.authorized)
                    self.onRequestAuthorizationStateChanged?(.authorized,"")
                case .denied:
                   print("User denied access to speech recognition")
                    authResult(.denied)
                    self.onRequestAuthorizationStateChanged?(.denied,"im_denied_access_speech".localized)
                case .restricted:
                    print("Speech recognition restricted on this device")
                    authResult(.restricted)
                    self.onRequestAuthorizationStateChanged?(.restricted,"im_speech_recognition_restricted".localized)
                case .notDetermined:
                    print("Speech recognition not yet authorized")
                    authResult(.notDetermined)
                    self.onRequestAuthorizationStateChanged?(.notDetermined,"im_speech_recognition_not_authorized".localized)
                default:
                    print("-")
                }
            }
        }
    }
    //设定自定义识别语言
    public func setLanguage(code: String) {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: code)) ?? SFSpeechRecognizer(locale: Locale(identifier: "en"))!
        let languageName = LocalizationManager.getDisplayNameForLanguageIdentifier(identifier: code)
        
        let dict = [
            "locale": code,
            "name": languageName
        ]

        UserDefaults.standard.set(dict, forKey: "SpeechToTextTypingLanguage")
    }
    // 设定默认识别语言
    private func setDefaultLangCode() {
        var langIdentifier = ""
        if #available(iOS 16, *) {
            langIdentifier = NSLocale.current.language.languageCode?.identifier ?? "en"
        } else {
            langIdentifier = NSLocale.current.languageCode ?? ""
            // Fallback on earlier versions
        }
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: langIdentifier)) ?? SFSpeechRecognizer(locale: Locale(identifier: "en"))!
    }
    //依据录音文件重新转换识别文字
    public func convertToTextWithAudioFile(filePath path: String, langCode code: String) {
        
        self.setLanguage(code: code)
        let url = URL(fileURLWithPath: path)
        let request = SFSpeechURLRecognitionRequest(url: url) // 进行请求
        speechRecognizer.recognitionTask(with: request) { result, error in
            
            guard let result = result else {
                self.onReceiveValue?(nil, result?.isFinal ?? true )
                return
            }
            self.onReceiveValue?(result.bestTranscription.formattedString, result.isFinal)
        }
    }
    
    private func updateState() {
        switch state {
        case .recording:
            checkAuthorization()
            self.onStateChanged?(.recording)

        case .idle:
            self.onStateChanged?(.idle)

        case .ready:
            self.onStateChanged?(.ready)

        case .loading:
            self.onStateChanged?(.loading)
        }
    }
    @objc private func checkAuthorization() {
        getAuthorization { [weak self] (status) in
            if status == .authorized {
                try? self?.startRecording()
            }
        }
    }
        
    @objc private func startRecording() throws {
        
        setDefaultLangCode()
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        switch state {
        case .recording:  break
        default: state = .recording
        }
        
        audioEngine = AVAudioEngine()
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        try audioSession.setPreferredIOBufferDuration(10.0)
        guard let audioEngine = audioEngine else { return }
        let inputNode = audioEngine.inputNode
        
        bufferRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let bufferRecognitionRequest = bufferRecognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        bufferRecognitionRequest.shouldReportPartialResults = true
        
        if #available(iOS 13, *) {
            bufferRecognitionRequest.requiresOnDeviceRecognition = false
        }
        if #available(iOS 16, *) {
            //给语音识别结果加上标点符号
            bufferRecognitionRequest.addsPunctuation = true
        }
        //更新语言标识
        currentSelectedLangCode = getSupportedLanguageData()
        var langIdentifier = currentSelectedLangCode.code ?? "en"
        langIdentifier = langIdentifier.replacingOccurrences(of: "-hans", with: "").replacingOccurrences(of: "-hant", with: "")
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: langIdentifier)) ?? SFSpeechRecognizer(locale: Locale(identifier: "en"))!
        recognitionTask = speechRecognizer.recognitionTask(with: bufferRecognitionRequest) { result, error in
            
            var isFinal = false
            
            if let result = result {
                isFinal = result.isFinal
                self.onReceiveValue?( result.bestTranscription.formattedString, isFinal)
            }
            
            if error != nil || isFinal {
                if let result = result {
                    self.onReceiveValue?(result.bestTranscription.formattedString,isFinal)
                } else {
                    self.onReceiveValue?("", true)
                }
                if audioEngine.isRunning == true {
                    self.audioEngine?.stop()
                    inputNode.removeTap(onBus: 0)
                    bufferRecognitionRequest.endAudio()
                }
                self.bufferRecognitionRequest = nil
                self.recognitionTask = nil
                
            }
        }
        
        var duration: TimeInterval = 60.0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            
            self?.onDurationChanged?(Int(duration))
            if duration <= 0 {
                SpeechVoiceDetectManager.shared.isRecordEnd = true
                timer.invalidate()
                self?.timer = nil
                self?.stopRecording()
                self?.onRecordEnd?()
                return
            }
            duration -= 1.0
        })
        timer?.fire()
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 4069, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.bufferRecognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        if !audioEngine.isRunning {
            try audioEngine.start()
        }
        
    }
    
    func stopRecording() {
        if audioEngine?.isRunning == true {
            audioEngine?.stop()
            bufferRecognitionRequest?.endAudio()
            audioEngine = nil
        }
        
        timer?.invalidate()
        timer = nil
    }
    
    func getSupportedLanguageData() -> SupportedLanguage {
        let langIdentifier = Locale.current.languageCode ?? "en"
        if let preferredLanguageObject = UserDefaults.standard.object(forKey: "SpeechToTextTypingLanguage") as? [String:String] {
            return SupportedLanguage(code: preferredLanguageObject["locale"] ?? langIdentifier, name: preferredLanguageObject["name"] ?? LocalizationManager.getDisplayNameForLanguageIdentifier(identifier: langIdentifier))
        }

        return SupportedLanguage(code: langIdentifier, name: LocalizationManager.getDisplayNameForLanguageIdentifier(identifier: langIdentifier))
    }
}
