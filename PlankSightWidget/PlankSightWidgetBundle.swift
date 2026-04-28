//
//  PlankSightWidgetBundle.swift
//  PlankSightWidget
//
//  Created by Muhammad Rizki on 22/04/26.
//

import WidgetKit
import SwiftUI

@main
struct PlankSightWidgetBundle: WidgetBundle {
    var body: some Widget {
        PlankSightWidget()
        PlankSightWidgetControl()
        PlankSightWidgetLiveActivity()
    }
}
