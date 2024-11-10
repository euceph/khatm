import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Year Progress Widget")
                .font(.title)
                .padding()
            
            Text("Add the widget to your lock screen to see the percentage of the year remaining.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Configure decimal places in the widget settings.")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
