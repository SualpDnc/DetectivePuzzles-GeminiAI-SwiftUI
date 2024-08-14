//
//  ContentView.swift
//  DetectivePuzzles
//
//  Created by Sualp DANACI on 14.08.2024.
//

import SwiftUI
import GoogleGenerativeAI

struct ContentView: View {
    
    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    
    @State var userPrompt = ""
    @State var response: LocalizedStringKey = ""
    @State var isLoading = false
    @State private var scenario: String = ""
    @State private var suspects: [String] = ["A", "B", "C", "D", "E"]
    @State private var selectedSuspect: String?
    @State private var isCorrectGuess: Bool?
    @State private var showOptions = true
    @State private var showNextRound = false
    
    var body: some View {
        VStack {
            if scenario.isEmpty {
                VStack{
                    Image(systemName: "magnifyingglass.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    Text("Detective Puzzles")
                        .bold()
                        .font(.largeTitle)
                        
                }.padding(.top,40)
                
                
                
                Button("Get a detective scenario!") {
                    userPrompt = "Create a crime scenario with 5 suspects. And give me answers consisting of A, B, C, D, E. After you ask me, I will give you one of these options as an answer. After you give it tell me if I chose the correct answer"
                    generateResponse()
                }.padding(.top,150).font(.title)
                
                Spacer()
                
                Text("Info: The AI ​​will give you a crime scenario. You will try to know the real culprit based on the information given to you. Good luck!") .multilineTextAlignment(.center)
                
               
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .indigo))
                        .scaleEffect(2)
                }
                
            } else {
                ZStack {
                    ScrollView {
                        Text(response)
                            .font(.title2)
                    }
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .indigo))
                            .scaleEffect(4)
                    }
                }
                
                if showOptions {
                    
                    List(suspects, id: \.self) { suspect in
                        Button(action: {
                            selectedSuspect = suspect
                            userPrompt = " You gave me this scenario on our previous chat: \(response) , According to this, You have to choose whichever is the most likely correct answer. Now, I will try to guess the correct answer. The suspect is \(suspect). Is this the correct guess? You can only give me one of two answers: Congratulations, you got it right, or Sorry, wrong answer, the correct answer was."
                            showOptions = false
                            generateResponse()
                        }) {
                            Text(suspect)
                        }
                    }
                }
                
                Button("Exit to main menu") {
                    scenario = ""
                    selectedSuspect = nil
                    isCorrectGuess = nil
                    showOptions = true
                    userPrompt = "Create a short crime scenario with 5 suspects. And give me answers consisting of A, B, C, D, E. After you ask me, I will give you one of these options as an answer. After you give it tell me if I chose the correct answer"
                }.font(.title3).bold()
            }
        }
        .padding()
    }
        
  
    func generateResponse() {
        isLoading = true
        response = ""
        
        Task {
            do {
                let result = try await model.generateContent(userPrompt)
                scenario = result.text ?? "No scenario found"
                isLoading = false
                response = LocalizedStringKey(result.text ?? "No response found")
                userPrompt = ""
            } catch {
                isLoading = false
                response = "Something went wrong! \n\(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    ContentView()
}
