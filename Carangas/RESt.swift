//
//  RESt.swift
//  Carangas
//
//  Created by Bruno Silva on 06/07/20.
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import Foundation

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
    
    // Criando uma sessoa
    private static let session = URLSession(configuration: configuration)
    
    class func loadCars() {
        guard let url = URL(string: basePath) else {return}
        
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
                if response.statusCode == 200 {
                    guard let data = data else {return}
                    do {
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        for car in cars {
                            print(car.name, car.brand)
                        }
                    } catch {
                        
                    }
                } else {
                    print("Alguma coisa esta errada...")
                }
                
            } else {
                print(error!)
            }
        }
        //O metodo RESUME e quem faz a solicitacao para o servidor
        dataTask.resume()
    }
}
