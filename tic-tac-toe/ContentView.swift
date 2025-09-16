import SwiftUI
import AVFoundation

struct Player {
    var name: String
    var avatar: String
    var score: Int
    var color: Color
}

struct ContentView: View {
    @State private var moves: [String] = Array(repeating: "", count: 9)
    @State private var currentPlayerIndex = 0
    @State private var winner: String? = nil
    @State private var showSettings = false
    @State private var showAvatars = false
    @State private var soundEnabled = true
    @State private var animationEnabled = true
    
    @State private var players = [
        Player(name: "Player 1", avatar: "person.circle.fill", score: 0, color: .red),
        Player(name: "Player 2", avatar: "person.circle", score: 0, color: .green)
    ]
    
    @State private var audioPlayer: AVAudioPlayer?
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    let winPatterns: [[Int]] = [
        [0,1,2], [3,4,5], [6,7,8], // rows
        [0,3,6], [1,4,7], [2,5,8], // columns
        [0,4,8], [2,4,6]           // diagonals
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                         startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // Title with settings button
                HStack {
                    Text("TicTacToe")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.purple)
                        .shadow(radius: 2)
                    
                    Spacer()
                    
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Circle().fill(Color.white.opacity(0.8)))
                    }
                }
                .padding(.horizontal)
                
                VStack (spacing: 6){
                    // Scoreboard with avatars
                    HStack(spacing: 30) {
                        ForEach(0..<2) { index in
                            VStack {
                                Button(action: {
                                    showAvatars = true
                                    currentPlayerIndex = index
                                }) {
                                    Image(systemName: players[index].avatar)
                                        .font(.system(size: 50))
                                        .foregroundColor(players[index].color)
                                        .padding(10)
                                        .background(
                                            Circle()
                                                .fill(index == currentPlayerIndex ? Color.white.opacity(0.9) : Color.white.opacity(0.6))
                                                .shadow(radius: 3)
                                        )
                                }
                                
                                Text(players[index].name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("\(players[index].score)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(players[index].color)
                            }
                        }
                    }
                    
                    // Turn indicator
                    Text("\(players[currentPlayerIndex].name)'s Turn")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Capsule().fill(Color.white.opacity(0.7)))
                }
                
                // Game Grid
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<9) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 3)
                                .frame(height: 100)
                            
                            if moves[index] == "X" {
                                Image(systemName: "xmark")
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(players[0].color)
                                    .scaleEffect(animationEnabled ? 1.2 : 1.0)
                                    .animation(animationEnabled ? .spring(response: 0.3, dampingFraction: 0.5) : .none, value: moves[index])
                            } else if moves[index] == "O" {
                                Image(systemName: "circle")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(players[1].color)
                                    .scaleEffect(animationEnabled ? 1.2 : 1.0)
                                    .animation(animationEnabled ? .spring(response: 0.3, dampingFraction: 0.5) : .none, value: moves[index])
                            }
                        }
                        .onTapGesture {
                            makeMove(at: index)
                        }
                        .disabled(moves[index] != "" || winner != nil)
                    }
                }
                .padding(.horizontal)
                
                // Winner text
                if let winner = winner {
                    VStack (spacing: 2){
                        Text(winner == "Draw" ? "It's a Draw!" : "\(winner) Wins!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                            .transition(.scale)
                        
                        if winner != "Draw" {
                            Text("🎉 Congratulations! 🎉")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Buttons
                HStack(spacing: 15) {
                    Button(action: resetGame) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Restart")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }
                    
                    Button(action: newGame) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("New Game")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
            .padding(.vertical)
            
            // Settings Sheet
            if showSettings {
                SettingsView(
                    isShowing: $showSettings,
                    soundEnabled: $soundEnabled,
                    animationEnabled: $animationEnabled,
                    players: $players
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
            
            // Avatar Selection Sheet
            if showAvatars {
                AvatarSelectionView(
                    isShowing: $showAvatars,
                    player: $players[currentPlayerIndex],
                    avatars: ["person.circle.fill", "person.fill", "face.smiling", "star.circle.fill", "heart.circle.fill", "flag.circle.fill"]
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .onAppear {
            prepareSounds()
        }
    }
    
    private func makeMove(at index: Int) {
        guard moves[index] == "" && winner == nil else { return }
        
        let symbol = currentPlayerIndex == 0 ? "X" : "O"
        moves[index] = symbol
        
        // Play sound
        if soundEnabled {
            playSound(named: "tap")
        }
        
        checkWinner()
        
        if winner == nil {
            // Switch player
            currentPlayerIndex = currentPlayerIndex == 0 ? 1 : 0
            
            // Play switch sound
            if soundEnabled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    playSound(named: "switch")
                }
            }
        }
    }
    
    private func checkWinner() {
        // Check for win
        for pattern in winPatterns {
            let line = pattern.map { moves[$0] }
            if line.allSatisfy({ $0 == "X" }) {
                winner = players[0].name
                players[0].score += 1
                if soundEnabled { playSound(named: "win") }
                return
            }
            if line.allSatisfy({ $0 == "O" }) {
                winner = players[1].name
                players[1].score += 1
                if soundEnabled { playSound(named: "win") }
                return
            }
        }
        
        // Check for draw
        if !moves.contains("") {
            winner = "Draw"
            if soundEnabled { playSound(named: "draw") }
        }
    }
    
    private func resetGame() {
        moves = Array(repeating: "", count: 9)
        currentPlayerIndex = 0
        winner = nil
        
        if soundEnabled {
            playSound(named: "reset")
        }
    }
    
    private func newGame() {
        resetGame()
        players[0].score = 0
        players[1].score = 0
        
        if soundEnabled {
            playSound(named: "newgame")
        }
    }
    
    private func prepareSounds() {
        // Preload sounds if needed
    }
    
    private func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("Sound file not found: \(name)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}

// Settings View
struct SettingsView: View {
    @Binding var isShowing: Bool
    @Binding var soundEnabled: Bool
    @Binding var animationEnabled: Bool
    @Binding var players: [Player]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                
                Spacer()
                
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 10)
            
            Toggle("Enable Sound Effects", isOn: $soundEnabled)
                .font(.headline)
            
            Toggle("Enable Animations", isOn: $animationEnabled)
                .font(.headline)
            
            Divider()
            
            Text("Player Names")
                .font(.headline)
                .foregroundColor(.blue)
            
            ForEach(0..<players.count, id: \.self) { index in
                TextField("Player \(index + 1) Name", text: $players[index].name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            Divider()
            HStack(spacing: 4){
                Text("Powered By")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                Text("Walizadah")
                    .font(.system(size: 14))
            }
            Spacer()
            
            Button("Save Settings") {
                isShowing = false
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
    }
}

// Avatar Selection View
struct AvatarSelectionView: View {
    @Binding var isShowing: Bool
    @Binding var player: Player
    let avatars: [String]
    
    var body: some View {
        VStack {
            HStack {
                Text("Choose Avatar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                
                Spacer()
                
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Divider()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(avatars, id: \.self) { avatar in
                    Button(action: {
                        player.avatar = avatar
                        isShowing = false
                    }) {
                        Image(systemName: avatar)
                            .font(.system(size: 50))
                            .foregroundColor(player.color)
                            .padding()
                            .background(Circle().fill(Color.white.opacity(0.8)))
                            .overlay(
                                Circle()
                                    .stroke(player.avatar == avatar ? Color.blue : Color.clear, lineWidth: 3)
                            )
                    }
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
    }
}

#Preview {
    ContentView()
}
