//
//  MemoView.swift
//  Class Project
//
//  Created by Archit Singh on 11/18/23.
//

import SwiftUI

struct MemoView: View {
    @EnvironmentObject var viewModel: MemoViewModel
    @State private var showingAddMemo = false
    @State var trip: Trip
    
    var body: some View {
        List {
            ForEach(viewModel.memos.filter {$0.trip == trip}, id: \.id) { memo in
                NavigationLink(destination: MemoDetailView(memo: memo)) {
                    VStack(alignment: .leading) {
                        Text(memo.title ?? "No Title")
                            .font(.headline)
                    }
                }
            }
            .onDelete(perform: viewModel.removeMemo)
        }
        .listStyle(PlainListStyle())
        .navigationTitle("My Memos")
        .navigationBarItems(
            leading: EditButton(),
            trailing: Button(action: { showingAddMemo = true }) {
                Image(systemName: "plus")
            }
        )
        .sheet(isPresented: $showingAddMemo) {
            AddMemoView(trip: trip, memos: $viewModel.memos)
        }
    }
}

struct MemoDetailView: View {
    var memo: Memo

    var body: some View {
        VStack {
            Text(memo.title!)
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            Text(memo.text ?? "No Text")

//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
                    ForEach(Array(memo.imagesAsArray().enumerated()), id: \.element) { index, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
//                }
//            }
        }
        .navigationBarTitle("Memo Details", displayMode: .inline)
    }
}

struct AddMemoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: MemoViewModel
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var showImagePicker: Bool = false
    @State private var inputImage: UIImage?
    @State var trip: Trip?
    @State private var images: [UIImage] = []
    @Binding var memos: [Memo]
    
    var body: some View {
        NavigationView {
            VStack {
                if trip != nil {
                    HStack{
                        Text("Enter Title: ")
                        TextField("Title", text: $title)
                    }
                    TextEditor(text: $text)
                        .padding()
                        .border(Color.gray, width: 1)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(images, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            }
                        }
                    }
                }
                else{
                    Text("Create a trip before adding memos.")
                }

                Button(action: {
                    self.showImagePicker = true
                }) {
                    Label("Add Image", systemImage: "photo")
                }
                .padding()
                Button("Add Memo") {
                    addMemo()
                }
                .padding()

                Spacer()
            }
            .navigationBarTitle("Add Memo", displayMode: .inline)
            .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
        }
    }

    private func addMemo() {
        viewModel.addMemo(title: title, text: text, images: inputImage != nil ? [inputImage!] : [], forTrip: trip!)
        presentationMode.wrappedValue.dismiss()
    }

    private func loadImage() {
        guard let inputImage = inputImage else { return }
        images.append(inputImage)
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


#Preview {
    MemoView(trip: Trip())
}
