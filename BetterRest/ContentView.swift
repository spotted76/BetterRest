//
//  ContentView.swift
//  BetterRest
//
//  Created by Peter Fischer on 3/15/22.
//

import CoreML
import SwiftUI

struct HeaderFormat : ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundColor(.primary)
    }
}

extension Text {
    func formatHeader() -> some View {
        modifier(HeaderFormat())
    }
}

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    
    static var defaultWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var computed : String {
        var computedTime = ""
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
                        
            let prediction = try model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount + 1))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            computedTime = sleepTime.formatted(date: .omitted, time: .shortened)
            
        }
        catch {
            computedTime = "Sorry, there was a problem calculating your bedtime"
        }
        
        return computedTime
    }
        
    
    var body: some View {
        NavigationView {
            Form {
                
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                } header: {
                    Text("When do you want to wake up?")
                        .bold()
                        .formatHeader()
                }
                
                Section {
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                        .bold()
                        .formatHeader()
                }
                
                Section {
                        Picker(coffeeAmount == 0 ? "1 cup" : "\(coffeeAmount+1) cups", selection: $coffeeAmount){
                            ForEach(1..<21) { cup in
                                Text(cup == 1 ? "1 cup" : "\(cup) cups")
                            }
                        }
                    
                } header: {
                    Text("Daily coffee intake")
                        .bold()
                        .formatHeader()
                }
                
                Section {
                    Text(computed)
                } header: {
                    Text("Computed Bed Time")
                        .bold()
                        .formatHeader()
                }
            }
            .navigationTitle("Better Rest")
        
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
