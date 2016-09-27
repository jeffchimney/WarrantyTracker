//
//  CalendarEvent.swift
//  WarrantyTracker
//
//  Created by Jeff Chimney on 2016-09-27.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import Foundation
import EventKit
import EventKitUI

var eventStore : EKEventStore = EKEventStore()

class CalendarEvent {
    
    var event: EKEvent = EKEvent(eventStore: eventStore)
    var title: String = ""
    var startDate: Date
    var endDate: Date
    var notes: String = ""
    
    init(withNotes title: String, startDate: Date, endDate: Date, notes: String) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
    }
    
    init(withoutNotes title: String, startDate: Date, endDate: Date) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func createReminder() {
        eventStore.requestAccess(to: .reminder, completion: {granted,error in
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let reminder:EKReminder = EKReminder(eventStore: eventStore)
                
                do {
                    try eventStore.save(reminder, commit: true)
                } catch {
                    print("error \(error)")
                }
                print("Saved Event")
            }
        })
    }
    
    func createCalendarEvent() {
        eventStore.requestAccess(to: .event, completion: {granted,error in
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                
                do {
                    try eventStore.save(event, span: EKSpan.thisEvent)
                } catch {
                    print(error)
                }
                
                print("Saved Event")
            }
        })
    }
}
