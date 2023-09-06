//
//  ContentView.swift
//  ChatGPT2
//
//  Created by Chirag Kaushik on 29/08/23.
////"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"
import OpenAISwift
import SwiftUI

//struct OpenAIConfig {
//    static let apiKey = "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"
//}


final class ViewModel: ObservableObject {
  
    init() {}

    private var client: OpenAISwift?
    
    
//    func setup() {
//        let config = OpenAISwift.Config(baseURL: "https://api.openai.com/v1/", endpointPrivider: OpenAIEndpointProvider.default, session: URLSession.shared, authorizeRequest: <#T##(inout URLRequest) -> Void#>)
//            client = OpenAISwift(config: config)
//    }
    func setup() {
        
        let endpointProvider = OpenAIEndpointProvider(source: .proxy(
            path: { api in
                switch api {
                case .completions:
                    return "/your_custom_completion_endpoint"
                // Add cases for other APIs if needed
                case .edits:
                    return "/v1/edits"
                case .chat:
                    return "/v1/chat/completions"
                case .images:
                    return "/v1/images/generations"
                case .embeddings:
                    return "/v1/embeddings"
                case .moderations:
                    return "/v1/moderations"
                }
            },
            method: { api in
                switch api {
                case .completions, .edits, .chat, .images, .embeddings, .moderations:
                    return "POST"
                }
            }
        ))
        
        
        let session = URLSession.shared
        
        let apiKey = "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"
        let authorizeRequest: (inout URLRequest) -> Void = { request in
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        let config = OpenAISwift.Config(
            baseURL: "https://api.openai.com/v1/",
            endpointPrivider: endpointProvider,
            session: session,
            authorizeRequest: authorizeRequest
        )
        
        client = OpenAISwift(config: config)
    }

    
    func send(text: String, completion: @escaping(String) -> Void) {
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: {
            result in
            switch result {
                case.success(let model):
                let output = model.choices?.first?.text ?? ""
                completion(output)
                
                case.failure(_):
                break
            }
        })
    }
}
struct ContentView: View {
    @ObservedObject
    var viewmodel =   ViewModel()
    @State
    var text = ""
    @State
    var models = [String]()
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                ForEach(models.indices, id: \.self) { index in
                    HStack {
                        Text(models[index])
                    }
                }

//                ForEach(models, id: \.self) {
//                    string in HStack {
//                        Text(string)
//                    }
//                }
                Spacer()
                HStack {
                    Image("man").resizable().frame(width: 40, height: 40)
                    TextField("Enter your text", text: $text).frame(height: 40).border(.gray).cornerRadius(2)
                    Button("Send") {
                        send()
                    }.frame(width: 100, height: 40).background(.blue).foregroundColor(.white).font(.title3).cornerRadius(12)
                }
            }.padding(.horizontal).navigationTitle("OpenAI ChatBot")
        }.onAppear {
            viewmodel.setup()
        }
    }
    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            return
        }
        models.append("Me : \(text)")
        viewmodel.send(text: text) {
            result in print(result)
            self.models.append("chatGpt :" + result)
        }
        self.text = ""
    }
}


struct ContentView_Previews: PreviewProvider {
    static
    var previews: some View {
        ContentView()
    }
    
}
