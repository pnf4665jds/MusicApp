//
//  YtTool.swift
//  FirstAppByYen
//
//  Created by YenChang on 2020/7/6.
//  Copyright © 2020 YenChang. All rights reserved.
//

import Foundation
import SwiftUI

class YtTool: NSObject {
    // this class is in singleton pattern
    // instance for class
    static let instance = YtTool()
    
    struct DataElement: Identifiable{
        let id: Int
        let dict: Dictionary<String, AnyObject>
    }
    
    // key for youtube data api
    var apiKey = "AIzaSyDX9qMtveddS-TUo-v8_-SJibnJQRR-CTc"
    // array to store channel data
    var channelDataArray: Array<DataElement> = []
    // array to store specific playlist
    var playlistDataArray: Array<DataElement> = []
    // array to store specific playlist
    var videolistDataArray: Array<DataElement> = []
    // queue for async
    let myQueue = DispatchQueue(label: "data")
    // group to manipulate async task
    let group = DispatchGroup()
    // group2
    let group2 = DispatchGroup()
    // next page token of channel
    var nextChannelToken = ""
    // first index of next channel list
    var nextChannelIndex = 0
    // next page token of list
    var nextListToken = ""
    // first index of next page list
    var nextListIndex = 0
    // next page token of video
    var nextVideoToken = ""
    // first index of next page video
    var nextVideoIndex = 0
    // id for playlist
    var playlistId = ""
    // id for channel
    var channelId = ""
    // id for video
    var videoId = ""
    
    // override init to prevent instantiate form other place
    private override init () {
        
    }
    
    // function to make a GET request
    func performGetRequest(targetURL: URL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: Error?) -> Void){
        var request = URLRequest(url: targetURL)    // get request form target url
        request.httpMethod = "GET"
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            DispatchQueue.main.async(group: self.group) {
                () -> Void in completion(data, (response as! HTTPURLResponse).statusCode, error)
            }})
        
        task.resume()
    }
    
    // get channel list with specific name
    func getChannelList(searchName: String, nextToken: Bool){
        var urlString: String!
        // url for youtube API
        urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=channel&q=\(searchName)&key=\(apiKey)" + (nextToken && nextChannelToken != "" ? "&pageToken=\(nextChannelToken)" : "")
        // convert url in QueryAllowed format
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let targetURL = URL(string: urlString)
        self.group.enter()
        // call for request
        performGetRequest(targetURL: targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            // if successfully get response without error
            if HTTPStatusCode == 200 && error == nil {
                do {
                    // convert JSON data to dictionary data structure
                    let resultDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
                    
                    //print(resultDict)
                    // check if there is next page
                    if resultDict["nextPageToken"] != nil {
                        self.nextChannelToken = resultDict["nextPageToken"] as! String
                    }
                    else {
                        self.nextChannelToken = ""
                    }
                    // get data from resultDict with key "items"
                    // and then get first element of dictionary from items
                    let items: AnyObject! = resultDict["items"]
                    
                    for index in 0 ..< items.count {
                        
                        let firstItemDict = (items as! Array<AnyObject>)[index] as! Dictionary<String, AnyObject>
                        // get "snippet" dictionary with the needed data in it
                        //print(firstItemDict)
                        let snippetDict = firstItemDict["snippet"] as! Dictionary<String, AnyObject>
                        // create new dictionary to store the info we need
                        var desiredValueDict = Dictionary<String, AnyObject>()
                        desiredValueDict["title"] = snippetDict["title"]
                        desiredValueDict["channelId"] = snippetDict["channelId"]
                        desiredValueDict["description"] = snippetDict["description"]
                        desiredValueDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                        // append back to array
                        self.channelDataArray.append(DataElement(id: self.nextChannelIndex + index, dict: desiredValueDict))
                    }
                    self.group.leave()
                }
                catch {
                    print(error)
                }
                
            }
            else {
                // print error message
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
            }
        })
    }
    
    // get playlist with specific channel id
    func getPlaylist(nextToken: Bool){
        var urlString: String!
        // url for youtube API
        urlString = "https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=\(self.channelId)&key=\(apiKey)&maxResults=10" + (nextToken && nextListToken != "" ? "&pageToken=\(nextListToken)" : "")
        // convert url in QueryAllowed format
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let targetURL = URL(string: urlString)
        self.group.enter()
        // call for request
        performGetRequest(targetURL: targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            // if successfully get response without error
            if HTTPStatusCode == 200 && error == nil {
                do {
                    // convert JSON data to dictionary data structure
                    let resultDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
                    
                    //print(resultDict)
                    // check if there is next page
                    if resultDict["nextPageToken"] != nil {
                        self.nextListToken = resultDict["nextPageToken"] as! String
                    }
                    else {
                        self.nextListToken = ""
                    }
                    // get data from resultDict with key "items"
                    // and then get first element of dictionary from items
                    let items: AnyObject! = resultDict["items"]
                    
                    for index in 0 ..< items.count {
                        
                        let firstItemDict = (items as! Array<AnyObject>)[index] as! Dictionary<String, AnyObject>
                        // get "snippet" dictionary with the needed data in it
                        //print(firstItemDict)
                        let snippetDict = firstItemDict["snippet"] as! Dictionary<String, AnyObject>
                        // create new dictionary to store the info we need
                        var desiredValueDict = Dictionary<String, AnyObject>()
                        desiredValueDict["id"] = firstItemDict["id"]
                        desiredValueDict["title"] = snippetDict["title"]
                        desiredValueDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                        // append back to array
                        self.playlistDataArray.append(DataElement(id: self.nextListIndex + index, dict: desiredValueDict))
                    }
                    self.group.leave()
                }
                catch {
                    print(error)
                }
                
            }
            else {
                // print error message
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
            }
        })
    }
    
    // get videolist with specific playlist id
    func getVideolist(nextToken: Bool){
        var urlString: String!
        // url for youtube API
        urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.playlistId)&key=\(apiKey)&maxResults=10" + (nextToken && nextVideoToken != "" ? "&pageToken=\(nextVideoToken)" : "")
        // convert url in QueryAllowed format
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let targetURL = URL(string: urlString)
        self.group.enter()
        // call for request
        performGetRequest(targetURL: targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            // if successfully get response without error
            if HTTPStatusCode == 200 && error == nil {
                do {
                    // convert JSON data to dictionary data structure
                    let resultDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
                    
                    //print(resultDict)
                    // check if there is next page
                    if resultDict["nextPageToken"] != nil {
                        self.nextVideoToken = resultDict["nextPageToken"] as! String
                    }
                    else {
                        self.nextVideoToken = ""
                    }
                    // get data from resultDict with key "items"
                    // and then get first element of dictionary from items
                    let items: AnyObject! = resultDict["items"]
                    // number of private video
                    var privateVideoNum = 0
                    
                    for index in 0 ..< items.count {
                        
                        let firstItemDict = (items as! Array<AnyObject>)[index] as! Dictionary<String, AnyObject>
                        // get "snippet" dictionary with the needed data in it
                        //print(firstItemDict)
                        let snippetDict = firstItemDict["snippet"] as! Dictionary<String, AnyObject>
                        // skip private videos
                        if snippetDict["title"] as! String == "Private video"{
                            privateVideoNum += 1
                            continue
                        }
                        // create new dictionary to store the info we need
                        var desiredValueDict = Dictionary<String, AnyObject>()
                        desiredValueDict["id"] = (snippetDict["resourceId"] as! Dictionary<String, AnyObject>)["videoId"]
                        desiredValueDict["title"] = snippetDict["title"]
                        desiredValueDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                        // append back to array
                        self.videolistDataArray.append(DataElement(id: self.nextVideoIndex + index - privateVideoNum, dict: desiredValueDict))
                    }
                    self.group.leave()
                }
                catch {
                    print(error)
                }
                
            }
            else {
                // print error message
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
            }
        })
    }
    
    // get the current max size of channels
    func channelListSize()-> Int{
        return self.channelDataArray.count
    }
    
    // get the current max size of playlist
    func playListSize()-> Int{
        return self.playlistDataArray.count
    }
    
    // get the current max size of videolist
    func videoListSize()-> Int{
        return self.videolistDataArray.count
    }
    
    // reset the info related to channel list
    func resetChannelList(){
        self.channelDataArray.removeAll()
        self.nextChannelToken = ""
        self.nextChannelIndex = 0
    }
    
    // reset the info related to play list
    func resetPlayList(){
        self.playlistDataArray.removeAll()
        self.nextListToken = ""
        self.nextListIndex = 0
    }
    
    // reset the info related to video list
    func resetVideoList(){
        self.videolistDataArray.removeAll()
        self.nextVideoToken = ""
        self.nextVideoIndex = 0
    }
}
