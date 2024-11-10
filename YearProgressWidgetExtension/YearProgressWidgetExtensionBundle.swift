//
//  YearProgressWidgetExtensionBundle.swift
//  YearProgressWidgetExtension
//
//  Created by issa euceph on 11/10/24.
//

import WidgetKit
import SwiftUI

@main
struct YearProgressWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        YearProgressWidgetExtension()
        YearProgressWidgetExtensionControl()
        YearProgressWidgetExtensionLiveActivity()
    }
}
