//
//  YearProgressWidgetBundle.swift
//  YearProgressWidget
//
//  Created by issa euceph on 11/10/24.
//

import WidgetKit
import SwiftUI

@main
struct YearProgressWidgetBundle: WidgetBundle {
    var body: some Widget {
        YearProgressWidget()
        ProgressPillWidget()
        DaysLeftWidget()
    }
}
