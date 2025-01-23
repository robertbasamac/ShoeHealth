//
//  Prompts.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 03.06.2024.
//

struct Prompts {
    
    struct SelectShoe {
        static let selectDefaultShoeTitle: String = "Select Default Shoe"
        static let selectDefaultShoeDescription: String = "Choose your Default Shoe for new workouts. This setting allows you to quickly assign your preferred shoe to each new running session, ensuring consistency and convenience in your routine."
        
        static func selectDefaultShoeTitle(for runType: RunType) -> String {
            return "Select Default Shoe for \(runType.rawValue.capitalized)"
        }
        
        static func selectDefaultShoeDescription(for runType: RunType) -> String {
            return "Choose your Default Shoe for \(runType.rawValue.capitalized) workouts. This setting allows you to quickly assign your preferred shoe to \(runType.rawValue.lowercased()) sessions, ensuring consistency and convenience in your routine."
        }
        
        static let selectWorkoutShoeTitle = "Select Shoe for Workout"
        static let selectWorkoutShoeDescription = "Select the Shoe you used for this running session to ensure accurate tracking."
        
        static let selectMultipleWorkoutShoeTitle = "Select Shoe for each Workout"
        static let selectMultipleWorkoutShoeDescription = "Select the Shoe you used for each running session to ensure accurate tracking."
        
        static let assignWorkoutsTitle = "Assign Workouts to Shoe"
        static let assignWorkoutsDescription = "Select the new Shoe to assign the selected workouts to."
    }
    
    struct HealthAccess {
        static let title = "Allow access to Apple Health"
        static let description = "To track your running gear health, access to Apple Health data is needed. This helps us not only manage your running gear health, but to also provide personalized insights and statistics."
        static let note = "Note: this is a mandatory step in order for Shoe Health to help you track your running gear health."
    }
    
    struct Notifications {
        static let title = "Allow access to Notifications"
        static let description = "Stay updated with the latest alerts by enabling notifications."
        static let note = ""
    }
    
    struct Settings {
        static let unitOfMeasure = "Used to set the unit for all measurements displayed in the app."
        static let remindMeLater = "Used to reschedule new workout notifications when you select \"Remind me later\" after long pressing on the workout notifications."
    }
}
