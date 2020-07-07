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

enum RESToperation {
    case save
    case delete
    case update
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
    
    class func loadBrands(onComplete: @escaping ([Brand]?) -> Void) {
        guard let url = URL(string: "https://fipeapi.appspot.com/api/1/carros/marcas.json") else {
            onComplete(nil)
            return
        }
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            
            //Esse erro e somento do App nao tem nada a ver com o servidor
            //Os erros do servidor vem dentro do objeto de resposta(response)
            if error == nil {
                
                //Estou tratando o response com HTTPURLResponse. Atraves disso, tenho acesso as respostas do servidor (200...504)
                guard let response = response as? HTTPURLResponse else {return}
                onComplete(nil)
                
                
                if response.statusCode == 200 {
                    guard let data = data else {return}
                    do {
                        let brands = try JSONDecoder().decode([Brand].self, from: data)
                        onComplete(brands)
                    } catch {
                        print(error.localizedDescription)
                        onComplete(nil)
                    }
                    
                } else {
                    print("Alguma coisa esta errada...")
                    onComplete(nil)
                }
                
            } else {
                onComplete(nil)
            }
        }
        //O metodo RESUME e quem faz a solicitacao para o servidor
        dataTask.resume()
    }
    
    // Metodo GET
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
    
    // Metodo CREATE -> POST
    class func save(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .save, onComplete: onComplete)
    }
    
    // Metodo UPDATE -> PUT
    class func update(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .update, onComplete: onComplete)
    }
    
    // Metodo DELETE -> DELETE
    class func delete(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .delete, onComplete: onComplete)
    }
    
    
    private class func applyOperation(car: Car, operation: RESToperation, onComplete: @escaping (Bool) -> Void) {
        
        //Criando a variavel a contem o ID
        let urlString = basePath + "/" + (car._id ?? "")
        
        //Criando outro endpoint na URL
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        
        var httpMethod: String = ""
        var request = URLRequest(url: url)
        
        switch operation {
        case .save:
            httpMethod = "POST"
        case .update:
            httpMethod = "PUT"
        case .delete:
            httpMethod = "DELETE"
        }
        
        //Metodo HTTP
        request.httpMethod = httpMethod
        
        //Para passar as informacoes para o servidor, e necessario utilizar o JSON.
        guard let json = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        
        //Alimentando o corpo do request
        request.httpBody = json
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data else {
                    onComplete(false)
                    return
                }
            } else {
                onComplete(false)
            }
        }
        dataTask.resume()
    }
}
