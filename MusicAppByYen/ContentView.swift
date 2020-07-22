//
//  ContentView.swift
//  FirstAppByYen
//
//  Created by YenChang on 2020/7/4.
//  Copyright © 2020 YenChang. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var viewStack: Array<AnyView> = []
    
    var body: some View {
        
        VStack {
            if viewRouter.currentPage == 1 {
                SubViewA().transition(.scale)
            }
            else if viewRouter.currentPage == 2 {
                SubViewB().transition(.scale)
            }
            else if viewRouter.currentPage == 3 {
                ListView().transition(.scale)
            }
            else if viewRouter.currentPage == 4 {
                VideoView().transition(.scale)
            }
        }
    }
}

struct SubViewA: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var name = ""
    @State private var password = ""
    
    var body: some View {
        
        VStack {
            // Custom text field
            TextField("Your Name", text: $name)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue, lineWidth: 5))
            .padding()
            
            SecureField("Password", text: $password)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue, lineWidth: 5))
            .padding()
            
            Button("Login"){
                // actions when button is clicked
                //if !self.name.isEmpty && !self.password.isEmpty {
                    self.viewRouter.currentPage = 2
                //}
            }
        }
    }
}

struct SubViewB: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var channelImageURL = RemoteImageURL()
    @State var name = ""
    @State var titles = ["", "", ""]
    
    var screenSize = UIScreen.main.bounds
    
    var body: some View {
        
        VStack {
            
            TextField("Search Name", text: $name)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue, lineWidth: 5))
            .padding()
            .font(Font.system(size: 24, design: .default))
            .onAppear{
                for index in 0 ..< YtTool.instance.channelListSize() {
                        let imgURL = YtTool.instance.channelDataArray[index].dict["thumbnail"] as! String
                        self.channelImageURL.setImageWithURL(imageURL: imgURL, index: index)
                    }
            }
            
            HStack {
                // test button for youtube API
                Button("Search"){
                    UIApplication.shared.endEditing()
                    YtTool.instance.resetChannelList()
                    YtTool.instance.getChannelList(searchName: self.name, nextToken: false)
                    YtTool.instance.group.notify(queue: .main){
                        for index in 0 ..< YtTool.instance.channelListSize() {
                            let imgURL = YtTool.instance.channelDataArray[index].dict["thumbnail"] as! String
                            self.channelImageURL.setImageWithURL(imageURL: imgURL, index: index)
                        }
                        YtTool.instance.nextChannelIndex = YtTool.instance.channelListSize()
                    }
                }
                .padding()
                .font(Font.system(size: 24, design: .default))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.orange, lineWidth: 5))
                
                Button("  Back  "){
                    // actions when button is clicked
                    YtTool.instance.resetChannelList()
                    self.viewRouter.currentPage = 1
                }
                .padding()
                .font(Font.system(size: 24, design: .default))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.orange, lineWidth: 5))
            }
            .padding()
            
            List(YtTool.instance.channelDataArray){ channel in
                HStack{
                    Image(uiImage: self.channelImageURL.uiImages[channel.id].image)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .onAppear{
                        if channel.id == YtTool.instance.channelListSize() - 1 && self.channelImageURL.uiImages[channel.id].isSet && YtTool.instance.nextChannelToken != "" && channel.id < 30{
                            self.updateNextPage()
                        }
                    }
                    
                    Text(channel.dict["title"] as! String)
                    .frame(width: 230, height: 100)
                    
                    Button(""){
                        YtTool.instance.channelId = channel.dict["channelId"] as! String
                        YtTool.instance.getPlaylist(nextToken: false)
                        YtTool.instance.group.notify(queue: .main){
                            YtTool.instance.nextListIndex = YtTool.instance.playListSize()
                            self.viewRouter.currentPage = 3
                        }
                        
                    }
                    .frame(width: 330, height: 100)
                }
                .background(channel.id % 2 == 0 ? Color(red: 0.5, green: 0.5, blue: 0.5) : Color(red: 0.8, green: 0.8, blue: 0.8))
            }
        }
    }

    // update the channellist for next page
    func updateNextPage(){
        YtTool.instance.getChannelList(searchName: self.name, nextToken: true)
        YtTool.instance.group.notify(queue: .main){
            for index in YtTool.instance.nextChannelIndex ..< YtTool.instance.channelListSize() {
                let imgURL = YtTool.instance.channelDataArray[index].dict["thumbnail"] as! String
                self.channelImageURL.setImageWithURL(imageURL: imgURL, index: index)
            }
            YtTool.instance.nextChannelIndex = YtTool.instance.channelListSize()
        }
    }
    
}

struct ListView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var playlistImageURL = RemoteImageURL()
    
    var body: some View {
        VStack {
            Text("PlayLists")
            .padding()
            .onAppear{
                for index in 0 ..< YtTool.instance.playListSize(){
                    let imgURL = YtTool.instance.playlistDataArray[index].dict["thumbnail"] as! String
                    self.playlistImageURL.setImageWithURL(imageURL: imgURL, index: index)
                }
            }
            
            Button(" Back "){
                // actions when button is clicked
                self.viewRouter.currentPage = 2
                YtTool.instance.resetPlayList()
            }
            .padding()
            .font(Font.system(size: 24, design: .default))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.orange, lineWidth: 5))
            
            // for list in playlistDataArray
            List(YtTool.instance.playlistDataArray){ list in
                HStack{
                    Image(uiImage: self.playlistImageURL.uiImages[list.id].image)
                    .resizable()
                    .frame(width: 120, height: 90)
                    .onAppear{
                        if list.id == YtTool.instance.playListSize() - 1 && self.playlistImageURL.uiImages[list.id].isSet && YtTool.instance.nextListToken != ""{
                            self.updateNextPage()
                        }
                    }
                    
                    Text(list.dict["title"] as! String)
                    .frame(width: 200, height: 90)
                    
                    Button(""){
                        YtTool.instance.playlistId = list.dict["id"] as! String
                        //YtTool.instance.getVideolist(nextToken: false)
                        YtTool.instance.group.notify(queue: .main){
                            //YtTool.instance.nextVideoIndex = YtTool.instance.videoListSize()
                            self.viewRouter.currentPage = 4
                        }
                    }
                    .frame(width: 330, height: 80)
                }
                .background(list.id % 2 == 0 ? Color(red: 0.5, green: 0.5, blue: 0.5) : Color(red: 0.8, green: 0.8, blue: 0.8))
            }
        }
    }
    // update the playlist for next page
    func updateNextPage(){
        YtTool.instance.getPlaylist(nextToken: true)
        YtTool.instance.group.notify(queue: .main){
            for index in YtTool.instance.nextListIndex ..< YtTool.instance.playListSize() {
                let imgURL = YtTool.instance.playlistDataArray[index].dict["thumbnail"] as! String
                self.playlistImageURL.setImageWithURL(imageURL: imgURL, index: index)
            }
            YtTool.instance.nextListIndex = YtTool.instance.playListSize()
        }
    }
}

struct VideoView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var videolistImageURL = RemoteImageURL()
    
    // index for currently playing video
    @State var currentIndex = -1
    
    var body: some View {
        VStack {
            HStack {
                Button(" Back "){
                    self.viewRouter.currentPage = 3
                    YtTool.instance.resetVideoList()
                    MusicPlayer.instance.resetPlayer()
                }
                .padding()
                .font(Font.system(size: 24, design: .default))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.orange, lineWidth: 5))
                .onAppear{
                    /*for index in 0 ..< YtTool.instance.videoListSize() {
                        let imgURL = YtTool.instance.videolistDataArray[index].dict["thumbnail"] as! String
                        self.videolistImageURL.setImageWithURL(imageURL: imgURL, index: index)
                    }*/
                    self.updateNextPage()
                }
                
                Button(" Next "){
                    if self.currentIndex >= 0 {
                        self.currentIndex += 1
                        MusicPlayer.instance.player.advanceToNextItem()
                    }
                }
                .padding()
                .font(Font.system(size: 24, design: .default))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.orange, lineWidth: 5))
            }
            
            List(YtTool.instance.videolistDataArray){ video in
                HStack{
                    Image(uiImage: self.videolistImageURL.uiImages[video.id].image)
                    .resizable()
                    .frame(width: 120, height: 90)
                    .onAppear{
                        /*if video.id == 5 && self.videolistImageURL.uiImages[4].isSet && YtTool.instance.nextVideoToken != ""{
                            self.updateNextPage()
                        }*/
                    }
                    
                    Text(video.dict["title"] as! String)
                    .frame(width: 200, height: 90)
                    
                    Button(""){
                        self.currentIndex = video.id
                        YtTool.instance.videoId = video.dict["id"] as! String
                        MusicPlayer.instance.playMusic(videoId: YtTool.instance.videoId)
                        YtTool.instance.group.notify(queue: .main){
                            for i in (video.id + 1) ..< YtTool.instance.videoListSize() {
                                MusicPlayer.instance.addMusicToPlayer(videoId: YtTool.instance.videolistDataArray[i].dict["id"] as! String)
                            }
                        }
                    }
                    .frame(width: 330, height: 80)
                    
                }
                .background(self.getItemColor(id: video.id))
            }
        }
    }
    
    func getItemColor(id: Int) -> Color {
        if id == currentIndex {
            return Color.orange
        }
        
        return id % 2 == 0 ? Color(red: 0.5, green: 0.5, blue: 0.5) : Color(red: 0.8, green: 0.8, blue: 0.8)
    }
    
    // update the video for next page
    func updateNextPage(){
        YtTool.instance.getVideolist(nextToken: true)
        YtTool.instance.group.notify(queue: .main){
            for index in YtTool.instance.nextVideoIndex ..< YtTool.instance.videoListSize() {
                let imgURL = YtTool.instance.videolistDataArray[index].dict["thumbnail"] as! String
                self.videolistImageURL.setImageWithURL(imageURL: imgURL, index: index)
            }
            YtTool.instance.nextVideoIndex = YtTool.instance.videoListSize()
            
            if YtTool.instance.nextVideoToken != ""{
                self.updateNextPage()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ViewRouter())
    }
}

extension UIApplication {
    func endEditing(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


