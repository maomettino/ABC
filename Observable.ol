from .\TestModule import *
from time import Time
include "console.iol"

service Observable() { 

    execution: concurrent
    
    embed Time as Time
    
    outputPort Observer {
        location: "placeholder"
        protocol: http
        interfaces: ObserverInterface
    }

    outputPort Self{
        location: "local://Inner"
        Interfaces: SelfInterface
    }

    inputPort Observable {
        location: "socket://localhost:8000"
        protocol: http
        interfaces: ObservableInterface
    }

    inputPort Self {
        Location: "local://Inner"
        Interfaces: SelfInterface
    }

    init {
        initializeEvents
    }

    main {
        [
            subscribe(subReq)
        ]
        {
            print@Console( "received subscription request to events:\n" )(  )
            subLocation = subReq.loc
            foreach( eventName : subReq.events ) {
                println@Console( "-"+eventName )()
                with(global.events) {
                    .(eventName).subscribers.(subLocation)= undefined
                }
            }
            Observer.location = subLocation
            confirm@Observer(true)
            Observer.location = "placeholder"
            if(subLocation=="socket://localhost:8001")
                ev << {.name="A", .data="Alice"}
            else if(subLocation=="socket://localhost:8002")
                ev << {.name="B", .data="Bob"}
            for(i=1, i<=20, i++) {
                sleep@Time( 5000 )()
                print@Console( "\n" )( ) 
                emit@Self(ev)
            }     
        }
        [
            unsubscribe(unsubReq)
        ]
        {
            subLocation = unsubReq.loc
            if(subLocation=="socket://localhost:8001")
                obs = "ObserverA"
            else if(subLocation=="socket://localhost:8002")
                obs = "ObserverB"
            println@Console( "received unsubscribe request from "+obs+" to events:" )( )
            foreach( eventName : unsubReq.events ) {
                println@Console( "-"+eventName+"\n" )()
                with(global.events) {
                    undef(.(eventName).subscribers.(subLocation))
                }
            }
            
        }
        [
            emit(Event)
        ]
        {
            notifyAll@Self(Event)
            propagate@Self(Event)
        }
        [
            notifyAll(Event)
        ]
        {
            foreach(sub : global.events.(Event.name).subscribers ) {
                Observer.location = sub
                if(sub=="socket://localhost:8001")
                    obs = "ObserverA"
                else if(sub=="socket://localhost:8002")
                    obs = "ObserverB"
                println@Console( "notifying event "+Event.name+" to "+obs )( )
                notify@Observer(Event)
            }
            Observer.location = "placeholder"
        }
        [
            propagate(Event)
        ]
        {
            print@Console( "propagating "+Event.name+"\n" )( )
            foreach(dependant : global.events.(Event.name).dependants) {
                if (dependant == "C") {
                    if(Event.name == "A") {
                        global.events.("C").store.A=true
                    }
                    if(Event.name == "B") {
                        global.events.("C").store.B=true
                    }
                    if(global.events.("C").store.A && global.events.("C").store.B) {
                        global.events.("C").store.A = false
                        global.events.("C").store.B = false
                        notifyAll@Self({.name="C" .data="Callisto"})
                        propagate@Self({.name="C" .data="Callisto"})
                    }
                }             
            }
        }
    }

    define initializeEvents {
        with(global.events) {
            with(.A) {
                .name= "A"
                .data = undefined
                with(.dependants) {
                    .C = undefined
                }
            }
            with(.B) {
                .name= "B"
                .data = undefined
                with(.dependants) {
                    .C= undefined
                }
            }
            with(.C) {
                .name= "c"
                .data = undefined
                .store = undefined
            }          
        }         
    }

}