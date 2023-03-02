from .\TestModule import *
include "console.iol"

service ObserverA {

    execution: concurrent

    outputPort Observable {
        location: "socket://localhost:8000"
        protocol: http
        interfaces: ObservableInterface
    } 

    inputPort Observer {
        location: "socket://localhost:8001"
        protocol: http
        interfaces: ObserverInterface
    }

    init {
        with(subRequest) {
            .loc="socket://localhost:8001"
            with(.events) {
                .A="A"
                .C="C"
            }
        }
        subscribe@Observable(subRequest)
        global.countA = 0
        global.countC = 0
    }

    main {
        [
            confirm(result)
        ]
        {
            print@Console( "subscription confirmed\n" )(  )
        }
        [
            notify(Event)
        ]
        {
            if(Event.name == "A") {
                print@Console( "received event A with value "+Event.data+"\n")(  )
                global.countA = global.countA +1
                if(global.countA == 10) {
                    unsubscribe@Observable({.loc="socket://localhost:8001" .events.A="A"})
                }     
            }
            if(Event.name == "C") {
                print@Console( "received event C with value "+Event.data+"\n" )(  )
                global.countC = global.countC + 1
                if(global.countC == 10) {
                    unsubscribe@Observable({.loc="socket://localhost:8001" .events.C="C"})
                }
            }         
        }
    }

}