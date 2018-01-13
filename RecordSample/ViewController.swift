//
//  ViewController.swift
//  RecordSample
//
//  Created by Sang ho Park on 2018. 1. 12..
//  Copyright © 2018년 solulink. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var playRecoredButton: UIButton!

	var player = AVAudioPlayer()
	let path = Bundle.main.path(forResource: "Sp106-001", ofType: "mp3")
	var isPlaying = false
	var recordingSession: AVAudioSession!
	var audioRecorder: AVAudioRecorder!
	var isRecPlaying = false
	var recPlayer:AVAudioPlayer!
	var recordedFileUrl:URL!
	
	@IBAction func recordAndSave(_ sender: Any) {
		if audioRecorder == nil {
			startRecording()
		} else {
			finishRecording(success: true)
		}
	}
	@IBAction func play(_ sender: Any) {
		if isPlaying == false {
			player.play()
			isPlaying = true
			playButton.setTitle("Pause", for: .normal)
		} else {
			player.pause()
			isPlaying = false
			playButton.setTitle("Play", for: .normal)
		}
	}
	@IBAction func playRecorded(_ sender: Any) {
		if isRecPlaying == false {
			do {
				try recPlayer = AVAudioPlayer(contentsOf: recordedFileUrl!)
				recPlayer.delegate = self

			} catch {
				print("Could not load file")
			}
		}
		
		if isPlaying == false {
			recPlayer.play()
			isRecPlaying = true
			playRecoredButton.setTitle("Pause", for: .normal)
		} else {
			recPlayer.pause()
			isRecPlaying = false
			playRecoredButton.setTitle("Play", for: .normal)
		}
	}
	
	func finishRecording(success: Bool) {
		audioRecorder.stop()
		audioRecorder = nil
		self.playRecoredButton.isEnabled = true
		if success {
			recordButton.setTitle("Tap to Re-record", for: .normal)
		} else {
			recordButton.setTitle("Tap to Record", for: .normal)
			// recording failed :(
		}
	}
	
	func audioPlayFinishing() {
		isRecPlaying = false
		playRecoredButton.setTitle("Play", for: .normal)
	}
	
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
	
	func startRecording() {
		recordedFileUrl = getDocumentsDirectory().appendingPathComponent("recording.m4a")
		
		let settings = [
			AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
			AVSampleRateKey: 12000,
			AVNumberOfChannelsKey: 1,
			AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
		]
		
		do {
			audioRecorder = try AVAudioRecorder(url: recordedFileUrl, settings: settings)
			audioRecorder.delegate = self
			audioRecorder.record()
			
			recordButton.setTitle("Tap to Stop", for: .normal)
		} catch {
			finishRecording(success: false)
		}
	}
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		print("audioPlayerDidFinishPlaying called")
		audioPlayFinishing()
	}

	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		if !flag {
			finishRecording(success: false)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		do {
			try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: path!))
		} catch {
			print("Could not load file")
		}
		
		recordingSession = AVAudioSession.sharedInstance()
		
		do {
			try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
			try recordingSession.setActive(true)
			recordingSession.requestRecordPermission() { [unowned self] allowed in
				DispatchQueue.main.async {
					if allowed {
						self.recordButton.isEnabled = true;
						} else {
						// failed to record!
					}
				}
			}
		} catch {
			// failed to record!
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

