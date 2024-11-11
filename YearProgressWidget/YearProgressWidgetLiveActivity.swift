//
//  YearProgressWidgetLiveActivity.swift
//  YearProgressWidget
//
//  Created by issa euceph on 11/10/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct YearProgressWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct YearProgressWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: YearProgressWidgetAttributes.self) { context in
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

extension YearProgressWidgetAttributes {
    fileprivate static var preview: YearProgressWidgetAttributes {
        YearProgressWidgetAttributes(name: "World")
    }
}

extension YearProgressWidgetAttributes.ContentState {
    fileprivate static var smiley: YearProgressWidgetAttributes.ContentState {
        YearProgressWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: YearProgressWidgetAttributes.ContentState {
         YearProgressWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: YearProgressWidgetAttributes.preview) {
   YearProgressWidgetLiveActivity()
} contentStates: {
    YearProgressWidgetAttributes.ContentState.smiley
    YearProgressWidgetAttributes.ContentState.starEyes
}
