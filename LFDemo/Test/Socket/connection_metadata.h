//
//  connection_metadata.h
//  LFDemo
//
//  Created by wulinfeng on 2019/8/6.
//  Copyright © 2019 lio. All rights reserved.
//

#ifndef connection_metadata_h
#define connection_metadata_h

#include <websocketpp/config/asio_no_tls_client.hpp>
#include <websocketpp/client.hpp>
typedef websocketpp::client<websocketpp::config::asio_client> client;


class connection_metadata {
public:
    typedef websocketpp::lib::shared_ptr<connection_metadata> ptr;
    
    connection_metadata(int id, websocketpp::connection_hdl hdl, std::string uri)
    : m_id(id)
    , m_hdl(hdl)
    , m_status("Connecting")
    , m_uri(uri)
    , m_server("N/A")
    {}
    
    
    void on_open(client * c, websocketpp::connection_hdl hdl);
    
    void on_fail(client * c, websocketpp::connection_hdl hdl) ;
    
    void on_close(client * c, websocketpp::connection_hdl hdl) ;
    
    void on_message(websocketpp::connection_hdl, client::message_ptr msg);
    
    websocketpp::connection_hdl get_hdl() const {
        return m_hdl;
    }
    
    int get_id() const {
        return m_id;
    }
    
    std::string get_status() const {
        return m_status;
    }
    
    void record_sent_message(std::string message) {
        m_messages.push_back(">> " + message);
    }

    friend std::ostream & operator<< (std::ostream & out, connection_metadata const & data);
private:
    int m_id;
    websocketpp::connection_hdl m_hdl;
    std::string m_status;
    std::string m_uri;
    std::string m_server;
    std::string m_error_reason;
    std::vector<std::string> m_messages;
};

//
//std::ostream & operator<< (std::ostream & out, connection_metadata const & data) {
//    out << "> URI: " << data.m_uri << "\n"
//    << "> Status: " << data.m_status << "\n"
//    << "> Remote Server: " << (data.m_server.empty() ? "None Specified" : data.m_server) << "\n"
//    << "> Error/close reason: " << (data.m_error_reason.empty() ? "N/A" : data.m_error_reason) << "\n";
//    out << "> Messages Processed: (" << data.m_messages.size() << ") \n";
//
//    std::vector<std::string>::const_iterator it;
//    for (it = data.m_messages.begin(); it != data.m_messages.end(); ++it) {
//        out << *it << "\n";
//    }
//
//    return out;
//};

#endif /* connection_metadata_h */
