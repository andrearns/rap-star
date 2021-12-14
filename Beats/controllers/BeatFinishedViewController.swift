import UIKit
import FirebaseAnalytics

final class BeatFinishedViewController: UIViewController {

    @IBOutlet var star1ImageView: UIImageView!
    @IBOutlet var star2ImageView: UIImageView!
    @IBOutlet var star3ImageView: UIImageView!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var popUpBackgroundView: UIView!
    
    var points: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.layer.cornerRadius = 25
        popUpBackgroundView.layer.cornerRadius = 15
        
        pointsLabel.text = "PONTOS: \(self.points ?? 0)"
        if points == 0 {
            star1ImageView.image = UIImage(systemName: "star")
            star2ImageView.image = UIImage(systemName: "star")
            star3ImageView.image = UIImage(systemName: "star")
        }
        else if points <= 100 && points != 0 {
            star1ImageView.image = UIImage(systemName: "star.fill")
            star2ImageView.image = UIImage(systemName: "star")
            star3ImageView.image = UIImage(systemName: "star")
        } else if points > 100 && points < 200 {
            star1ImageView.image = UIImage(systemName: "star.fill")
            star2ImageView.image = UIImage(systemName: "star.fill")
            star3ImageView.image = UIImage(systemName: "star")
        } else {
            star1ImageView.image = UIImage(systemName: "star.fill")
            star2ImageView.image = UIImage(systemName: "star.fill")
            star3ImageView.image = UIImage(systemName: "star.fill")
        }
        
        Analytics.logEvent("beat_finished", parameters: [:])
    }
    
    @IBAction func finish(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Home")
        present(vc, animated: true, completion: nil)
    }
}
