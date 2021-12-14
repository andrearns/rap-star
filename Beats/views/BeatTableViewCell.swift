import UIKit

final class BeatTableViewCell: UITableViewCell {

    @IBOutlet var beatImageView: UIImageView!
    @IBOutlet var beatNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(beat: Beat) {
        beatImageView.image = UIImage(named: beat.imageName!)
        beatNameLabel.text = beat.name
        artistNameLabel.text = beat.artistName
    }

}
