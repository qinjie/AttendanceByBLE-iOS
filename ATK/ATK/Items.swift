//
//  Items.swift
//  ATKStudent
//
//  Created by xuhelios on 11/24/16.
//  Copyright © 2016 xuhelios. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Constants{
    static let baseURL = "http://188.166.247.154"
    static var token = ""
    static var username = ""
    static var password = ""
    static var name = ""
    static var id = 0
    static var acad = ""
}

struct user{
    var name : String
    var acad : String
    var id : String
    init(){
        name = "ABC"
        acad = "ABC"
        id = "0"
        
    }
}

var currentUser = user()


/*JSON  [
 {
 "lesson" : {
 "id" : 49,
 "subject_area" : "ELECTRO",
 "module_id" : "006492",
 "semester" : "1",
 "facility" : "06-03-0004",
 "component" : "PRA",
 "meeting_pattern" : "EVEN",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1DEL",
 "venue_id" : 1,
 "start_time" : "08:00:00",
 "updated_at" : "2016-11-16 02:37:21",
 "end_time" : "10:00:00",
 "class_section" : "P2L1",
 "weekday" : "2"
 },
 "lesson_id" : 49,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 80,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : {
 "beacon" : {
 "id" : 3,
 "minor" : 59,
 "user_id" : 59,
 "major" : 2,
 "updated_at" : "2016-11-17 03:38:05",
 "created_at" : "2016-11-17 03:38:05"
 },
 "acad" : "ECE",
 "id" : 2,
 "card" : "9376",
 "created_at" : "0000-00-00 00:00:00",
 "email" : "ccy6@np.edu.sg",
 "user_id" : 59,
 "updated_at" : "2016-11-23 04:40:26",
 "name" : "CHENG CHEE YUEN"
 },
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24373,
 "lesson_id" : 49,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-12",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 41,
 "subject_area" : "ELECTRO",
 "module_id" : "007685",
 "semester" : "1",
 "facility" : "05-03-0001",
 "component" : "LEC",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1AMPR",
 "venue_id" : 1,
 "start_time" : "10:00:00",
 "updated_at" : "2016-11-16 02:37:21",
 "end_time" : "12:00:00",
 "class_section" : "L2L",
 "weekday" : "2"
 },
 "lesson_id" : 41,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 72,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : null,
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24371,
 "lesson_id" : 41,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-12",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 53,
 "subject_area" : "IS MATH",
 "module_id" : "005696",
 "semester" : "1",
 "facility" : "04-02-0002",
 "component" : "LEC",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1EM3A",
 "venue_id" : 1,
 "start_time" : "13:00:00",
 "updated_at" : "2016-11-16 02:37:21",
 "end_time" : "15:00:00",
 "class_section" : "LL12",
 "weekday" : "2"
 },
 "lesson_id" : 53,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 84,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : {
 "beacon" : {
 "id" : 7,
 "minor" : 63,
 "user_id" : 63,
 "major" : 2,
 "updated_at" : "2016-11-17 03:38:05",
 "created_at" : "2016-11-17 03:38:05"
 },
 "acad" : "ECE",
 "id" : 12946,
 "card" : "12946",
 "created_at" : "0000-00-00 00:00:00",
 "email" : "kks6@np.edu.sg",
 "user_id" : 63,
 "updated_at" : "2016-11-23 04:34:00",
 "name" : "KOH KAR SENG"
 },
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24374,
 "lesson_id" : 53,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-12",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 47,
 "subject_area" : "ELECTRO",
 "module_id" : "006492",
 "semester" : "1",
 "facility" : "06-05-0001",
 "component" : "LEC",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1DEL",
 "venue_id" : 1,
 "start_time" : "15:00:00",
 "updated_at" : "2016-11-16 02:37:21",
 "end_time" : "17:00:00",
 "class_section" : "LL12",
 "weekday" : "2"
 },
 "lesson_id" : 47,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 78,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : null,
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24372,
 "lesson_id" : 47,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-12",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 51,
 "subject_area" : "ELECTRO",
 "module_id" : "009885",
 "semester" : "1",
 "facility" : "04-05-0001",
 "component" : "PRA",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1EDPT1",
 "venue_id" : 1,
 "start_time" : "09:00:00",
 "updated_at" : "2016-11-16 02:37:36",
 "end_time" : "12:00:00",
 "class_section" : "P2L1",
 "weekday" : "3"
 },
 "lesson_id" : 51,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 82,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : {
 "beacon" : {
 "id" : 5,
 "minor" : 61,
 "user_id" : 61,
 "major" : 2,
 "updated_at" : "2016-11-17 03:38:05",
 "created_at" : "2016-11-17 03:38:05"
 },
 "acad" : "ECE",
 "id" : 9580,
 "card" : "9580",
 "created_at" : "0000-00-00 00:00:00",
 "email" : "faj2@np.edu.sg",
 "user_id" : 61,
 "updated_at" : "2016-11-23 04:34:00",
 "name" : "FOO JONG YONG ABDIEL"
 },
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24400,
 "lesson_id" : 51,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-13",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 46,
 "subject_area" : "ELECTRO",
 "module_id" : "008045",
 "semester" : "1",
 "facility" : "08-06-0001",
 "component" : "PRA",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1APPG",
 "venue_id" : 1,
 "start_time" : "13:00:00",
 "updated_at" : "2016-11-16 02:37:36",
 "end_time" : "15:00:00",
 "class_section" : "P2L1",
 "weekday" : "3"
 },
 "lesson_id" : 46,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 77,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : null,
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24399,
 "lesson_id" : 46,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-13",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 44,
 "subject_area" : "ELECTRO",
 "module_id" : "010152",
 "semester" : "1",
 "facility" : "06-03-0006",
 "component" : "TUT",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1EGPHY",
 "venue_id" : 1,
 "start_time" : "15:00:00",
 "updated_at" : "2016-11-16 02:37:36",
 "end_time" : "16:00:00",
 "class_section" : "T2L1",
 "weekday" : "3"
 },
 "lesson_id" : 44,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 75,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : null,
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24398,
 "lesson_id" : 44,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-13",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 43,
 "subject_area" : "ELECTRO",
 "module_id" : "011197",
 "semester" : "1",
 "facility" : "58-01-0002",
 "component" : "TUT",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "2CPP2",
 "venue_id" : 1,
 "start_time" : "10:00:00",
 "updated_at" : "2016-11-16 02:37:43",
 "end_time" : "12:00:00",
 "class_section" : "T2L1",
 "weekday" : "4"
 },
 "lesson_id" : 43,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 74,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : null,
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24426,
 "lesson_id" : 43,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-14",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 56,
 "subject_area" : "AE",
 "module_id" : "010428",
 "semester" : "1",
 "facility" : "",
 "component" : "PRA",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "  75INT6",
 "venue_id" : 3,
 "start_time" : "17:00:00",
 "updated_at" : "2016-11-16 02:37:43",
 "end_time" : "18:00:00",
 "class_section" : "PL23",
 "weekday" : "4"
 },
 "lesson_id" : 56,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 87,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : null,
 "venue" : {
 "location" : "08-06-08",
 "major" : 29225,
 "minor" : 63081,
 "id" : 3,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "Research Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24427,
 "lesson_id" : 56,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-14",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 52,
 "subject_area" : "ELECTRO",
 "module_id" : "010152",
 "semester" : "1",
 "facility" : "04-02-0002",
 "component" : "LEC",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1EGPHY",
 "venue_id" : 1,
 "start_time" : "08:00:00",
 "updated_at" : "2016-11-16 02:37:51",
 "end_time" : "10:00:00",
 "class_section" : "L2L",
 "weekday" : "5"
 },
 "lesson_id" : 52,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 83,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : {
 "beacon" : {
 "id" : 6,
 "minor" : 62,
 "user_id" : 62,
 "major" : 2,
 "updated_at" : "2016-11-17 03:38:05",
 "created_at" : "2016-11-17 03:38:05"
 },
 "acad" : "ECE",
 "id" : 9,
 "card" : "938",
 "created_at" : "0000-00-00 00:00:00",
 "email" : "ksk@np.edu.sg",
 "user_id" : 62,
 "updated_at" : "2016-11-23 04:41:05",
 "name" : "KOH SIEW KHENG"
 },
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24450,
 "lesson_id" : 52,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-15",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 50,
 "subject_area" : "ELECTRO",
 "module_id" : "006492",
 "semester" : "1",
 "facility" : "06-06-0006",
 "component" : "TUT",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1DEL",
 "venue_id" : 1,
 "start_time" : "10:00:00",
 "updated_at" : "2016-11-16 02:37:51",
 "end_time" : "11:00:00",
 "class_section" : "T2L1",
 "weekday" : "5"
 },
 "lesson_id" : 50,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 81,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : {
 "beacon" : {
 "id" : 4,
 "minor" : 60,
 "user_id" : 60,
 "major" : 2,
 "updated_at" : "2016-11-17 03:38:05",
 "created_at" : "2016-11-17 03:38:05"
 },
 "acad" : "ECE",
 "id" : 1,
 "card" : "8944",
 "created_at" : "0000-00-00 00:00:00",
 "email" : "qinjie@np.edu.sg",
 "user_id" : 60,
 "updated_at" : "2016-11-23 04:40:33",
 "name" : "ZHANG QINJIE"
 },
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24449,
 "lesson_id" : 50,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-15",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 55,
 "subject_area" : "IS MATH",
 "module_id" : "005696",
 "semester" : "1",
 "facility" : "04-03-0007",
 "component" : "TUT",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1EM3A",
 "venue_id" : 1,
 "start_time" : "11:00:00",
 "updated_at" : "2016-11-16 02:37:51",
 "end_time" : "12:00:00",
 "class_section" : "T2L1",
 "weekday" : "5"
 },
 "lesson_id" : 55,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 86,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : {
 "beacon" : {
 "id" : 20,
 "minor" : 69,
 "user_id" : 69,
 "major" : 2,
 "updated_at" : "2016-11-17 03:38:05",
 "created_at" : "2016-11-17 03:38:05"
 },
 "acad" : "ECE",
 "id" : 3,
 "card" : "495",
 "created_at" : "0000-00-00 00:00:00",
 "email" : "tcc@np.edu.sg",
 "user_id" : 69,
 "updated_at" : "2016-11-24 01:55:54",
 "name" : "TAN CHIN CHYE"
 },
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24451,
 "lesson_id" : 55,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-15",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 48,
 "subject_area" : "ELECTRO",
 "module_id" : "006492",
 "semester" : "1",
 "facility" : "06-05-0001",
 "component" : "LEC",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1DEL",
 "venue_id" : 1,
 "start_time" : "12:00:00",
 "updated_at" : "2016-11-16 02:37:51",
 "end_time" : "13:00:00",
 "class_section" : "LL12",
 "weekday" : "5"
 },
 "lesson_id" : 48,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 79,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : null,
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24448,
 "lesson_id" : 48,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-15",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 42,
 "subject_area" : "ELECTRO",
 "module_id" : "007685",
 "semester" : "1",
 "facility" : "46-01-0003",
 "component" : "PRA",
 "meeting_pattern" : "ODD",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1AMPR",
 "venue_id" : 1,
 "start_time" : "15:00:00",
 "updated_at" : "2016-11-16 02:37:51",
 "end_time" : "17:00:00",
 "class_section" : "P2L1",
 "weekday" : "5"
 },
 "lesson_id" : 42,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 73,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : null,
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24447,
 "lesson_id" : 42,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-15",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 54,
 "subject_area" : "IS MATH",
 "module_id" : "005696",
 "semester" : "1",
 "facility" : "04-02-0002",
 "component" : "LEC",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1EM3A",
 "venue_id" : 1,
 "start_time" : "09:00:00",
 "updated_at" : "2016-11-16 02:38:00",
 "end_time" : "10:00:00",
 "class_section" : "LL12",
 "weekday" : "6"
 },
 "lesson_id" : 54,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 85,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : {
 "beacon" : {
 "id" : 8,
 "minor" : 64,
 "user_id" : 64,
 "major" : 2,
 "updated_at" : "2016-11-17 03:38:05",
 "created_at" : "2016-11-17 03:38:05"
 },
 "acad" : "ECE",
 "id" : 25,
 "card" : "4980",
 "created_at" : "0000-00-00 00:00:00",
 "email" : "tks5@np.edu.sg",
 "user_id" : 64,
 "updated_at" : "2016-11-23 04:42:07",
 "name" : "TANG KIM SENG"
 },
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24475,
 "lesson_id" : 54,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-16",
 "updated_by" : 1
 }
 },
 {
 "lesson" : {
 "id" : 45,
 "subject_area" : "ELECTRO",
 "module_id" : "008045",
 "semester" : "1",
 "facility" : "05-02-0015",
 "component" : "PRA",
 "meeting_pattern" : "",
 "created_at" : "0000-00-00 00:00:00",
 "catalog_number" : "1APPG",
 "venue_id" : 1,
 "start_time" : "10:00:00",
 "updated_at" : "2016-11-16 02:38:00",
 "end_time" : "12:00:00",
 "class_section" : "P2L1",
 "weekday" : "6"
 },
 "lesson_id" : 45,
 "updated_at" : "0000-00-00 00:00:00",
 "id" : 76,
 "created_at" : "2016-04-26 03:10:06",
 "student_id" : 1,
 "lecturers" : null,
 "venue" : {
 "location" : "08-06-09",
 "major" : 44455,
 "minor" : 7738,
 "id" : 1,
 "created_at" : "2016-11-23 04:53:25",
 "uuid" : "",
 "updated_at" : "2016-11-23 05:22:51",
 "name" : "R&D Room"
 },
 "lesson_date" : {
 "created_at" : "2016-11-17 06:35:50",
 "id" : 24474,
 "lesson_id" : 45,
 "updated_at" : "2016-11-17 06:35:50",
 "ldate" : "2016-12-16",
 "updated_by" : 1
 }
 }
 ]*/
