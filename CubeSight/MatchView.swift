//
//  MatchView.swift
//  CubeSight
//
//  Created by Noe Thalheim on 08.09.2024.
//

import Foundation
import SwiftData
import SwiftUI


struct MatchResultView: View {
    @Bindable var match: Match
    @State private var selectedWinner: Player?
    @State private var selectedResult: (Int, Int, Int)?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section("Select Winner") {
                Button(match.player1.name) {
                    selectedWinner = match.player1
                    selectedResult = nil
                }
                .foregroundColor(selectedWinner == match.player1 ? .green : .primary)
                .accessibilityLabel("Select player 1 as winner")
                
                if let player2 = match.player2 {
                    Button(player2.name) {
                        selectedWinner = player2
                        selectedResult = nil
                    }
                    .foregroundColor(selectedWinner == player2 ? .green : .primary)
                    .accessibilityLabel("Select player 2 as winner")
                    
                    Button("Draw") {
                        selectedWinner = nil
                        selectedResult = nil
                    }
                    .foregroundColor(selectedWinner == nil ? .green : .primary)
                    .accessibilityLabel("Select draw")
                } else {
                    Text("Bye")
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Bye match")
                }
            }
            
            Section("Select Result") {
                if selectedWinner != nil {
                    Button("1-0") { selectedResult = (1, 0, 0) }
                        .foregroundColor( (selectedResult ?? (0,0,0)) == (1,0,0) ? .green : .primary )
                        .accessibilityLabel("Select result 1-0")
                    Button("2-0") { selectedResult = (2, 0, 0) }
                        .foregroundColor( (selectedResult ?? (0,0,0)) == (2,0,0) ? .green : .primary )
                        .accessibilityLabel("Select result 2-0")
                    Button("2-1") { selectedResult = (2, 1, 0) }
                        .foregroundColor( (selectedResult ?? (0,0,0)) == (2,1,0) ? .green : .primary )
                        .accessibilityLabel("Select result 2-1")
                    
                } else if match.player2 != nil {
                    Button("0-0") { selectedResult = (0, 0, 0) }
                        .foregroundColor( (selectedResult ?? (1,0,0)) == (0,0,0) ? .green : .primary )
                        .accessibilityLabel("Select result 0-0")
                    Button("1-1") { selectedResult = (1, 1, 0) }
                        .foregroundColor( (selectedResult ?? (0,0,0)) == (1,1,0) ? .green : .primary )
                        .accessibilityLabel("Select result 1-1")
                }
                //
                else {
                    Text("2-0 (Bye)")
                        .onAppear { selectedResult = (2, 0, 0) }
                        .foregroundColor( (selectedResult ?? (0,0,0)) == (2,0,0) ? .green : .primary )
                        .accessibilityLabel("Bye result 2-0")
                }
            }
            .disabled(match.player2 == nil)
            
            if let result = selectedResult {
                Button("Record Result") {
                    if match.player2 == nil {
                        // Handle bye
                        match.recordResult(winner: match.player1, player1Wins: 2, player2Wins: 0, draws: 0)
                    } else {
                        match.recordResult(winner: selectedWinner, player1Wins: result.0, player2Wins: result.1, draws: result.2)
                    }
                    dismiss()
                }
                .accessibilityLabel("Record match result")
                .accessibilityHint("Records the selected result and returns to the round view")
            }
        }
        .navigationTitle("Record Match Result")
    }
}

struct MatchRowView: View {
    let match: Match
    let matchIndex: Int
    
    var body: some View {
        HStack {
            Text(match.player1.name)
            Spacer()
            if match.isComplete {
                Text(resultText)
                    .foregroundColor(resultColor)
            } else {
                Text("Not played")
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(match.player2?.name ?? "BYE")
        }
        .accessibilityLabel("Match row")
        .accessibilityValue(accessibilityResultText)
    }
    
    private var resultText: String {
        if match.player2 == nil {
            return "BYE"
        } else {
            return "\(match.player1Wins)-\(match.player2Wins)"
        }
    }
    
    private var accessibilityResultText: String {
        if !match.isComplete {
            return "Not played"
        } else if match.player2 == nil {
            return "BYE"
        }
        else {
            let winnerDescription = match.winner == match.player1 ? "Player 1 wins" :
            match.winner == match.player2 ? "Player 2 wins" : "Draw"
            return "\(resultText), \(winnerDescription)"
        }
    }
    
    private var resultColor: Color {
        if match.winner == match.player1 {
            return .green
        } else if match.winner == match.player2 {
            return .red
        } else {
            return .blue
        }
    }
}
