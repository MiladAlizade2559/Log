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
#include <../Defines.mqh>
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
    //--- Functions for controlling the work of logs
    string           Massage(const string massage, const ENUM_LOG_TYPE type,const string file,const string fun,const int line,const int error);
    template<typename T>
    string           MassageVariable(const string massage,const string name,const T value, const ENUM_LOG_TYPE type,const string file,const string fun,const int line,const int error);
    template<typename T>
    string           MassageVariableArray(const string massage,const string name,const T &array[], const ENUM_LOG_TYPE type,const string file,const string fun,const int line,const int error);
    string           MassageVariables(const string massage,const string &names[],const string &array[], const ENUM_LOG_TYPE type,const string file,const string fun,const int line,const int error);
    template<typename T>
    string           MassageObject(const string massage,string name,T &value, const ENUM_LOG_TYPE type,const string file,const string fun,const int line,const int error);
    template<typename T>
    string           MassageObjectArray(const string massage,string name,T &array[], const ENUM_LOG_TYPE type,const string file,const string fun,const int line,const int error);
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
//| Loging massage                                                   |
//+------------------------------------------------------------------+
string CLog::Massage(const string massage, const ENUM_LOG_TYPE type,const string file,const string fun,const int line,const int error)
   {
//--- create headers and values array
    string headers[],values[];
//--- seting headers type and massage
    ArrayResize(headers,2);
    ArrayResize(values,2);
    headers[0] = EnumToString(type);
    headers[1] = "Massage";
//--- seting values type and massage
    values[0] = StringFormat("%s ,Fn: %s ,Ln: %d",file,fun,line);
    if(type == ERROR)
        values[0] += StringFormat(" ,Er: %d",error);
    values[1] = massage;
//--- converting headers and values to log tree
    string log_value = LogTree(headers,values);
//--- showing log value in terminal
    Print(log_value);
    ResetLastError();
    if(m_saved)
       {
        ArrayResize(headers,1);
        ArrayResize(values,1);
        headers[0] = TimeToString(TimeTradeServer(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
        values[0] = log_value;
        string log_value_file = LogTree(headers,values);
        //--- save log to file
        m_file.Seek(0, SEEK_END);
        m_file.WriteString(log_value_file,"\n");
       }
    return(log_value);
   }
//+------------------------------------------------------------------+
//| Loging massage and data one variable                             |
//+------------------------------------------------------------------+
template<typename T>
string CLog::MassageVariable(const string massage,const string name,const T value, const ENUM_LOG_TYPE type,const string file,const string fun,const int line,const int error)
   {
//--- create headers and values array
    string headers[],values[];
//--- seting headers data varname and values data value
    ArrayResize(headers,1);
    ArrayResize(values,1);
    headers[0] = name;
    values[0] = (string)value;
//--- converting headers and values data to log tree
    string value_data = LogTree(headers,values);
//--- seting headers type, massage and data
    ArrayResize(headers,3);
    ArrayResize(values,3);
    headers[0] = EnumToString(type);
    headers[1] = "Massage";
    headers[2] = "Data";
//--- seting values type, massage and data
    values[0] = StringFormat("%s ,Fn: %s ,Ln: %d",file,fun,line);
    if(type == LOG_ERROR)
        values[0] += StringFormat(" ,Er: %d",error);
    values[1] = massage;
    values[2] = value_data;
//--- converting headers and values to log tree
    string log_value = LogTree(headers,values);
//--- showing log value in terminal
    Print(log_value);
    ResetLastError();
    if(m_saved)
       {
        ArrayResize(headers,1);
        ArrayResize(values,1);
        headers[0] = TimeToString(TimeTradeServer(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
        values[0] = log_value;
        string log_value_file = LogTree(headers,values);
        //--- save log to file
        m_file.Seek(0, SEEK_END);
        m_file.WriteString(log_value_file,"\n");
       }
    return(log_value);
   }
//+------------------------------------------------------------------+
//| Loging massage and data one array                                |
//+------------------------------------------------------------------+
template<typename T>
string CLog::MassageVariableArray(const string massage,const string name,const T &array[], const ENUM_LOG_TYPE type,const string file,const string fun,const int line,const int error)
   {
//--- create headers and values array
    string headers[],values[];
//--- seting headers data varname
    ArrayResize(headers,1);
    ArrayResize(values,1);
    headers[0] = name;
//--- seting values data array
    string value = "";
    for(int i = 0; i < ArraySize(array); i++)
       {
        //--- sorting lenght values data
        if(StringLen(value) > 100)
           {
            values[0] += value + "\n";
            value = "";
           }
        //--- add index array and converting array value to string
        value += StringFormat("[%d] %s ",i,(string)array[i]);
       }
    values[0] += value;
//--- converting headers data and values data to log tree
    string value_data = LogTree(headers,values);
//--- seting headers type, massage and data
    ArrayResize(headers,3);
    ArrayResize(values,3);
    headers[0] = EnumToString(type);
    headers[1] = "Massage";
    headers[2] = "Data";
//--- seting values type, massage and data
    values[0] = StringFormat("%s ,Fn: %s ,Ln: %d",file,fun,line);
    if(type == LOG_ERROR)
        values[0] += StringFormat(" ,Er: %d",error);
    values[1] = massage;
    values[2] = value_data;
//--- converting headers and values to log tree
    string log_value = LogTree(headers,values);
//--- showing log value in terminal
    Print(log_value);
    ResetLastError();
    if(m_saved)
       {
        ArrayResize(headers,1);
        ArrayResize(values,1);
        headers[0] = TimeToString(TimeTradeServer(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
        values[0] = log_value;
        string log_value_file = LogTree(headers,values);
        //--- save log to file
        m_file.Seek(0, SEEK_END);
        m_file.WriteString(log_value_file,"\n");
       }
    return(log_value);
   }
//+------------------------------------------------------------------+
//| Loging massage and data every variables                          |
//+------------------------------------------------------------------+
string CLog::MassageVariables(const string massage,const string &names[],const string &array[], const ENUM_LOG_TYPE type,const string file,const string fun,const int line,const int error)
   {
//--- create headers and values array
    string headers[],values[];
    ArrayResize(values,ArraySize(array));
//--- sorting array and seting to values data array
    for(int i = 0; i < ArraySize(values); i++)
       {
        //--- checking value string is array
        if(StringSubstr(array[i],0,1) == "[" &&
           StringSubstr(array[i],StringLen(array[i]) - 1) == "]")
           {
            //--- find delimiter from value string for splite array
            int start_array = StringFind(array[i],"]",1) + 2;
            string delimiter = StringSubstr(array[i],1,start_array - 3);
            //--- find value array from value string for splite array
            string value_array = StringSubstr(array[i],start_array);
            value_array = StringSubstr(value_array,0,StringLen(value_array) - 1);
            //--- splite value array to results by delimiter
            string results[];
            StringSplit(value_array,StringGetCharacter(delimiter,0),results);
            string value = "";
            values[i] = "";
            //--- seting values data var array
            for(int res = 0; res < ArraySize(results); res++)
               {
                //--- sorting lenght values data
                if(StringLen(value) > 100)
                   {
                    values[i] += value + "\n";
                    value = "";
                   }
                //--- add index array and converting array value to string
                value += StringFormat("[%d] %s ",res,(string)results[res]);
               }
            values[i] += value;
           }
        else
           {
            //--- seting values data var
            values[i] = array[i];
           }
       }
//--- converting names data and values data to log tree
    string value_data = LogTree(names,values);
//--- seting headers type, massage and data
    ArrayResize(headers,3);
    ArrayResize(values,3);
    headers[0] = EnumToString(type);
    headers[1] = "Massage";
    headers[2] = "Data";
//--- seting values type, massage and data
    values[0] = StringFormat("%s ,Fn: %s ,Ln: %d",file,fun,line);
    if(type == ERROR)
        values[0] += StringFormat(" ,Er: %d",error);
    values[1] = massage;
    values[2] = value_data;
//--- converting headers and values to log tree
    string log_value = LogTree(headers,values);
//--- showing log value in terminal
    Print(log_value);
    ResetLastError();
    if(m_saved)
       {
        ArrayResize(headers,1);
        ArrayResize(values,1);
        headers[0] = TimeToString(TimeTradeServer(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
        values[0] = log_value;
        string log_value_file = LogTree(headers,values);
        //--- save log to file
        m_file.Seek(0, SEEK_END);
        m_file.WriteString(log_value_file,"\n");
       }
    return(log_value);
   }
//+------------------------------------------------------------------+
//| Loging massage and data one object class or struct               |
//+------------------------------------------------------------------+
template<typename T>
string CLog::MassageObject(const string massage,string name,T &value, const ENUM_LOG_TYPE type,const string file,const string fun,const int line,const int error)
   {
//--- create headers and values array
    string headers[],values[];
//--- geting names and values object
    value.Vars(GET_NAMES,headers,true);
    value.Vars(GET_VALUES,values,true);
//--- converting headers and values to log tree
    return(m_log.Log(massage,headers,values,type,file,fun,line,error));
   }
//+------------------------------------------------------------------+
//| Loging massage and data every object class or struct             |
//+------------------------------------------------------------------+
template<typename T>
string CLog::MassageObjectArray(const string massage,string name,T &array[], const ENUM_LOG_TYPE type,const string file,const string fun,const int line,const int error)
   {
//--- checking is not size object array
    int size_obj = ArraySize(array);
    if(size_obj == 0)
        return("");
//--- create headers and values array
    string  names[],values_obj[],headers[],values[];
//--- geting names object
    array[0].Vars(GET_NAMES,names,true);
    int size_names = ArraySize(names);
//--- resizes headers and values
    ArrayResize(headers,size_names * size_obj);
    ArrayResize(values,size_names * size_obj);
//--- geting values objects and seting to values array
    for(int i = 0; i < size_obj; i++)
       {
        //--- geting values object
        ArrayResize(values_obj,0);
        array[i].Vars(GET_VALUES,values_obj,true);
        for(int x = 0; x < size_names; x++)
           {
            //--- seting headers and values
            int index = x + (i * size_names);
            headers[index] = StringFormat("%s[%d]",names[x],i);
            values[index] = values_obj[x];
           }
       }
//--- converting headers and values to log tree
    return(m_log.Log(massage,headers,values,type,file,fun,line,error));
   }
//+------------------------------------------------------------------+
