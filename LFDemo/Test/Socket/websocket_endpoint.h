//
//  websocket_endpoint.h
//  LFDemo
//
//  Created by wulinfeng on 2019/8/6.
//  Copyright © 2019 lio. All rights reserved.
//

#ifndef websocket_endpoint_h
#define websocket_endpoint_h


#include "connection_metadata.h"

class websocket_endpoint {
public:
    websocket_endpoint ();
    
    ~websocket_endpoint();
    
    int connect(std::string const & uri) ;
    
    void close(int id, websocketpp::close::status::value code, std::string reason);
    
    void send(int id, std::string message);
    
    connection_metadata::ptr get_metadata(int id) ;
    
    
private:
    typedef std::map<int,connection_metadata::ptr> con_list;
    
    client m_endpoint;
    websocketpp::lib::shared_ptr<websocketpp::lib::thread> m_thread;
    
    con_list m_connection_list;
    int m_next_id;
};


#endif /* websocket_endpoint_h */
