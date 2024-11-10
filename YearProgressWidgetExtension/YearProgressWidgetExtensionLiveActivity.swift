//
//  YearProgressWidgetExtensionLiveActivity.swift
//  YearProgressWidgetExtension
//
//  Created by issa euceph on 11/10/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct YearProgressWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct YearProgressWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: YearProgressWidgetExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension YearProgressWidgetExtensionAttributes {
    fileprivate static var preview: YearProgressWidgetExtensionAttributes {
        YearProgressWidgetExtensionAttributes(name: "World")
    }
}

extension YearProgressWidgetExtensionAttributes.ContentState {
    fileprivate static var smiley: YearProgressWidgetExtensionAttributes.ContentState {
        YearProgressWidgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: YearProgressWidgetExtensionAttributes.ContentState {
         YearProgressWidgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: YearProgressWidgetExtensionAttributes.preview) {
   YearProgressWidgetExtensionLiveActivity()
} contentStates: {
    YearProgressWidgetExtensionAttributes.ContentState.smiley
    YearProgressWidgetExtensionAttributes.ContentState.starEyes
}
