import AudioKit
import AudioKitUI
import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet private var amplitudeLabel: UILabel!
    @IBOutlet private var audioInputPlot: EZAudioPlot!
    private let phone = "415-519-7276"
    let utterance = AVSpeechUtterance(string: "You are loud")
    let synthesizer = AVSpeechSynthesizer()
    
        
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.translatesAutoresizingMaskIntoConstraints = false
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        audioInputPlot.addSubview(plot)
        
        // Pin the AKNodeOutputPlot to the audioInputPlot
        var constraints = [plot.leadingAnchor.constraint(equalTo: audioInputPlot.leadingAnchor)]
        constraints.append(plot.trailingAnchor.constraint(equalTo: audioInputPlot.trailingAnchor))
        constraints.append(plot.topAnchor.constraint(equalTo: audioInputPlot.topAnchor))
        constraints.append(plot.bottomAnchor.constraint(equalTo: audioInputPlot.bottomAnchor))
        constraints.forEach { $0.isActive = true }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        view.backgroundColor = .white
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5
        utterance.volume = 1.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        setupPlot()
        Timer.scheduledTimer(timeInterval: 0.4,
                             target: self,
                             selector: #selector(ViewController.updateUI),
                             userInfo: nil,
                             repeats: true)
        
    }
    
    @objc func updateUI() {
        let db = (10 * log(tracker.amplitude)) + 98
        
        amplitudeLabel.text = String(format: "Amplitude: %0.1f", db)
        if (db > 91) {
            print("You Loud")
            view.backgroundColor = .red
            synthesizer.speak(utterance)
        } else {
            view.backgroundColor = .white
        }

    }

    
}

