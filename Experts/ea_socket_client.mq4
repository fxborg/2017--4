//+------------------------------------------------------------------+
//|                                             ea_socket_client.mq4 |
//| EA Socket Client                          Copyright 2017, fxborg |
//|                                   http://fxborg-labo.hateblo.jp/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, fxborg"
#property link      "http://fxborg-labo.hateblo.jp/"
#property version   "1.0"
#property strict

#include <socket-library-mt4-mt5.mqh>

input string   Hostname="192.168.179.4";    // Server hostname or IP address
input ushort   ServerPort=8282;        // Server port
input int InpGmtOffset=1; // GMT Offset

// --------------------------------------------------------------------
// Global variables and constants
// --------------------------------------------------------------------
ClientSocket*glbClientSocket=NULL;

// --------------------------------------------------------------------
// Initialisation (no action required)
// --------------------------------------------------------------------
void OnInit() {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(glbClientSocket)
     {
      delete glbClientSocket;
      glbClientSocket=NULL;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!glbClientSocket)
     {
      glbClientSocket=new ClientSocket(Hostname,ServerPort);
      if(glbClientSocket.IsSocketConnected())
        {
         Print("Client connection succeeded");
           } else {
         Print("Client connection failed");
        }
     }

   if(glbClientSocket.IsSocketConnected())
     {

      MqlTick last_tick;
      //---
      if(SymbolInfoTick(Symbol(),last_tick))
        {
         string strMsg="+tick.bid|tick.ask host=tradeview instruments=USDJPY indicator=tick\r\n";
         long offset=3600000*InpGmtOffset;
         long t=1000000*(last_tick.time_msc+offset);

         StringAdd(strMsg,":"+IntegerToString(t)+"\r\n");
         StringAdd(strMsg,"*2"+"\r\n");
         StringAdd(strMsg, StringFormat("+%f\r\n",last_tick.bid));
         StringAdd(strMsg, StringFormat("+%f\r\n",last_tick.ask));
         glbClientSocket.Send(strMsg);
        }

     }

// If the socket is closed, destroy it, and attempt a new connection
// on the next call to OnTick()
   if(!glbClientSocket.IsSocketConnected())
     {
      // Destroy the server socket. A new connection
      // will be attempted on the next tick
      Print("Client disconnected. Will retry.");
      delete glbClientSocket;
      glbClientSocket=NULL;
     }
  }
//+------------------------------------------------------------------+
