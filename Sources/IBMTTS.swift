//
//  IBMTTS.swift
//  GoogleHomeNotifier
//
//  Created by Watanabe Toshinori on 2/14/18.
//  Copyright © 2018 Watanabe Toshinori. All rights reserved.
//

import UIKit

/**
 IBM Watson TTS
 https://www.ibm.com/watson/services/text-to-speech/
 */
public class IBMTTS: TextToSpeechService {

    var username: String!

    var password: String!

    var language = "en-US_MichaelVoice"

    private var token: String?

    // MARK: - Initialize

    public convenience init(username: String, password: String, language: String? = nil) {
        self.init()
        self.username = username
        self.password = password

        if let language = language {
            self.language = language
        }
    }

    // MARK: - Text To Speech

    public func speechURL(for text: String, language: String?, completionHandler: @escaping (URL) -> Void) {
        getAPIToken { (token) in
            self.token = token

            guard let url = self.generateSpeechURL(text: text, language: language ?? self.language) else {
                fatalError()
            }

            DispatchQueue.main.async {
                completionHandler(url)
            }
        }
    }

    private func getAPIToken(completionHandler: @escaping (String) -> Void) {
        if let token = token {
            // Token already loaded
            completionHandler(token)
            return
        }

        let loginData = String(format: "%@:%@", username, password).data(using: .utf8)!
        let base64Credential = loginData.base64EncodedString()

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization": "Basic \(base64Credential)"]
        let session = URLSession(configuration: configuration)

        var urlComponents = URLComponents(string: "https://stream.watsonplatform.net/authorization/api/v1/token")
        urlComponents?.queryItems = [
            URLQueryItem(name: "url", value: "https://stream.watsonplatform.net/text-to-speech/api")
        ]

        guard let url = urlComponents?.url else {
            fatalError()
        }

        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }

            if let data = data {
                let token = String(data: data, encoding: .utf8)!
                completionHandler(token)
            }
        }
        task.resume()
    }

    private func generateSpeechURL(text: String, language: String) -> URL? {
        var urlComponents = URLComponents(string: "https://stream.watsonplatform.net/text-to-speech/api/v1/synthesize")
        urlComponents?.queryItems = [
            URLQueryItem(name: "accept", value: "audio/mp3"),
            URLQueryItem(name: "voice", value: language),
            URLQueryItem(name: "text", value: text),
        ]
        if let query = urlComponents?.percentEncodedQuery {
            urlComponents?.percentEncodedQuery = query + "&watson-token=\(token!)"
        }
        return urlComponents?.url
    }

}
