//
//  ContentView.swift
//  WordScramble
//
//  Created by AJit Kawale on 02/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var addedWord = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score: Int = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        
        NavigationStack{
            
            
            List{
                Section
                {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                    
                }
                Section {
                    ForEach(addedWord, id: \.self)
                    {
                        
                        word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                            
                            
                            
                        }
                    }
                    
                }
            }
            
            
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            
            .alert(errorTitle,isPresented: $showingError) { } message :{
                
                Text(errorMessage)
            }
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Score: \(score)")
                        .font(.body)
                        .frame(minWidth: 80, alignment: .leading)
                }
                
                // Trailing item: New Game button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Game", action: startGame)
                    
                }
            }
        }
    
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0  else {return}
        
        guard isValid(word: answer) else {
            wordError(title: "Word is same as root", message: "\(answer) is root word.")
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "\(answer) has already been used. Try another one.")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You cant spell that word from \(rootWord) !")
            return
        }
        guard isReal(word: answer)else {
            wordError(title: "Word not Recognized", message: "You can't just make then up, you know !")
            return
        }
        
        
        
        withAnimation {
            addedWord.insert(answer, at: 0)
            score += 1
        }
        newWord = ""
    }
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                
                addedWord.removeAll()   // 🧹 Clear old words
                newWord = ""
                score = 0// 🔄 Clear text field
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
        
        }
    func isOriginal(word: String) -> Bool {
        !addedWord.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
        
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    func isValid(word: String) -> Bool {
        !word.contains(rootWord)
        
    }
   
   
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    
}
#Preview {
    ContentView()
}



//need to fix stacks rootword going in toolbar
