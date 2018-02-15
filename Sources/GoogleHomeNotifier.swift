//
//  GoogleHomeNotifier.swift
//  GoogleHomeNotifier
//
//  Created by Watanabe Toshinori on 2/14/18.
//  Copyright © 2018 Watanabe Toshinori. All rights reserved.
//

import Foundation
import GoogleCast

public class GoogleHomeNotifier: NSObject {

    private let kModelName = "Google Home"

    // MARK: - Public Properties

    public var deviceName: String?

    public var ipAddress: String?

    public var tts: TextToSpeechService = GoogleTTS()

    // MARK: - Private properties

    private weak var device: GCKDevice?

    private var mediaURL = ""

    private var isMediaPlayed = false

    private var deviceScanner: GCKDeviceScanner?

    private var searchDeviceHandler: ((GCKDevice) -> Void)?

    private var deviceManager: GCKDeviceManager?

    private var mediaControlChannel: GCKMediaControlChannel?

    private var castMediaHandler: ((NSError?) -> Void)?

    // MARK: - Public Functions

    public func notify(message: String, language: String? = nil, completionHandler: @escaping (NSError?) -> Void) {
        GoogleHomeNotifierManager.add(notifier: self)

        if let device = device {
            speech(text: message, language: language, device: device, completionHandler: completionHandler)
        } else {
            searchDevices(completionHandler: { (device) in
                self.device = device
                self.speech(text: message, language: language, device: device, completionHandler: completionHandler)
            })
        }
    }

    public func play(url: String, completionHandler: @escaping (NSError?) -> Void) {
        GoogleHomeNotifierManager.add(notifier: self)

        if let device = device {
            play(url: url, device: device, completionHandler: completionHandler)
        } else {
            searchDevices(completionHandler: { (device) in
                self.device = device
                self.play(url: url, device: device, completionHandler: completionHandler)
            })
        }
    }

    // MARK: - Cast media to Google Home

    private func speech(text: String, language: String? = nil, device: GCKDevice, completionHandler: @escaping (NSError?) -> Void) {
        tts.speechURL(for: text, language: language) { (url) in
            self.play(url: url.absoluteString, device: device, completionHandler: completionHandler)
        }
    }

    private func play(url: String, device: GCKDevice, completionHandler: @escaping (NSError?) -> Void) {
        mediaURL = url
        isMediaPlayed = false
        castMediaHandler = completionHandler

        connect(to: device)
    }

    // MARK: - Search Google Hoome

    private func searchDevices(completionHandler: @escaping (GCKDevice) -> Void) {
        searchDeviceHandler = completionHandler

        // Establish filter criteria.
        let filterCriteria = GCKFilterCriteria(forAvailableApplicationWithID: kGCKMediaDefaultReceiverApplicationID)

        // Initialize device scanner.
        deviceScanner = GCKDeviceScanner(filterCriteria: filterCriteria)

        if let deviceScanner = deviceScanner {
            deviceScanner.add(self)
            deviceScanner.startScan()
            deviceScanner.passiveScan = true
        }
    }

    private func connect(to device: GCKDevice) {
        // Initialize device manager
        deviceManager = GCKDeviceManager(device: device, clientPackageName: Bundle.main.bundleIdentifier)

        if let deviceManager = deviceManager {
            deviceManager.delegate = self
            deviceManager.connect()
        }
    }

    private func disconnect() {
        deviceManager?.leaveApplication()
        deviceManager?.disconnect()
        deviceManager = nil
        device = nil

        GoogleHomeNotifierManager.remove(notifier: self)
    }

}

// MARK: - Device Scanner

extension GoogleHomeNotifier: GCKDeviceScannerListener {

    public func deviceDidComeOnline(_ device: GCKDevice!) {
        print("Device found: \(device)")

        let shouldSelect: Bool = {
            if let deviceName = deviceName {
                return device.friendlyName == deviceName
            }

            if let ipAddress = ipAddress {
                return device.ipAddress == ipAddress
            }

            return device.modelName == kModelName
        }()

        if shouldSelect {
            searchDeviceHandler?(device)
            searchDeviceHandler = nil

            deviceScanner?.stopScan()
            deviceScanner = nil
        }
    }

}

// MARK: - Device Manager

extension GoogleHomeNotifier: GCKDeviceManagerDelegate {

    public func deviceManagerDidConnect(_ deviceManager: GCKDeviceManager!) {
        print("Device connected")

        deviceManager.launchApplication(kGCKMediaDefaultReceiverApplicationID)
    }

    public func deviceManager(_ deviceManager: GCKDeviceManager!,
                              didConnectToCastApplication applicationMetadata: GCKApplicationMetadata!,
                              sessionID: String!,
                              launchedApplication: Bool) {

        print("Device connected to Application")

        let mediaInformation = GCKMediaInformation(
            contentID: mediaURL,
            streamType: .buffered,
            contentType: "audio/mp3",
            metadata: nil,
            streamDuration: 0,
            mediaTracks: [],
            textTrackStyle: nil,
            customData: nil
        )

        // Cast the media
        mediaControlChannel = GCKMediaControlChannel()

        if let mediaControlChannel = mediaControlChannel {
            mediaControlChannel.delegate = self
            deviceManager.add(mediaControlChannel)
            mediaControlChannel.loadMedia(mediaInformation, autoplay: true)
        }
    }

    public func deviceManager(_ deviceManager: GCKDeviceManager!, didFailToConnectToApplicationWithError error: Error!) {
        print(error)

        castMediaHandler?(error as NSError)
        castMediaHandler = nil

        disconnect()
    }

    public func deviceManager(_ deviceManager: GCKDeviceManager!, didFailToConnectWithError error: Error!) {
        print(error)

        castMediaHandler?(error as NSError)
        castMediaHandler = nil

        disconnect()
    }

    public func deviceManager(_ deviceManager: GCKDeviceManager!, didDisconnectWithError error: Error!) {
        print(error)

        castMediaHandler?(error as NSError)
        castMediaHandler = nil

        disconnect()
    }

}

// MARK: - MediaControlChannel Delegate

extension GoogleHomeNotifier: GCKMediaControlChannelDelegate {

    public func mediaControlChannelDidUpdateStatus(_ mediaControlChannel: GCKMediaControlChannel!) {
        if let mediaStatus = mediaControlChannel.mediaStatus {
            switch mediaStatus.playerState {
            case .buffering:
                print("Device state: buffering")
            case .idle:
                print("Device state: idle")
                if isMediaPlayed {
                    castMediaHandler?(nil)
                    castMediaHandler = nil

                    disconnect()
                }
            case .paused:
                print("Device state: paused")
            case .playing:
                isMediaPlayed = true
                print("Device state: playing")
            case .unknown:
                print("Device state: unknown")
            }
        }
    }

    public func mediaControlChannel(_ mediaControlChannel: GCKMediaControlChannel!, didCompleteLoadWithSessionID sessionID: Int) {
        print("Device notified")
    }

    public func mediaControlChannel(_ mediaControlChannel: GCKMediaControlChannel!, didFailToLoadMediaWithError error: Error!) {
        print(error)

        castMediaHandler?(error as NSError)
        castMediaHandler = nil

        disconnect()
    }

}
