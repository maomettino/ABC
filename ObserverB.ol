from .\TestModule import *
include "console.iol"

service ObserverB {

    execution: concurrent

    outputPort Observable {
        location: "socket://localhost:8000"
        protocol: http
        interfaces: ObservableInterface
    } 

    inputPort Observer {
        location: "socket://localhost:8002"
        protocol: http
        interfaces: ObserverInterface
    }

    init {
        with(subRequest) {
            .loc="socket://localhost:8002"
            with(.events) {
                .B="B"
                .C="C"
            }
        }
        global.countB = 0
        global.countC = 0
        subscribe@Observable(subRequest)
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
            if(Event.name == "B") {
                print@Console( "received event B with value "+Event.data+"\n")(  )
                global.countB = global.countB +1
                if(global.countB == 10) {
                    unsubscribe@Observable({.loc="socket://localhost:8002" .events.B="B"})
                }    
            }
            if(Event.name == "C") {
                print@Console( "received event C with value "+Event.data+"\n" )(  )
                global.countC = global.countC + 1
                if(global.countC == 10) {
                    unsubscribe@Observable({.loc="socket://localhost:8002" .events.C="C"})
                }
            }         
        }
    }

}