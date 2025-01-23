//
//  FAQView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 23.01.2025.
//

import SwiftUI

struct FAQItem {
    let question: String
    let answer: String
    var isExpanded: Bool = false
}

struct FAQView: View {
        
    @State private var faqItems: [FAQItem] = [
        FAQItem(
            question: "How can I restore my data after reinstalling the App?",
            answer: "Your shoe data is stored in iCloud and it will automatically restore when opening the App after reinstall if you have signed in with the same Apple ID in system settings."
        ),
        FAQItem(
            question: "How is the lifespan of shoes calculated?",
            answer: "The lifespan of a specific shoe is calculated based on the total running distance of its workouts imported from Apple Health."
        ),
        FAQItem(
            question: "Can I track workouts other than running?",
            answer: "Currently, the app focuses only on running workouts imported from Apple Health."
        ),
        FAQItem(
            question: "What kind of notifications will I receive from Shoe Health?",
            answer: "You will get notified about new workouts being available for shoe assignment, as well as about any changes in your shoes wear condition after assigning workouts to them."
        ),
        FAQItem(
            question: "What is the purpose of a default shoe and how can I make use of it?",
            answer: "The default shoe is designed to quickly assign workouts to it by long pressing on new workouts notifications, without manually navigating trough the whole App. Each time you log a new workout in Apple Health by using any other application that has access to write in Apple Health, the App will notify you about it and allow you to quickly assign it to the default shoe or any other shoe you like."
        ),
        FAQItem(
            question: "Is it mandatory to have a default shoe?",
            answer: "Having a default shoe is not mandatory, but the App will notify you about not having a 'Daily' default shoe set up and will try to help you to set one. When not having a 'Daily' default shoe set up, using the 'Use Default Shoe - Daily' option by long pressing on a new workout notification will have no effect, so it is helpful to always have a 'Daily' default shoe."
        ),
        FAQItem(
            question: "Is there any limit of shoes I can add?",
            answer: "Yes, there is a limit of 5 shoes that you can add to the App. If you want to be able to add more shoes you can to purchase the Premium version of the App."
        ),
        FAQItem(
            question: "What features are included in the Premium version of the App?",
            answer: "Currently there are 2 features included in the Premium version of the App: an unlimited number of shoes that you can add and the ability to also set default shoes for different running types (long, tempo, race and trail run) and use them directly from the new workouts notifications."
        )
    ]
    
    var body: some View {
        List {
            ForEach($faqItems, id: \.question) { $faqItem in
                DisclosureGroup(
                    isExpanded: $faqItem.isExpanded,
                    content: {
                        Text(faqItem.answer)
                            .font(.callout)
                    },
                    label: {
                        Text(faqItem.question)
                            .font(.headline)
                            .padding(.vertical, 4)
                    }
                )
                .animation(.easeInOut, value: faqItem.isExpanded)
                .accentColor(.primary)
                .onTapGesture {
                    withAnimation {
                        faqItem.isExpanded.toggle()
                    }
                }
            }
        }
        .navigationBarTitle("FAQ")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FAQView()
    }
}
