type Event {
    name: string
    data?: undefined
    meta?: undefined    //for meta-info
    subscribers?: undefined  //for notification
    dependants?: undefined  //for propagation
    store?: undefined   //for propagation
}

//sub or unsub request
type Request {
    loc: string //observer location
    events: undefined //tree where each child is an event
    options?: undefined
}

interface ObservableInterface {
    OneWay: 
        subscribe(Request),
        unsubscribe(Request)
}

interface ObserverInterface {
    OneWay:
        confirm(bool),  //confirm subscription
        notify(Event)
}

interface SelfInterface {
    OneWay:
        emit(Event),    //wrapper for the other two
        propagate(Event),
        notifyAll(Event)
}

