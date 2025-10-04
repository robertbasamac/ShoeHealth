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
            answer: "Your shoe data is stored in iCloud and will automatically restore when you open the App after reinstalling, as long as you are signed in with the same Apple ID in the system settings."
        ),
        FAQItem(
            question: "How is the lifespan of shoes calculated?",
            answer: "The lifespan of a shoe is calculated based on the total running distance from workouts imported from Apple Health. In the future, it is planned to use other several factors to calculate the lifespan of a shoe."
        ),
        FAQItem(
            question: "Can I track workouts other than running?",
            answer: "Currently, the App only supports tracking running workouts imported from Apple Health."
        ),
        FAQItem(
            question: "What kind of notifications will I receive from Shoe Health?",
            answer: "You will receive notifications about new workouts available for shoe assignment and updates on your shoes's wear condition after assigning workouts to them."
        ),
        FAQItem(
            question: "What is the purpose of a default shoe and how can I make use of it?",
            answer: "A default shoe allows you to quickly assign workouts by long pressing on new workout notifications, without navigating through the App. When a new workout is logged in Apple Health using another app, Shoe Health will notify you and let you assign it to the default shoe or any other shoe of your choice."
        ),
        FAQItem(
            question: "Is it mandatory to have a default shoe?",
            answer: "A default shoe is not mandatory, but the App will remind you if a 'Daily' default shoe is not set. Other categories are not mandatory, but it is recommended to have at least a 'Daily' default shoe set for convenience."
        ),
        FAQItem(
            question: "Is there any limit to the number of shoes I can add?",
            answer: "Yes, the Free version of the App allows you to add up to \(StoreManager.shoesLimit) shoes. To add more, you can upgrade to the Premium version."
        ),
        FAQItem(
            question: "What features are included in the Premium version of the App?",
            answer: "The Premium version includes two main features: unlimited shoe entries and access to four more running types (long run, tempo run, race, and trail run). You can also use these default shoes directly from new workout notifications and display them in Widgets."
        ),
        FAQItem(
            question: "What happens to my shoes if I upgrade to the Premium version, add more than \(StoreManager.shoesLimit) shoes, and then go back to the Free version?",
            answer: "If you switch back to the Free version, all shoes you added while using Premium will remain in the App, but they will be restricted. You won’t be able to edit them, add workouts, or set them as default shoes. You will only have access to up to \(StoreManager.shoesLimit) shoes. These \(StoreManager.shoesLimit) shoes are selected by specific rules in the following order: the default 'Daily' shoe is included first (if set), followed by the most recently used shoes and then the most recently added shoes until the limit of \(StoreManager.shoesLimit) is reached."
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
