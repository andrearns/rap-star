import UIKit

class PausedPopUpViewController: UIViewController {

    @IBOutlet var popUpBackgroundView: UIView!
    @IBOutlet var backToMainMenuButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backToMainMenuButton.layer.cornerRadius = 25
        pauseButton.layer.cornerRadius = 25
        popUpBackgroundView.layer.cornerRadius = 15
    }
    
    @IBAction func backToMainMenu(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.Action.BackToMainMenu, object: nil)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func continueBeat(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.Action.PlayOrStop, object: nil)
        navigationController?.popViewController(animated: true)
    }
    
}
