import SwiftUI

struct MedicationReminderWidget: View {
    let medicationName: String
    let dosage: String
    let onSkip: () -> Void
    let onTaken: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "pill.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.accentColor)
                
                Text("Medication Reminder")
                    .font(.headline)
                    .foregroundColor(AppColors.textColor)
            }
            
            Text("It's time to take your \(medicationName) (\(dosage))")
                .font(.subheadline)
                .foregroundColor(AppColors.textColor.opacity(0.8))
            
            HStack(spacing: 20) {
                Button(action: onSkip) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Skip")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
                
                Button(action: onTaken) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Taken")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .padding(20)
        .background(AppColors.backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
