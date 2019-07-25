import AudioKit
import AudioKitUI
import UIKit
//import AVFoundation

class ViewController: UIViewController {
    
    
    
    @IBOutlet private var amplitudeLabel: UILabel!
    @IBOutlet weak var thresholdLabel: UILabel!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    var threshold = 90
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        view.backgroundColor = .white
        thresholdLabel.text = "Max threshold: " + String(threshold)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        Timer.scheduledTimer(timeInterval: 0.4,
                             target: self,
                             selector: #selector(ViewController.updateUI),
                             userInfo: nil,
                             repeats: true)
        
    }
    
    @objc func updateUI() {
        let db = (10 * log(tracker.amplitude)) + 98
        
        amplitudeLabel.text = String(format: "%0.1f", db)
        if (Int(db) > threshold) {
            print("You Loud")
            view.backgroundColor = .red
        } else if (db > (threshold - 15)) {
            print("You Are Nearly Loud")
            view.backgroundColor = .yellow
        } else {
            view.backgroundColor = .green
        }

    }

    @IBAction func adjustButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Adjust the sound threshold?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input the new amplitude..."
            textField.keyboardType = UIKeyboardType.numberPad
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let new = Int((alert.textFields?.first!.text)!) {
                print(new)
                self.threshold = new
                self.thresholdLabel.text = "Max threshold: " + String(self.threshold)
            }
        }))
        
        self.present(alert, animated: true)
    }
    
}

