//
//  RESt.swift
//  Carangas
//
//  Created by Bruno Silva on 06/07/20.
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import Foundation

enum CarError {
    case url
    case taskError(error: Error)
    case noRespose
    case noData
    case responseStatusCode(code: Int)
    case invalidJson
}

class RESt {
    
    private static let basePath = "https://carangas.herokuapp.com/cars"
    
    // Criando uma closure
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        config.timeoutIntervalForRequest = 30.0
        config.httpMaximumConnectionsPerHost = 5
        return config
    }()
    
    // Criando uma sessao
    private static let session = URLSession(configuration: configuration)
    
    class func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError) -> Void) {
        guard let url = URL(string: basePath) else {
            onError(.url)
            return
        }
        
        //Para fazer uma requisicao, e necessario criar uma tarefa. Abaixo e criado uma tarefa.
        //Informacoes da Closure
        //Data -> informacao que o servidor deu, no caso o proprio JSON
        //Response -> Resposta do servidor
        //Error -> Caso tenha acontecido algum erro
        // ======== foi necessario criar uma variavel chamada "dataTask" porque a funcao dataTask nao e executada, apenas criada.
        // ======== Alem disso, abaixo apenas criei uma tarefa
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            
            //Esse erro e somento do App nao tem nada a ver com o servidor
            //Os erros do servidor vem dentro do objeto de resposta(response)
            if error == nil {
                
                //Estou tratando o response com HTTPURLResponse. Atraves disso, tenho acesso as respostas do servidor (200...504)
                guard let response = response as? HTTPURLResponse else {return}
                onError(.noRespose)
                
                
                if response.statusCode == 200 {
                    guard let data = data else {return}
                    do {
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        onComplete(cars)
                    } catch {
                        print(error.localizedDescription)
                        onError(.invalidJson)
                    }
                    
                } else {
                    print("Alguma coisa esta errada...")
                    onError(.responseStatusCode(code: response.statusCode))
                }
                
            } else {
                onError(.taskError(error: error!))
            }
        }
        //O metodo RESUME e quem faz a solicitacao para o servidor
        dataTask.resume()
    }
}
