import UIKit
import Foundation
import AVFoundation
import Speech

class RimeViewController: UIViewController, SFSpeechRecognizerDelegate {

    var beat: Beat!
    var rimeCurrentState: RimeCurrentState = .playing
    var timer = Timer()
    var player: AVAudioPlayer?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "pt-BR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var transcriptionText: String = ""
    var points: Int = 0
    
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var easyWordBackgroundView: UIView!
    @IBOutlet var mediumWordBackgroundView: UIView!
    @IBOutlet var hardWordBackgroundView: UIView!
    @IBOutlet var transcriptLabel: UILabel!
    @IBOutlet var beatNameLabel: UILabel!
    @IBOutlet var beatImageView: UIImageView!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var playOrStopButton: UIButton!
    @IBOutlet var easyWordLabel: UILabel!
    @IBOutlet var mediumWordLabel: UILabel!
    @IBOutlet var hardWordLabel: UILabel!
    @IBOutlet var wordsIntervalLabel: UILabel!
    @IBOutlet var wordsIntervalSlider: UISlider!
    @IBOutlet var progressBarWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Draw beat informations on screen
        beatNameLabel.text = beat.name
        beatImageView.image = UIImage(named: beat.imageName!)
        artistNameLabel.text = beat.artistName
        wordsIntervalLabel.text = "Tempo entre a troca de palavras: \(wordsIntervalSlider.value.rounded()) s"
        
        // Add styles
        playOrStopButton.layer.cornerRadius = 20
        
        // Play or Stop Button
        playOrStop()
        
        // Words
        fadeInWords()
        sortWords()
        
        // Player
        configurePlayer()
        
        // Speech Recognizer
        speechRecognizer?.delegate = self
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            startRecording()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removePlayer()
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord)
            try audioSession.setMode(.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren`t set beacuse of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
//        if #available(iOS 13, *) {
//            recognitionRequest.requiresOnDeviceRecognition = true
//        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
            
            var isFinal = false
            
            if result != nil {
                self.transcriptionText = (result?.bestTranscription.formattedString)!
                
                if self.transcriptionText.count > 50 {
                    let newString = self.transcriptionText.dropFirst(self.transcriptionText.count - 50)
                    self.transcriptionText = String(newString)
                }
                
                self.transcriptLabel.text = self.transcriptionText
                print(self.transcriptionText)
                
                if self.transcriptLabel.text?.lowercased().contains(self.easyWordLabel.text!.lowercased()) == true {
                    print("Easy word done")
                    self.easyWordBackgroundView.backgroundColor = UIColor(named: "NeonGreen")
                    self.performPointsAnimation(label: self.easyWordLabel)
                    self.easyWordLabel.text = "+ 10 pontos"
                    self.points += 10
                } else if self.transcriptLabel.text?.lowercased().contains(self.mediumWordLabel.text!.lowercased()) == true {
                    print("Medium word done")
                    self.mediumWordBackgroundView.backgroundColor = UIColor(named: "NeonGreen")
                    self.performPointsAnimation(label: self.mediumWordLabel)
                    self.mediumWordLabel.text = "+ 20 pontos"
                    self.points += 20
                } else if self.transcriptLabel.text?.lowercased().contains(self.hardWordLabel.text!.lowercased()) == true {
                    print("Hard word done")
                    self.hardWordBackgroundView.backgroundColor = UIColor(named: "NeonGreen")
                    self.performPointsAnimation(label: self.hardWordLabel)
                    self.hardWordLabel.text = "+ 30 pontos"
                    self.points += 30
                }
                self.pointsLabel.text = "PONTOS: \(self.points)"
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
            
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 10000, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn`t start because of an error.")
        }

        transcriptLabel.text = "Say something, I`m listening"
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        wordsIntervalLabel.text = "Tempo entre a troca de palavras: \(wordsIntervalSlider.value.rounded()) s"
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(wordsIntervalSlider.value.rounded()), repeats: true, block: { _ in
            self.fadeOutWords()
            self.sortWords()
            self.fadeInWords()
        })
    }
    
    @IBAction func pressPlayOrStopButton(_ sender: Any) {
        playOrStop()
    }
    
    func playOrStop() {
        if rimeCurrentState == .playing {
            configurePlayer()
            rimeCurrentState = .paused
            playOrStopButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(wordsIntervalSlider.value.rounded()), repeats: true, block: { _ in
                self.fadeOutWords()
                self.sortWords()
                self.fadeInWords()
            })
            print("Beat played")
        } else if rimeCurrentState == .paused {
            if let player = player {
                player.stop()
            }
            rimeCurrentState = .playing
            playOrStopButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.timer.invalidate()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Paused") as? PausedPopUpViewController
            navigationController?.present(vc!, animated: true, completion: nil)
            print("Beat paused")
        }
    }
    
    func sortWords() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.sortWord(label: self.easyWordLabel, level: .easy)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.sortWord(label: self.mediumWordLabel, level: .medium)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.sortWord(label: self.hardWordLabel, level: .hard)
        }
    }
    
    func sortWord(label: UILabel, level: WordLevel) {
        let oldWord = label.text
        while label.text == oldWord {
            switch level {
            case .easy:
                label.text = WordsBank.shared.easyWordsList.randomElement()
            case .medium:
                label.text = WordsBank.shared.mediumWordsList.randomElement()
            case .hard:
                label.text = WordsBank.shared.hardWordsList.randomElement()
            }
        }
    }
    
    func fadeOutWords() {
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
            self.easyWordLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        })
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseOut, animations: {
            self.mediumWordLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        })
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
            self.hardWordLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        })
    }
    
    
    func fadeInWords() {
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseIn, animations: {
            self.easyWordLabel.transform = CGAffineTransform.identity
            self.easyWordBackgroundView.backgroundColor = .white
            self.easyWordLabel.textColor = UIColor(named: "BackgroundGray")
        })
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn, animations: {
            self.mediumWordLabel.transform = CGAffineTransform.identity
            self.mediumWordBackgroundView.backgroundColor = .white
            self.mediumWordLabel.textColor = UIColor(named: "BackgroundGray")
        })
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseIn, animations: {
            self.hardWordLabel.transform = CGAffineTransform.identity
            self.hardWordBackgroundView.backgroundColor = .white
            self.hardWordLabel.textColor = UIColor(named: "BackgroundGray")
        })
    }
    
    func performPointsAnimation(label: UILabel) {
        label.textColor = .white
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
            label.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        })
        UIView.animate(withDuration: 0.15, delay: 0.15, options: .curveEaseIn, animations: {
            label.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
        })
    }
    
    func configurePlayer() {
        let urlString = Bundle.main.path(forResource: beat.trackName, ofType: ".mp3")
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
                
            guard let urlString = urlString else {
                return
            }
            
            player = try AVAudioPlayer(contentsOf: URL(string: urlString)!)
            
            guard let player = player else {
                return
            }
            
            player.play()
        }
        catch {
            print("Error")
        }
    }
    
    func removePlayer() {
        if let player = player {
            player.stop()
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("Available")
        } else {
            print("Not available")
        }
    }
}

enum RimeCurrentState {
    case playing
    case paused
}

enum WordLevel {
    case easy
    case medium
    case hard
}
