struct BeatsBank {
    static var shared = BeatsBank()
    
    var beatsList: [Beat] = [
        Beat(name: "Ganga", imageName: "cover1", artistName: "Sedevi", trackName: "beat1"),
        Beat(name: "Memories", imageName: "cover2", artistName: "OZsound", trackName: "beat2"),
        Beat(name: "Flex", imageName: "cover3", artistName: "Beats Provider", trackName: "beat3"),
        Beat(name: "HIGH", imageName: "cover4", artistName: "Sedevi", trackName: "beat4"),
        Beat(name: "Boombap", imageName: "cover5", artistName: "Redlox Beats", trackName: "beat5"),
        Beat(name: "Chill Old School 90s", imageName: "cover6", artistName: "Redlox Beats", trackName: "beat6"),
        Beat(name: "Glory", imageName: "cover7", artistName: "Robbero", trackName: "beat7"),
        Beat(name: "Spheres", imageName: "cover8", artistName: "Robbero", trackName: "beat8"),
        Beat(name: "I dunno", imageName: "cover9", artistName: "graps ft. J Lang & Morusque", trackName: "beat9"),
    ]
}
