//+------------------------------------------------------------------+
//|                                                          Log.mqh |
//|                                   Copyright 2025, Milad Alizade. |
//|                   https://www.mql5.com/en/users/MiladAlizade2559 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Milad Alizade."
#property link      "https://www.mql5.com/en/users/MiladAlizade2559"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <ReadWrite/FileTXT.mqh>
//+------------------------------------------------------------------+
//| Class CLog                                                       |
//| Usage: Control log work                                          |
//+------------------------------------------------------------------+
class CLog
   {
private:
    CFileTXT         m_file;     // object CFileTXT for saving logs in file
    bool             m_saved;    // is saved logs to log file
protected:
    //--- Function for converting information to log tree
    string           LogTree(const string &headers[], const string &values[]);
public:
                     CLog(void);
                    ~CLog(void);
    //--- Functions for controlling the work of log file
    bool             Open(const string path,const string log_file,const bool is_common_folder = false);
    void             Close(void);
   };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CLog::CLog(void) : m_saved(false)
   {
   }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CLog::~CLog(void)
   {
   }
//+------------------------------------------------------------------+
//| Open log file for saving                                         |
//+------------------------------------------------------------------+
bool CLog::Open(const string path,const string file_name,const bool is_common_folder = false)
   {
    m_saved = false;
//--- set path
    m_file.Path(path,is_common_folder);
//--- open log file
    int handle = m_file.Open(file_name,FILE_READ | FILE_WRITE | FILE_SHARE_READ | FILE_TXT);
//--- check handle
    if(handle == INVALID_HANDLE)
        return(false);
    m_saved = true;
    return(true);
   }
//+------------------------------------------------------------------+
//| Close log file                                                   |
//+------------------------------------------------------------------+
void CLog::Close(void)
   {
    if(m_saved)
        //--- close log file
        m_file.Close();
   }
//+------------------------------------------------------------------+
//| Converting information to log tree                               |
//+------------------------------------------------------------------+
string CLog::LogTree(const string &headers[], const string &values[])
   {
//--- created variables
    int len_header = 0;
    int len = 0;
    string log_value = "";
    string value = "";
    string sps = "";
    string header = "";
//--- get max lenght header in headers and set to len_header
    for(int i = 0; i < ArraySize(headers); i++)
       {
        len = StringLen(headers[i]);
        if(len > len_header)
            len_header = len;
       }
//--- completing headers to values
//--- header ==> value
    for(int i = 0; i < ArraySize(headers); i++)
       {
        //--- sorting header to one column
        len = StringLen(headers[i]);
        sps = "";
        StringInit(sps,len_header - len,' ');
        header = StringFormat("%s%s ==> ",headers[i],sps);
        //--- sorting value to one column
        string results[];
        StringSplit(values[i],'\n',results);
        value = "";
        //--- checking not null results array
        if(ArraySize(results) > 0)
           {
            for(int res = 0; res < ArraySize(results) - 1; res++)
               {
                sps = "";
                StringInit(sps,len_header + 5,' ');
                value += StringFormat("%s\n%s",results[res],sps);
               }
            value += results[ArraySize(results) - 1];
           }
        //--- adding header and value to log_value
        log_value += StringFormat("%s%s\n",header,value);
       }
    return(log_value);
   }
//+------------------------------------------------------------------+
