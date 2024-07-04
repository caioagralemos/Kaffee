//
//  ContentView.swift
//  Kaffee
//
//  Created by Caio on 30/06/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 8
        components.minute = 30
        return Calendar.current.date(from: components) ?? .now
    }
    
    @State private var sleepAmount = 8.0
    @State private var wakeTime = defaultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertShowing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Coffee").resizable().scaledToFill().ignoresSafeArea().blur(radius: 4)
                Color(.systemBackground).ignoresSafeArea().opacity(0.3)
                VStack {
                    Spacer()
                    Spacer()
                    Text("Kaffee").font(.largeTitle.bold()).foregroundStyle(.white)
                    VStack (spacing: 30) {
                        VStack (spacing: 10) {
                            Text("Quando você quer acordar?")
                            DatePicker("Please enter a time", selection: $wakeTime, displayedComponents: .hourAndMinute).labelsHidden()
                        }.onChange(of: wakeTime) {
                            calculateSleep()
                        }
                         
                        VStack (spacing: 10) {
                            Text("Quantas horas de sono?")
                            Stepper("\(sleepAmount.formatted()) horas", value: $sleepAmount, in: 4...12, step: 0.25)
                        }.onChange(of: sleepAmount) {
                            calculateSleep()
                        }
                        
                        
                        VStack (spacing: 10) {
                            Text("Quanto café você toma por dia?")
                            Stepper("\(coffeeAmount) copo(s)", value: $coffeeAmount, in: 1...20)
//                            Picker("Oi", selection: $coffeeAmount) {
//                                Text("1").tag(1)
//                                Text("2").tag(3)
//                            }
                        }.onChange(of: coffeeAmount) {
                            calculateSleep()
                        }
                        
//                        Button {
//                            calculateSleep()
//                        } label: {
//                            Text("Calculate").frame(width: 100, height: 40).background(.quaternary).clipShape(.rect(cornerRadius: 10)).foregroundStyle(.foreground)
//                        }
                        // Text("Now it's \(Date.now, format: .dateTime.hour().minute())")
                       // Text("Now it's \(Date.now.formatted(date: .abbreviated, time: .shortened))")
                        
                        
                    }
                    .padding(40).background(.ultraThickMaterial).clipShape(.rect(cornerRadius: 30)).padding(.horizontal, 40)
                    
                    Text("\(alertMessage)").font(.title2.bold()).foregroundStyle(.white).multilineTextAlignment(.center).padding(.horizontal, 40).padding(.vertical, 15)
                    Spacer()
                    Spacer()
                    Spacer()
                }
            }.alert(alertTitle, isPresented: $alertShowing) {
                Button("Thanks") {}
            } message: {
                Text(alertMessage)
            }.onAppear() {
                calculateSleep()
            }
        }
    }
    
//    func exampleDates() {
////        var components = DateComponents()
////        components.hour = 8
////        components.minute = 0
////        let date = Calendar.current.date(from: components) ?? .now
//        
//        let components = Calendar.current.dateComponents([.hour, .minute], from: .now)
//        // let hour = components.hour ?? 0
//        // let minute = components.minute ?? 0
//    }
    
    func calculateSleep() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeTime)
            let hour = (components.hour ?? 0) * 3600
            let minute = (components.minute ?? 0 ) * 60
            
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeTime - prediction.actualSleep
            
            alertTitle = "We found your ideal bedtime!"
            alertMessage = "Nosso gênio do Kaffee acredita que você deve ir dormir às \(sleepTime.formatted(date: .omitted, time: .shortened))."
            // alertShowing = true
        } catch {
            alertTitle = "Error"
            alertMessage = "Something went wrong! Check your data and try again"
        }
    }
}

#Preview {
    ContentView()
}
