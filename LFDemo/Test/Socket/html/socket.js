class SocketClient {
    constructor() {
        console.log('websocket constructed')
    }


    connect(callback) {
        this._ws = new window.WebSocket('ws://127.0.0.1:9003');
        this._ws.onopen = () => {
            console.log('Websocket opened!');
        };

        this._ws.onclose = () => {
            console.log('Websocket closed!');
        };

        this._ws.onmessage = msg => {
            // console.log(`receive message ${msg.data}`);
            // this.getMsgFromServer(msg.data);
            callback(msg.data);
        };
    }

    send(msg) {
        this._ws.send(JSON.stringify(msg))
    }


    close() {
        this._ws.close();
    }
}