import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("khatm")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("add the widget to your lock screen to see the percentage of your year remaining.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("configure decimal places in the widget settings")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}