import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var input = ""
    @State private var password = "1234"
    @State private var unlock = false
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var images: [UIImage] = []

    var body: some View {
        if unlock {
            PhotoVaultView(images: $images, photoItems: $photoItems)
        } else {
            CalculatorView(input: $input, onEnter: checkPassword)
        }
    }

    func checkPassword() {
        if input == password {
            unlock = true
        }
        input = ""
    }
}

struct CalculatorView: View {
    @Binding var input: String
    var onEnter: () -> Void
    let keyRows = [
        ["7","8","9","÷"],
        ["4","5","6","×"],
        ["1","2","3","−"],
        ["0",".","=","+"]
    ]

    var body: some View {
        VStack(spacing:14) {
            Text(input)
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            ForEach(keyRows, id:\.self) { row in
                HStack(spacing:12) {
                    ForEach(row, id:\.self) { key in
                        Button(key) {
                            if key == "=" {
                                onEnter()
                            } else {
                                input.append(key)
                            }
                        }
                        .frame(width:72, height:72)
                        .background(Color(UIColor.systemGray5))
                        .clipShape(Circle())
                        .font(.title)
                    }
                }
            }
        }
        .padding()
    }
}

struct PhotoVaultView: View {
    @Binding var images: [UIImage]
    @Binding var photoItems: [PhotosPickerItem]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing:8) {
                    ForEach(images.indices, id:\.self) { idx in
                        Image(uiImage: images[idx])
                            .resizable()
                            .scaledToFill()
                            .frame(height:160)
                            .clipped()
                            .onLongPressGesture {
                                images.remove(at: idx)
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("照片保险箱")
            .toolbar {
                PhotosPicker(selection: $photoItems, matching: .images) {
                    Text("添加照片")
                }
            }
            .onChange(of: photoItems) { newItems in
                Task {
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data:data) {
                            images.append(img)
                        }
                    }
                    photoItems.removeAll()
                }
            }
        }
    }
}

@main
struct CalcSafeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
