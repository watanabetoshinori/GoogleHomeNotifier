//
//  TextToSpeechService.swift
//  GoogleHomeNotifier
//
//  Created by Watanabe Toshinori on 2/14/18.
//  Copyright © 2018 Watanabe Toshinori. All rights reserved.
//

import UIKit

/**
 TTS API Protocol
 */
public protocol TextToSpeechService {

    func speechURL(for text: String, language: String?, completionHandler: @escaping (URL) -> Void)

}
