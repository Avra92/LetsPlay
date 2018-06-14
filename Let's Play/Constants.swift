//
//  Constants.swift
//  Let's Play
//
//  Created by Avra Ghosh on 10/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    //static let platDict = ["Xbox - Asia":"xbox-as", "Xbox - Europe":"xbox-eu", "Xbox - North America":"xbox-na", "Xbox - Oceania":"xbox-oc", "PC - Korea":"pc-krjp", "PC - Japan":"pc-jp", "PC - North America":"pc-na", "PC - Europe":"pc-eu", "PC - Russia":"pc-ru", "PC - Oceania":"pc-oc", "PC - Kakao":"pc-kakao", "PC - South East Asia":"pc-sea", "PC - South and Central America":"pc-sa", "PC - Asia":"pc-as","Custom URL ID":"custom","Steam 64 ID":"steam64","PC":"pc","PS4":"psn","Xbox":"xbl","Android":"Android","iOS":"iOS"]
    static let platDict = ["Custom URL ID": "custom", "Steam 64 ID": "steam64", "PC": "pc", "PS4": "psn", "Xbox": "xbl", "Android": "Android", "iOS": "iOS"]
    static let gameDict = ["Counter Strike: Global Offensive": "csgo", "Fortnite": "fort", "Clash of Clans": "coc", "Clash Royale": "cr",]
    static let gameReverseDict = ["csgo": "Counter Strike: Global Offensive", "fort": "Fortnite", "coc": "Clash of Clans", "cr": "Clash Royale"]

    static let infoDict = ["csInfo": "Please note for CSGO, please check your steam profile URL.   Select Steam 64 ID if your profile URL looks like https://steamcommunity.com/profiles/<steam64id>.  Select Custom URL ID if your profile URL looks like https://steamcommunity.com/id/<id>.", "coccrInfo": "Please note for Clash of Clans and Clash Royale provide your tag as game ID and not the game name."]

    private static let baseURL = "https://www.jak2018.freehosting.co.nz/api/"
    static let loginURL = baseURL + "login.php"
    static let friendsListUrl = baseURL + "getfriendslist.php"
    static let gameStatsURL = baseURL + "getgamestats.php"
    static let removeFriendURL = baseURL + "removefriend.php"
    static let gamesListURL = baseURL + "getgameslist.php"
    static let removeGameURL = baseURL + "removegame.php"
    static let letsPlayURL = baseURL + "letsplay.php"
    static let addGameURL = baseURL + "addgame.php"
    static let registerURL = baseURL + "register.php"
    static let searchURL = baseURL + "search.php"
    static let addFriendURL = baseURL + "addfriend.php"
    static let forgotPasswordURL = baseURL + "forgotpassword.php"
    
    static let error_internet = "Internet issue. Please try again"
    static let error_server = "Server issue. Please try again"
    static let error_general = "An error occurred. Please try again"

    static func createRequest(url: String, postString: String) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        return request
    }

    static func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { action in

        }
        alert.addAction(okAction)
        return alert;
    }
}



