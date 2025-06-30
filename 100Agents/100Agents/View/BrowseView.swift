
import SwiftUI
import UniformTypeIdentifiers

struct BrowseView: View {
    @StateObject private var viewModel = BrowseViewModel()
    @ObservedObject var authService: AuthService
    let allCategories = MainCategory.allCases
    
    let initialCategoryCount = 5
    @State private var showAllCategories = false
    @State private var urlText = ""
    @State private var showingFilePicker = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading) {
                        // User greeting header
                        userGreetingHeader
                        
                        Group {
                            if !viewModel.recentCategories.isEmpty {
                                RecentlySelectedView(viewModel: viewModel, recentCategories: viewModel.recentCategories) { category in
                                    viewModel.toggleCategory(category)
                                }
                            } else {
                                Color.clear
                            }
                        }
                        
                        trendingTopicsLabel
                        //                            .font(.system(size: 20, weight: .semibold, design: .default))
                            .font(.headline)
                            .padding(.horizontal)
                        WrapLayout(verticalSpacing: 15) {
                            let categoriesToShow = showAllCategories ? allCategories : Array(allCategories.prefix(initialCategoryCount))
                            
                            ForEach(categoriesToShow, id: \.self) { category in
                                CategoryButton(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: viewModel.selectedCategories.contains(category)
                                ) {
                                    withAnimation {
                                        viewModel.toggleCategory(category)
                                    }
                                }
                                .padding(4)
                            }
                            
                            moreLessButton
                        }
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 80) // Add padding to the bottom to avoid overlap with the button
                    .padding(.horizontal, 5)
                }

                if viewModel.selectedCategories.count > 0 {
                    submitButton
                } else {
                    alternativeOptionsSection
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading) {
                        Text("Browse")
                            .font(.system(size: 35, weight: .semibold, design: .default))
                        Text("Choose a topic to learn -- or multiple!")
                    }
                }
            }
        }
    }
    
    var trendingTopicsLabel: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            Text("Trending Topics")
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
    
    var submitButton: some View {
        NavigationLink(destination: NarrowSelectionView(category: viewModel.selectedCategories)) {
            Text("Continue (\(viewModel.selectedCategories.count))")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(15)
                .shadow(radius: 10)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(), value: viewModel.selectedCategories.isEmpty)
    }
    
    var moreLessButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                showAllCategories.toggle()
            }
        }) {
            HStack {
                Image(systemName: showAllCategories ? "arrow.up.right.and.arrow.down.left" : "ellipsis")
                Text(showAllCategories ? "Less" : "More")
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(4)
    }
    
    var alternativeOptionsSection: some View {
        VStack(spacing: 15) {
            orDivider
            
            pdfUploadButton
            
            orDivider
            
            urlEntrySection
        }
        .padding(.horizontal)
        .padding(.bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(), value: viewModel.selectedCategories.isEmpty)
    }
    
    var pdfUploadButton: some View {
        Button(action: {
            showingFilePicker = true
        }) {
            HStack {
                Image(systemName: "doc.fill")
                Text("Upload PDF")
                    .fontWeight(.bold)
            }
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
            // 3D embossed effect
            .shadow(color: Color.white.opacity(0.8), radius: 1, x: 0, y: -1) // Top highlight
            .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 2) // Bottom shadow
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4) // Deeper bottom shadow
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handlePDFSelection(result)
        }
    }
    
    var orDivider: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black.opacity(0.3))
            
            Text("OR")
                .foregroundColor(.gray)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black.opacity(0.3))
        }
    }
    
    var urlEntrySection: some View {
        HStack(spacing: 12) {
            // URL Input Field with Notion styling
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                TextField("Paste article URL here...", text: $urlText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(urlText.isEmpty ? Color.gray.opacity(0.2) : Color.blue.opacity(0.3), lineWidth: 1)
            )
            // 3D embossed effect for text field
            .shadow(color: Color.white.opacity(0.8), radius: 1, x: 0, y: -1) // Top highlight
            .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 2) // Bottom shadow
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 3) // Deeper bottom shadow
            .animation(.easeInOut(duration: 0.2), value: urlText.isEmpty)
            
            urlEntrySubmitButton
        }
    }
    
    var urlEntrySubmitButton: some View {
        Button(action: {
            handleURLSubmission()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
            }
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
//                    .background(urlText.isEmpty ? Color.gray.opacity(0.1) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(urlText.isEmpty ? Color.gray.opacity(0.2) : Color.black.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: urlText.isEmpty ? Color.clear : Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            .shadow(color: urlText.isEmpty ? Color.clear : Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
            .scaleEffect(urlText.isEmpty ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: urlText.isEmpty)
        }
        .disabled(urlText.isEmpty)

    }
    
    private func handlePDFSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                // TODO: Navigate to reel generation with PDF
                print("PDF selected: \(url)")
            }
        case .failure(let error):
            print("Error selecting PDF: \(error)")
        }
    }
    
    private func handleURLSubmission() {
        guard !urlText.isEmpty else { return }
        // TODO: Navigate to reel generation with URL
        print("URL submitted: \(urlText)")
    }
    
    var userGreetingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(authService.userName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("What would you like to learn today?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Simple profile circle with initials
//            Text(authService.userName.prefix(1).uppercased())
            VStack {
                Image("BL")
                    .resizable()
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 40)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.black, lineWidth: 2)
                    )
                
                Text(authService.userName.prefix(1).uppercased())
                    .font(.caption)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

#Preview {
    BrowseView(authService: AuthService())
}
