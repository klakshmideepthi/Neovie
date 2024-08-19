import SwiftUI
struct MedicationReminderWidget: View {
    let medicationName: String
    let dosage: String
    let onSkip: () -> Void
    let onTaken: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Medication Reminder")
                .font(.headline)
                .foregroundColor(.customTextColor)
            
            Text("It's time to take your \(medicationName) (\(dosage))")
                .foregroundColor(.customTextColor)
            
            HStack {
                Button("Skip", action: onSkip)
                    .foregroundColor(.red)
                Spacer()
                Button("Taken", action: onTaken)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
