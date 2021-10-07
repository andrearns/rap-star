import UIKit
import Foundation
import AVFoundation

class RimeViewController: UIViewController {

    var beat: Beat!
    var rimeCurrentState: RimeCurrentState = .playing
    var timer = Timer()
    var player: AVAudioPlayer?
    
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removePlayer()
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
            print("Beat paused")
        }
    }
    
    func sortWords() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.easyWordLabel.text = WordsBank.shared.easyWordsList.randomElement()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.mediumWordLabel.text = WordsBank.shared.mediumWordsList.randomElement()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.hardWordLabel.text = WordsBank.shared.hardWordsList.randomElement()
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
        })
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn, animations: {
            self.mediumWordLabel.transform = CGAffineTransform.identity
        })
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseIn, animations: {
            self.hardWordLabel.transform = CGAffineTransform.identity
        })
    }
    
    func configurePlayer() {
        let urlString = Bundle.main.path(forResource: beat.trackName, ofType: ".mp3")
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                
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
}

enum RimeCurrentState {
    case playing
    case paused
}
