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
