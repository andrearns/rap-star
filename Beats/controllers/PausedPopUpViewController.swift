import UIKit
import FirebaseAnalytics

final class PausedPopUpViewController: UIViewController {

    @IBOutlet var popUpBackgroundView: UIView!
    @IBOutlet var backToMainMenuButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backToMainMenuButton.layer.cornerRadius = 25
        pauseButton.layer.cornerRadius = 25
        popUpBackgroundView.layer.cornerRadius = 15
        Analytics.logEvent("beat_paused", parameters: [:])
    }
    
    @IBAction func backToMainMenu(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.Action.BackToMainMenu, object: nil)
        Analytics.logEvent("beat_exited", parameters: [:])
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func continueBeat(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.Action.PlayOrStop, object: nil)
        Analytics.logEvent("beat_continued", parameters: [:])
        navigationController?.popViewController(animated: true)
    }
    
}
