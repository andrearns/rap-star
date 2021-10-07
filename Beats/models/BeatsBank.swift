struct BeatsBank {
    static var shared = BeatsBank()
    
    var beatsList: [Beat] = [
        Beat(name: "Survival Of The Fittest", imageName: "cover1", artistName: "Mobb Deep", trackName: "beat1"),
        Beat(name: "Shook Ones", imageName: "cover2", artistName: "Mobb Deep", trackName: "beat2"),
        Beat(name: "My Ambitionz As a Ridah", imageName: "cover3", artistName: "2Pac", trackName: "beat3"),
        Beat(name: "Dark Beat", imageName: "cover4", artistName: "Unknown", trackName: "beat4"),
        Beat(name: "Deep Cover", imageName: "cover5", artistName: "Snoop Dogg ft. Dr. Dre", trackName: "beat5"),
        Beat(name: "Green", imageName: "cover6", artistName: "Bearded Skull", trackName: "beat6"),
        Beat(name: "Xxplosive", imageName: "cover7", artistName: "Dr. Dre", trackName: "beat7"),
        Beat(name: "90's Gangsta Rap", imageName: "cover8", artistName: "SolxceMusikOfficial", trackName: "beat8"),
        Beat(name: "Gorilla Beat", imageName: "cover9", artistName: "Mixla", trackName: "beat9"),
        Beat(name: "Bonafide", imageName: "cover10", artistName: "Lethal Needle", trackName: "beat10"),
    ]
}
