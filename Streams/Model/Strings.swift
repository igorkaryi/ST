//
//  Strings.swift
//  Streams
//
//  Created by Igor Karyi on 22.04.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import Foundation

struct Strings {
    private init(){}
}

extension Strings {
    
    //MARK: ALERTS
    
    static let noConnectionServer: String = NSLocalizedString("No connection to the server!", comment: "No connection to the server!")
    static let checkInternetConnection: String = NSLocalizedString("Check your internet connection", comment: "Check your internet connection")
    static let attention: String = NSLocalizedString("Attention!", comment: "Attention!")
    static let fillAllFields: String = NSLocalizedString("Please fill in all the fields before you can continue", comment: "Please fill in all the fields before you can continue")
    static let incorrectEmail: String = NSLocalizedString("Enter correct email before you can continue", comment: "Enter correct email before you can continue")
    static let noHasSharedNews: String = NSLocalizedString("Today, no one has shared the news. You can be the first", comment: "Today, no one has shared the news. You can be the first")
    static let createNews: String = NSLocalizedString("Create news?", comment: "Create news?")
    static let yourLetterHasBeenSent: String = NSLocalizedString("Your letter has been sent", comment: "Your letter has been sent")
    static let yourLetterHasBeenNoSent: String = NSLocalizedString("Your email has not been sent", comment: "Your email has not been sent")
    static let youCanSharedNewsOrBlock: String = NSLocalizedString("You can share the news or block", comment: "You can share the news or block")
    static let blockNews: String = NSLocalizedString("Want to block the news?", comment: "Want to block the news?")
    static let groupName: String = NSLocalizedString("Group name", comment: "Group name")
    static let enterGroupName: String = NSLocalizedString("Enter a new group name", comment: "Enter a new group name")
    static let groupWhenSameName: String = NSLocalizedString("A group with this name already exists!", comment: "A group with this name already exists!")
    static let alreadyParticipatingSuchGroup: String = NSLocalizedString("You are already participating in such a group!", comment: "You are already participating in such a group!")
    static let noSuchGroup: String = NSLocalizedString("Such a group does not exist!", comment: "Such a group does not exist!")
    static let ctreateDiscussion: String = NSLocalizedString("Create a discussion?", comment: "Create a discussion?")
    static let noClosedDiscussion: String = NSLocalizedString("You do not have any discussions yet", comment: "You do not have any private discussions yet")
    static let willBeRemovedFromList: String = NSLocalizedString("It will be removed from your discussion list", comment: "It will be removed from your discussion list")
    
    //MARK: ALERT BUTTONS
    static let accept: String = NSLocalizedString("Accept", comment: "Accept")
    static let retry: String = NSLocalizedString("Retry", comment: "Retry")
    static let retryLater: String = NSLocalizedString("Repeat later", comment: "Repeat later")
    static let send: String = NSLocalizedString("Send", comment: "Send")
    static let block: String = NSLocalizedString("Block news", comment: "Block news")
    static let buttonNo: String = NSLocalizedString("NO", comment: "NO")
    static let buttonYes: String = NSLocalizedString("YES", comment: "YES")
    
    //MARK: BUTTONS AND TITLES
    static let addNewsButton: String = NSLocalizedString("Add news", comment: "Add news")
    static let buttonLocation: String = NSLocalizedString("City", comment: "City")
    static let buttonSubject: String = NSLocalizedString("Themes", comment: "Themes")
    static let search: String = NSLocalizedString("Search", comment: "Search")
    static let buttonAll: String = NSLocalizedString("All", comment: "All")
    static let buttonCancel: String = NSLocalizedString("Cancel", comment: "Cancel")
    static let left: String = NSLocalizedString("Left", comment: "Left")
    static let characters: String = NSLocalizedString("symbols", comment: "symbols")
    static let newGroup: String = NSLocalizedString("A new group", comment: "A new group")
    static let name: String = NSLocalizedString("Name", comment: "Name")
    static let joinToGroup: String = NSLocalizedString("Join the group", comment: "Join the group")
    static let addParticipant: String = NSLocalizedString("Add Members", comment: "Add Members")
    static let yourName: String = NSLocalizedString("Your name", comment: "Your name")
    static let yourEmail: String = NSLocalizedString("Your email", comment: "Your email")
    static let message: String = NSLocalizedString("Message", comment: "Message")
    
    static let subjectVC: String = NSLocalizedString("Themes", comment: "Themes")
    static let locationVC: String = NSLocalizedString("Location", comment: "Location")
    static let myDiscussion: String = NSLocalizedString("My discussions", comment: "My discussions")
    static let photoAndVideo: String = NSLocalizedString("Photo and video", comment: "Photo and video")
    static let feedback: String = NSLocalizedString("Feedback", comment: "Feedback")
    
    
}
