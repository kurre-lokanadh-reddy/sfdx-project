/* ==============================================
* @class name: IFB_ErrorLoggingService
* @author: Accenture ATCI(LOKAR) | CPS-417
* @group: IFB
* @purpose: Service Class Used for logging the Database DML Operation Results
* @created date (mm/dd/yyyy) :  12-Dec-2022
================================================*/
public without sharing class IFB_ErrorLoggingService {
    //constants
    private static final String STR_STATUS_NOTSTARTED ='Not Started';
    private static final String STR_STATUS_COMPLETED='Completed';
    private static final String STR_UPSERT = 'Upsert';
    private static final String STR_DELETE = 'Delete';
    private static final String STR_INSERT = 'Insert';
    private static final String STR_UPDATE = 'Update';
    
    /*=================================================================================== 
    * @method name : createMasterLog()
    * @author : Accenture ATCI (LOKAR)
    * @group : IFB    
    * @purpose : Method to create a Master Record of the Error Log..
    * @param :  String strObjectName, String strClassName, String strRawJSON, String strOperationType
    * @return : NA
    * @created date (mm/dd/yyyy) :  12-Dec-2022
    * @last modified date (mm/dd/yyyy) : 
    * @last modified by: 
    ==================================================================================== */
    private static void createMasterLog( String strObjectName, String strClassName, String strRawJSON, String strOperationType){
        IFB_ErrorLogHeader__c objMaster = new IFB_ErrorLogHeader__c();
        objMaster.IFB_Object__c=strObjectName;
        //objMaster.IFB_Status__c =STR_STATUS_NOTSTARTED ;
        objMaster.IFB_ClassName__c = strClassName;
        objMaster.IFB_RAWLog__c=strRawJSON;
        objMaster.IFB_OperationType__c=strOperationType;
        insert objMaster;
    }

    /*=================================================================================== 
    * @method name : logDMLResultsRawJSON()
    * @author : Accenture ATCI (LOKAR)
    * @group : IFB    
    * @purpose : Method to create a Master Record for the error log with all the individual results stored as JSON.
    * @param :  String strObjectName, String strIssueType, List<Database.SaveResult> lstSaveResult
    * @return : NA
    * @created date (mm/dd/yyyy) :  12-Dec-2022
    * @last modified date (mm/dd/yyyy) : 
    * @last modified by: 
    ==================================================================================== */
    public static void logDMLResultsRawJSON( String strObjectName, String strClassName, List<Database.SaveResult> lstSaveResult, Boolean blnIsInsert){
        try{
            createMasterLog(strObjectName,strClassName,JSON.serialize(lstSaveResult), blnIsInsert? STR_INSERT: STR_UPDATE);
        }
        catch(Exception e){

        }
    }
    /*=================================================================================== 
    * @method name : logDMLResultsRawJSON()
    * @author : Accenture ATCI (LOKAR)
    * @group : IFB    
    * @purpose : Method to create a Master Record for the error log with all the individual results stored as JSON.
    * @param :  String strObjectName, String strClassName, List<Database.UpsertResult> lstSaveResult
    * @return : NA
    * @created date (mm/dd/yyyy) :  12-Dec-2022
    * @last modified date (mm/dd/yyyy) : 
    * @last modified by: 
    ==================================================================================== */
    public static void logDMLResultsRawJSON( String strObjectName, String strClassName, List<Database.UpsertResult> lstSaveResult){
        try{
            createMasterLog(strObjectName,strClassName,JSON.serialize(lstSaveResult),STR_UPSERT);
        }
        catch(Exception e){

        }
    }
    /*=================================================================================== 
    * @method name : logDMLResultsRawJSON()
    * @author : Accenture ATCI (LOKAR)
    * @group : IFB    
    * @purpose : Method to create a Master Record for the error log with all the individual results stored as JSON.
    * @param :  String strObjectName, String strClassName, List<Database.DeleteResult> lstSaveResult
    * @return : NA
    * @created date (mm/dd/yyyy) :  12-Dec-2022
    * @last modified date (mm/dd/yyyy) : 
    * @last modified by: 
    ==================================================================================== */
    public static void logDMLResultsRawJSON( String strObjectName, String strClassName, List<Database.DeleteResult> lstSaveResult){
        try{
            createMasterLog(strObjectName,strClassName,JSON.serialize(lstSaveResult),STR_DELETE);
        }
        catch(Exception e){

        }
    }

    /*=================================================================================== 
    * @method name : deserializeRawJSONLog()
    * @author : Accenture ATCI (LOKAR)
    * @group : IFB    
    * @purpose : Method to create Detail Log records for each of the error that occuered.
    * @param : List<IFB_ErrorLogHeader__c> lstErrLogMasters
    * @return : NA
    * @created date (mm/dd/yyyy) :  12-Dec-2022
    * @last modified date (mm/dd/yyyy) : 
    * @last modified by: 
    ==================================================================================== */
    public static void deserializeRawJSONLog(List<IFB_ErrorLogHeader__c> lstErrLogMasters){
        if(lstErrLogMasters==null || lstErrLogMasters.isEmpty()){
            return;
        }
        List<IFB_ErrorLogDetail__c> lstDetailLogs = new List<IFB_ErrorLogDetail__c>();

        for(IFB_ErrorLogHeader__c objMaster: lstErrLogMasters){
            if( String.isNotBlank(objMaster.IFB_RAWLog__c) ){
                lstDetailLogs.addAll( createDetailLogs(objMaster.IFB_RAWLog__c, objMaster.Id) );
            }
            objMaster.IFB_Status__c = STR_STATUS_COMPLETED;
        }

        if(!lstDetailLogs.isEmpty()){
            Database.insert(lstDetailLogs, false);
        }
        Database.update(lstErrLogMasters, false);

    }
    /*=================================================================================== 
    * @method name : createDetailLogs()
    * @author : Accenture ATCI (LOKAR)
    * @group : IFB    
    * @purpose : Method to create a Detail Error Logs..
    * @param :  String strRAWjson, String strMasterId
    * @return : List<IFB_ErrorLogDetail__c>
    * @created date (mm/dd/yyyy) :  12-Dec-2022
    * @last modified date (mm/dd/yyyy) : 
    * @last modified by: 
    ==================================================================================== */
    private static List<IFB_ErrorLogDetail__c> createDetailLogs(String strRAWjson, String strMasterId){
        List<IFB_ErrorLogDetail__c> lstDetailLogs = new List<IFB_ErrorLogDetail__c>();
        IFB_ErrorLogDetail__c objDetailLog;
        List<IFB_ResultWrapper> lstRes = (List<IFB_ResultWrapper>) JSON.deserialize(strRAWjson, List<IFB_ResultWrapper>.class);
        for(IFB_ResultWrapper objRes: lstRes){
            objDetailLog = new IFB_ErrorLogDetail__c();
            objDetailLog.IFB_ErrorLogHeader__c = strMasterId;
            objDetailLog.IFB_RecordID__c = objRes.id;
            objDetailLog.IFB_Success__c = objRes.success;
            objDetailLog.IFB_ErrorReason__c = objRes.errors.toString(); //only shows 10 Errors
            lstDetailLogs.add(objDetailLog);
        }
        return lstDetailLogs;
    }
    /*=================================================================================== 
    * @method name : createDetailLogs()
    * @author : Accenture ATCI (LOKAR)
    * @group : IFB    
    * @purpose : Method to create a Detail Error Logs..
    * @param :  String strRAWjson, String strMasterId
    * @return : List<IFB_ErrorLogDetail__c>
    * @created date (mm/dd/yyyy) :  12-Dec-2022
    * @last modified date (mm/dd/yyyy) : 
    * @last modified by: 
    ==================================================================================== */
    /*
    private static List<IFB_ErrorLogDetail__c> createDetailLogs2(String strRAWjson, String strMasterId){
        String strMasterTag = '"IFB_ErrorLogHeader__c" : "'+strMasterId+'", "IFB_RecordID__c"';
        strRAWJson = strRAWJson.replace('"id"', strMasterTag);
        strRAWJson = strRAWJson.replace('"success"','"IFB_Success__c"');
        strRAWJson = strRAWJson.replace(']',']"');
        strRAWJson = strRAWJson.replace('"errors":','"IFB_ErrorReason__c":"');
        return (List<IFB_ErrorLogDetail__c>) JSON.deserialize(strRAWJson, List<IFB_ErrorLogDetail__c>.class);
    }
    */

    private Class IFB_ResultWrapper {
        private String id;
        private List<Database.Error> errors;
        private Boolean success;
    }
}