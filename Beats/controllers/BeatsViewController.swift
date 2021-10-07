import UIKit

class BeatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var beatsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beatsTableView.delegate = self
        beatsTableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BeatsBank.shared.beatsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = beatsTableView.dequeueReusableCell(withIdentifier: "BeatCell", for: indexPath) as! BeatTableViewCell
        cell.setup(beat: BeatsBank.shared.beatsList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Start beat")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Rime") as! RimeViewController
        vc.beat = BeatsBank.shared.beatsList[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}

