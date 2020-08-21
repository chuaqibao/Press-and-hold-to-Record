import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecords = 0
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var buttonLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the recognizer to recognize the button action
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(record))
        longPressRecognizer.minimumPressDuration = 0
        buttonLabel.addGestureRecognizer(longPressRecognizer)
        
        // Setting up session
        recordingSession = AVAudioSession.sharedInstance()
        
        // Get permission from user to use mic
        AVAudioSession.sharedInstance().requestRecordPermission{ (hasPermission) in
            if hasPermission
            {print ("ACCEPTED")}
        }
    }
    
    
    @IBAction func record(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Check if we have an active recorder
        if (gestureRecognizer.state == .began) && (audioRecorder == nil) {
            // Increase +1 total number of recordings for every new recording made
            numberOfRecords += 1
            
            // Setting filename and settings
            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do
            {
                // Start audio recording
                buttonLabel.setTitle("Recording...", for: .normal)
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
            }
            catch
            {
                // Catch for errors
                displayAlert(title: "Oops!", message: "Recording failed")
                
            }
            
        } else if gestureRecognizer.state == .ended && (audioRecorder != nil)
        
        {
            // Stopping audio recording
            buttonLabel.setTitle("Start Recording", for: .normal)
            audioRecorder.stop()
            audioRecorder = nil

            // Refresh table data
            myTableView.reloadData()
        }
    }
    
    // Function that gets path to directory
    func getDirectory () -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    // Function that displays an alert
    func displayAlert(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Setting up TableView
    
    // Setting number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(numberOfRecords)
        return numberOfRecords
    }
    
    // Setting contents of each cell of table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row + 1)
        print("done")
        return cell
    }
    
    // Playing the audio
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        }
        catch
        {
            displayAlert(title: "Oops!", message: "Recording failed")
        }
    }
}
