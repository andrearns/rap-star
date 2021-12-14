import UIKit
import Foundation
import AVFoundation
import Speech

final class RimeViewController: UIViewController, SFSpeechRecognizerDelegate {

    var beat: Beat!
    var rimeCurrentState: RimeCurrentState = .playing
    var timer = Timer()
    var finishTimer = Timer()
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
        
        // Words
        fadeInWords()
        sortWords()
        
        // Speech Recognizer
        speechRecognizer?.delegate = self
        
        // Finish Timer
        self.finishTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(60), repeats: false, block: { _ in
            print("Beat finished")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Finished") as! BeatFinishedViewController
            vc.points = self.points
            if let player = self.player {
                player.stop()
            }
            self.navigationController?.present(vc, animated: true, completion: nil)
        })
        
        startRecording()
        configureTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(playOrStop), name: Notification.Name.Action.PlayOrStop, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(backToMainMenu), name: Notification.Name.Action.BackToMainMenu, object: nil)
        
        configurePlayer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
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
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
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
        configureTimer()
    }
    
    @IBAction func pressPlayOrStopButton(_ sender: Any) {
        playOrStop()
    }
    
    @objc func backToMainMenu() {
        removePlayer()
        removeSpeechRecognizer()
    }
    
    
    @objc func playOrStop() {
        print("Play or stop")
        
        if rimeCurrentState == .playing {
            rimeCurrentState = .paused
        } else {
            rimeCurrentState = .playing
        }
        
        // Play
        if rimeCurrentState == .playing {
            print("Beat played")
            
            if let player = player {
                player.play()
            }
            
            playOrStopButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            
            configureTimer()
            startRecording()
        }
        // Stop
        else if rimeCurrentState == .paused {
            print("Beat stoped")
            
            if let player = player {
                player.stop()
            }
            
            playOrStopButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            
            self.timer.invalidate()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Paused") as? PausedPopUpViewController
           
            removeSpeechRecognizer()
            
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func configureTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(wordsIntervalSlider.value.rounded()), repeats: true, block: { _ in
            self.fadeOutWords()
            self.sortWords()
            self.fadeInWords()
        })
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
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true)
                
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
        player = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        }
        catch {
            print("Error")
        }
    }
    
    func removeSpeechRecognizer() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
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

extension Notification.Name {
    struct Action {
        static let PlayOrStop = Notification.Name("PlayOrStop")
        static let BackToMainMenu = Notification.Name("BackToMainMenu")
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
