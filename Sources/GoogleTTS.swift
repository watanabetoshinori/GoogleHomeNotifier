//
//  GoogleTTS.swift
//  GoogleHomeNotifier
//
//  Created by Watanabe Toshinori on 2/14/18.
//  Copyright © 2018 Watanabe Toshinori. All rights reserved.
//

import UIKit

/**
 Google TTS
 */
public class GoogleTTS: TextToSpeechService {

    var language = "en"

    // MARK: - Initialize

    @available(iOS, deprecated: 1.0, message: "Google TTS is an unofficial API. Please use IBM TTS or other TTS.")
    public convenience init(language: String? = nil) {
        self.init()

        if let language = language {
            self.language = language
        }
    }

    // MARK: - Text To Speech

    public func speechURL(for text: String, language: String?, completionHandler: @escaping (URL) -> Void) {
        guard let url = self.generateSpeechURL(text: text, language: language ?? self.language) else {
            fatalError()
        }

        DispatchQueue.main.async {
            completionHandler(url)
        }
    }

    private func generateSpeechURL(text: String, language: String) -> URL? {
        var urlComponents = URLComponents(string: "https://translate.google.com/translate_tts")
        urlComponents?.queryItems = [
            URLQueryItem(name: "ie", value: "UTF-8"),
            URLQueryItem(name: "q", value: text),
            URLQueryItem(name: "tl", value: language),
            URLQueryItem(name: "client", value: "tw-ob"),
        ]
        return urlComponents?.url
    }

}
