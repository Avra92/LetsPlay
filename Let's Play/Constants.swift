//
//  Constants.swift
//  Let's Play
//
//  Created by Avra Ghosh on 10/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import Foundation

class Constants {
    //static let platDict = ["Xbox - Asia":"xbox-as", "Xbox - Europe":"xbox-eu", "Xbox - North America":"xbox-na", "Xbox - Oceania":"xbox-oc", "PC - Korea":"pc-krjp", "PC - Japan":"pc-jp", "PC - North America":"pc-na", "PC - Europe":"pc-eu", "PC - Russia":"pc-ru", "PC - Oceania":"pc-oc", "PC - Kakao":"pc-kakao", "PC - South East Asia":"pc-sea", "PC - South and Central America":"pc-sa", "PC - Asia":"pc-as","Custom URL ID":"custom","Steam 64 ID":"steam64","PC":"pc","PS4":"psn","Xbox":"xbl","Android":"Android","iOS":"iOS"]
    static let platDict = ["Custom URL ID":"custom","Steam 64 ID":"steam64","PC":"pc","PS4":"psn","Xbox":"xbl","Android":"Android","iOS":"iOS"]
    static let gameDict = ["Counter Strike: Global Offensive":"csgo","Fortnite":"fort","Clash of Clans":"coc","Clash Royale":"cr",]
    static let gameReverseDict = ["csgo":"Counter Strike: Global Offensive","fort":"Fortnite","coc":"Clash of Clans","cr":"Clash Royale"]
    
    static let infoDict = ["csInfo":"Please note for CSGO, please check your steam profile URL.   Select Steam 64 ID if your profile URL looks like https://steamcommunity.com/profiles/<steam64id>.  Select Custom URL ID if your profile URL looks like https://steamcommunity.com/id/<id>.","coccrInfo":"Please note for Clash of Clans and Clash Royale provide your tag as game ID and not the game name."]
}


