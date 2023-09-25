//
//  ContentView.swift
//  WordScramble
//
//  Created by User on 30/08/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var scoreCount = 0
    
    var body: some View {
        
        NavigationView {
            List {
                
                Section("Guess!") {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section("Score") {
                    Text("\(scoreCount) points")
                    //Text(score)
                }
                
                Section("Used words") {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
                Section("Information about the app") {
                    Text("Built as part of HackingWithSwift course \n\n Patrick Lubbers was here")
                }
            }
            .navigationTitle(rootWord) //on the top(?)
            .navigationBarTitleDisplayMode(.inline)
            .multilineTextAlignment(.center)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {startGame()
                    }, label: {
                        Text("Press me to change words!")
                    })
                }
            }
            .onSubmit(addNewWord) //when using return key
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func startGame() {
        //1. Find start.txt in our bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //2. Load it into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                //3. Split that string into an array of strings, with each element being one word
                let allWords = startWords.components(separatedBy: "\n")
                
                //4. Pick one random word from there to be assigned to rootWord, or use a sensible default if the array is empty.
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // If we are here everything has worked, so we can exit. we will wipe the game if people want to change the word
                scoreCount = 0
                usedWords.removeAll()
                            return
            }
        }
        
        // If we are *here* then there was a problem - trigger a crash and report the error
        fatalError("Could not lead start.txt from bundle.")
    }
    
    func addNewWord() {
        //lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        //exit if the remaining string is empty
        guard answer.count > 0 else { return }
        
        //guard answer.count >= 3 else { return }
        
        guard isSame(word: answer) else {
            wordError(title: "Word is the same as '\(rootWord)'!", message: "That is the same word as the given word!")
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word is too short", message: "come up with more than words like cat or dog!")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make up words")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            newWord = ""
        }
        
        scoreCalculate() //newly added! JFLIJHSABFOUAHFD
    }
    
    func isLongEnough(word: String) -> Bool {
        if newWord.count <= 3 {
            return false
        }
        return true
    }
    
    func isSame(word: String) -> Bool {
        if newWord == rootWord {
            return false
        }
            return true
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
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
    
    func wordError (title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func scoreCalculate() {
        if let newestWord = usedWords.first {
            let characterCount = newestWord.count
            scoreCount += characterCount
        }
    }
    
    func loadFile() {
        if let fileURL = Bundle.main.url(forResource: "some-file", withExtension: "txt") {
            // Here
            if let fileContents = try? String(contentsOf: fileURL) {
                fileContents
            }
        }
            
    }
    
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
