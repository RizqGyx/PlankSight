//
//  PlankSightWidgetLiveActivity.swift
//  PlankSightWidget
//
//  Created by Muhammad Rizki on 22/04/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PlankSightWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PlankSightWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PlankSightWidgetAttributes.self) { context in
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

extension PlankSightWidgetAttributes {
    fileprivate static var preview: PlankSightWidgetAttributes {
        PlankSightWidgetAttributes(name: "World")
    }
}

extension PlankSightWidgetAttributes.ContentState {
    fileprivate static var smiley: PlankSightWidgetAttributes.ContentState {
        PlankSightWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PlankSightWidgetAttributes.ContentState {
         PlankSightWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PlankSightWidgetAttributes.preview) {
   PlankSightWidgetLiveActivity()
} contentStates: {
    PlankSightWidgetAttributes.ContentState.smiley
    PlankSightWidgetAttributes.ContentState.starEyes
}
