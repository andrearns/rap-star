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
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func continueBeat(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
