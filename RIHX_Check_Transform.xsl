<?xml version="1.0" encoding="UTF-8"?>
<!-- *********************************************************************************************** -->
<!-- File:    RIHX_Check_Transform.xsl                                                               -->
<!--                                                                                                 -->
<!-- Purpose: To Transform the Request for Waitout Queue                                             -->
<!--                                                                                                 -->
<!--                                                                                                 -->
<!-- Scope:   All Domains                                                                            -->
<!--                                                                                                 -->
<!-- Change History:                                                                                 -->
<!--       Date     Author           Description of Change                                           -->
<!--    ==========  =============    =============================================================   -->
<!--    09/28/2020  Shabharish          Original Development for RIHX                                -->
<!-- *********************************************************************************************** -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:dp="http://www.datapower.com/extensions" extension-element-prefixes="dp"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:aig="http://logservice.aig.com/AIGLogService"
    exclude-result-prefixes="dp soapenv">
    <!-- Imorting the config file to fetech the values 
    <xsl:import href="local:///ReinsuranceHistory_MPG/RIHX_WaitOutRequest_ConfigSetting.xsl"/>-->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        
        <xsl:variable name="inputRequest"><xsl:copy-of select="."/></xsl:variable>
        <!-- Check if the request is a first request-->
        <xsl:variable name="firstRequest"><xsl:value-of select="dp:variable('var://context/local/FirstRequest')"/></xsl:variable>
        <xsl:choose>
            <xsl:when test="$firstRequest = 'true'">
                <!-- Setting default values for  -->
                <xsl:variable name="NumLogNotifies"><xsl:value-of select="number(0)"/></xsl:variable>
                <xsl:variable name="StartDateTime"><xsl:value-of select="date:date-time()"/></xsl:variable>
                <xsl:variable name="FollowUpDateTime"><xsl:value-of select="date:date-time()"/></xsl:variable>
                <xsl:variable name="CICSTAIAGLResponseReceivedOK"><xsl:value-of select="'false'"/></xsl:variable>
                <xsl:variable name="CICSTAIAGLAResponseReceivedOK"><xsl:value-of select="'false'"/></xsl:variable>
                <xsl:variable name="RIHXResponseAGLSentOK"><xsl:value-of select="'false'"/></xsl:variable>
                <xsl:variable name="RIHXResponseAGLASentOK"><xsl:value-of select="'false'"/></xsl:variable> 
                
                <!-- Storing the vaules in context variables for further use  -->                
                <dp:set-variable name="'var://context/local/NumLogNotifies'" value="$NumLogNotifies"/>
                <dp:set-variable name="'var://context/local/StartDateTime'" value="$StartDateTime"/>
                <dp:set-variable name="'var://context/local/FollowUpDateTime'" value="$FollowUpDateTime"/>
                <dp:set-variable name="'var://context/local/CICSTAIAGLResponseReceivedOK'" value="$CICSTAIAGLResponseReceivedOK"/>
                <dp:set-variable name="'var://context/local/CICSTAIAGLAResponseReceivedOK'" value="$CICSTAIAGLAResponseReceivedOK"/>
                <dp:set-variable name="'var://context/local/RIHXResponseAGLSentOK'" value="$RIHXResponseAGLSentOK"/>
                <dp:set-variable name="'var://context/local/RIHXResponseAGLASentOK'" value="$RIHXResponseAGLASentOK"/>
                
                <xsl:variable name="sMeta"><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='MetaData'][1]"/></xsl:variable>
                <!-- Code to check on the INVOKER -->
                <xsl:variable name="Invoker">
                <xsl:choose>
                    <xsl:when test="string-length($sMeta) > 0 and contains($sMeta,':ALIP=Y:')">
                        <xsl:value-of select="'ALIP'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'DX'"/>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:variable>
                
                <dp:set-variable name="'var://context/local/sMeta'" value="$sMeta"/>
                <dp:set-variable name="'var://context/local/Invoker'" value="$Invoker"/>
                
                <xsl:variable name="Retries"><xsl:value-of select="number(0)"/></xsl:variable>                
                <dp:set-variable name="'var://context/local/Retries'" value="$Retries"/>
                
                <!-- Assign sHealth -->
                <xsl:variable name="sHealth"><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='iHealth'][1]"/></xsl:variable>
                
                <!-- populating the IHealth Check -->
                <xsl:variable name="iHealthCheck">
                    <xsl:choose>
                        <xsl:when test="number($sHealth) > number(99)">
                            <xsl:value-of select="number(99)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="number($sHealth)"/>
                        </xsl:otherwise>
                    </xsl:choose>                    
                </xsl:variable>
                
                <dp:set-variable name="'var://context/local/iHealth'" value="$iHealthCheck"/>
                <xsl:choose>
                    <!-- When the Flow is not Healthy -->
                    <xsl:when test="($iHealthCheck >= number(99))">
                        <xsl:message dp:priority="Debug"><xsl:value-of select="'RIHXSearch NOT Healthy!'"/></xsl:message>                        
                        <xsl:message dp:priority="Debug"><xsl:value-of select="'Map RequestBG to Request ASBO - Begin'"/></xsl:message>                        
                        <xsl:variable name="rihxHealthReq">
                            <RIHXRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="RIHXRequest_._type">                               
                                <PCRID><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='PCRID'][1]"/></PCRID>
                                <!-- Important to update the value of iHealth to Zero(0) -->
                                <iHealth><xsl:value-of select="number(0)"/></iHealth>
                                <sMetaData><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='MetaData'][1]"/></sMetaData>
                                <ClientSearch>
                                    <FirstName><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='ClientSearch'][1]/*[local-name()='FirstName'][1]"/></FirstName>
                                    <LastName><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='ClientSearch'][1]/*[local-name()='LastName'][1]"/></LastName>
                                    <BirthDate><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='ClientSearch'][1]/*[local-name()='BirthDate'][1]"/></BirthDate>
                                    <Gender><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='ClientSearch'][1]/*[local-name()='Gender'][1]"/></Gender>                         
                                </ClientSearch>
                                <PolicySearch>
                                    <PolicyCount><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='PolicySearch'][1]/*[local-name()='PolicyCount'][1]"/></PolicyCount>
                                    <InsuranceHistory>
                                        <Policy><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='PolicySearch'][1]/*[local-name()='InsuranceHistory'][1]/*[local-name()='Policy'][1]"/></Policy>
                                        <StatutoryCompany><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='PolicySearch'][1]/*[local-name()='InsuranceHistory'][1]/*[local-name()='StatutoryCompany'][1]"/></StatutoryCompany>
                                        <SystemAdminCode><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='PolicySearch'][1]/*[local-name()='InsuranceHistory'][1]/*[local-name()='SystemAdminCode'][1]"/></SystemAdminCode>            
                                    </InsuranceHistory>
                                </PolicySearch>
                                <TreatySearch>
                                    <BasePlanCode><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='TreatySearch'][1]/*[local-name()='BasePlanCode'][1]"/></BasePlanCode>
                                    <PolicyAge><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='TreatySearch'][1]/*[local-name()='PolicyAge'][1]"/></PolicyAge>
                                    <TreatyCompany><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='TreatySearch'][1]/*[local-name()='TreatyCompany'][1]"/></TreatyCompany>
                                    <SystemAdminCode><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='TreatySearch'][1]/*[local-name()='SystemAdminCode'][1]"/></SystemAdminCode>
                                    <Rider>
                                        <RiderPlanCode><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='TreatySearch'][1]/*[local-name()='Rider'][1]/*[local-name()='RiderPlanCode'][1]/*[local-name()='RiderPlanCode'][1]"/></RiderPlanCode>                             
                                    </Rider>
                                </TreatySearch>
                            </RIHXRequest>
                        </xsl:variable>
                        
                        <xsl:message dp:priority="Debug"><xsl:value-of select="'Map RequestBG to Request ASBO - End'"/></xsl:message>
                        <xsl:message dp:priority="Debug"><xsl:value-of select="'Invoke RIHX Health'"/></xsl:message>
                        
                        <!-- ============================================================================================ -->
                        <!-- MQMD Settings                                                                                -->
                        <!-- ============================================================================================ --> 
                        <xsl:variable name="MQMD_RIHX_HEADERS">
                            <MQMD>
                                <Format>MQSTR</Format>            
                                <Priority><xsl:value-of select="6"/></Priority>
                                <Persistence><xsl:value-of select="1"/></Persistence>            
                                <UserIdentifier><xsl:value-of select="'mqm'"/></UserIdentifier>
                                <Encoding><xsl:value-of select="546"/></Encoding>
                                <CodedCharSetId><xsl:value-of select="819"/></CodedCharSetId>
                                <MsgFlags>0</MsgFlags>               		
                                <ApplIdentityData><xsl:value-of select="'DataPower'"/></ApplIdentityData>
                            </MQMD>
                        </xsl:variable>
                        <xsl:variable name="MQMD_RIHX_REQ_HEADERS">
                            <dp:serialize select="$MQMD_RIHX_HEADERS" omit-xml-decl="yes"/>
                        </xsl:variable>
                        
                        <dp:set-request-header name="'MQMD'" values="$MQMD_RIHX_REQ_HEADERS"/>
                        
                        <!-- Invoke URL Open to place the data to Wait Queue -->
                        <xsl:variable name="mqPut">
                            <dp:url-open target="dpmq://MWMQ_DEV/?RequestQueue=IATB.MW.RIHXHEALTH.REQ.TSTC.QL" response="responsecode-ignore" content-type="application/xml" http-method="'post'">
                                <xsl:copy-of select="$rihxHealthReq"/>
                            </dp:url-open>
                        </xsl:variable>                                        
                            <xsl:if test="$mqPut/url-open/responsecode/text()!= '0'">
                                <!-- Alert Notification -->
                                <xsl:message dp:priority="alert">DataPower detected Error while placing RIHX Health Queue IATB.MW.RIHXHEALTH.REQ.TSTC.QL</xsl:message>
                            </xsl:if>                            
                    </xsl:when>
                    <!-- When the flow is Healthy -->
                    <xsl:otherwise>
                        <!-- populating the IHealth Check -->
                        <xsl:variable name="qHealthCheck">
                            <xsl:choose>
                                <xsl:when test="number($sHealth) > number(99)">
                                    <xsl:value-of select="number(99)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="number($sHealth)"/>
                                </xsl:otherwise>
                            </xsl:choose>                    
                        </xsl:variable>
                        <!-- Building the RIHXMO XML -->
                        <xsl:variable name="rihxMo">
                            <RIHXMO xmlns:ns0="http://RIHXSearch" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns0:MO_RIHXSearch">
                                <verb>Create</verb>
                                <MO_RIHXSearch>
                                    <NumLogNotifies><xsl:value-of select="dp:variable('var://context/local/NumLogNotifies')"/></NumLogNotifies>
                                    <StartDateTime><xsl:value-of select="dp:variable('var://context/local/StartDateTime')"/></StartDateTime>
                                    <FollowUpDateTime><xsl:value-of select="dp:variable('var://context/local/FollowUpDateTime')"/></FollowUpDateTime>
                                    <CICSTAIAGLResponseReceivedOK><xsl:value-of select="dp:variable('var://context/local/CICSTAIAGLResponseReceivedOK')"/></CICSTAIAGLResponseReceivedOK>
                                    <CICSTAIAGLAResponseReceivedOK><xsl:value-of select="dp:variable('var://context/local/CICSTAIAGLAResponseReceivedOK')"/></CICSTAIAGLAResponseReceivedOK>
                                    <RIHXResponseAGLSentOK><xsl:value-of select="dp:variable('var://context/local/RIHXResponseAGLSentOK')"/></RIHXResponseAGLSentOK>
                                    <RIHXResponseAGLASentOK><xsl:value-of select="dp:variable('var://context/local/RIHXResponseAGLASentOK')"/></RIHXResponseAGLASentOK>
                                    <bCritical><xsl:value-of select="'false'"/></bCritical>
                                    <LogDesc><xsl:value-of select="''"/></LogDesc>
                                    <Retries><xsl:value-of select="dp:variable('var://context/local/Retries')"/></Retries>
                                    <iHealthCheck><xsl:value-of select="dp:variable('var://context/local/iHealthCheck')"/></iHealthCheck>
                                    <iDebug><xsl:value-of select="dp:variable('var://context/local/iDebug')"/></iDebug>
                                    <sPCRID><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='PCRID'][1]"/></sPCRID>
                                    <bFile13></bFile13>
                                </MO_RIHXSearch>
                            </RIHXMO>
                        </xsl:variable>
                        
                        
                        
                        <!-- From this portion this would be common for both of the flows which needs to be Proceeded as a Template/Rule -->
                        <!-- setting other default values -->
                        <xsl:variable name="NumRequests"><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='PolicySearch'][1]/*[local-name()='PolicyCount'][1]"/></xsl:variable>
                        <xsl:variable name="CommSizeExceeded"><xsl:value-of select="'false'"/></xsl:variable>
                        <xsl:variable name="bFaultAGL"><xsl:value-of select="'false'"/></xsl:variable>
                        <xsl:variable name="bFaultAGLA"><xsl:value-of select="'false'"/></xsl:variable>
                        <xsl:variable name="bSuccess"><xsl:value-of select="'true'"/></xsl:variable>
                        <xsl:variable name="bError"><xsl:value-of select="'false'"/></xsl:variable>
                        <xsl:variable name="bCritical"><xsl:value-of select="'false'"/></xsl:variable>
                        <xsl:variable name="bCriticalTAI"><xsl:value-of select="'false'"/></xsl:variable>
                        <xsl:variable name="bFile13"><xsl:value-of select="'false'"/></xsl:variable>
                        <xsl:variable name="bRequestSizeTooBig"><xsl:value-of select="'false'"/></xsl:variable>
                        <xsl:variable name="LogDescAGL"><xsl:value-of select="''"/></xsl:variable>
                        <xsl:variable name="LogDescAGLA"><xsl:value-of select="''"/></xsl:variable>
                        
                        <!-- Storing in Context variables for future Use -->
                        <dp:set-variable name="'var://context/local/NumRequests'" value="$NumRequests"/>
                        <dp:set-variable name="'var://context/local/CommSizeExceeded'" value="$CommSizeExceeded"/>
                        <dp:set-variable name="'var://context/local/bFaultAGL'" value="$bFaultAGL"/>
                        <dp:set-variable name="'var://context/local/bFaultAGLA'" value="$bFaultAGLA"/>
                        <dp:set-variable name="'var://context/local/bSuccess'" value="$bSuccess"/>
                        <dp:set-variable name="'var://context/local/bError'" value="$bError"/>
                        <dp:set-variable name="'var://context/local/bCritical'" value="$bCritical"/>
                        <dp:set-variable name="'var://context/local/bCriticalTAI'" value="$bCriticalTAI"/>
                        <dp:set-variable name="'var://context/local/bFile13'" value="$bFile13"/>
                        <dp:set-variable name="'var://context/local/bRequestSizeTooBig'" value="$bRequestSizeTooBig"/>
                        <dp:set-variable name="'var://context/local/LogDescAGL'" value="$LogDescAGL"/>
                        <dp:set-variable name="'var://context/local/LogDescAGLA'" value="$LogDescAGLA"/>
                        
                        <!-- Parallel Processing Starts -->
                        
                        <xsl:message dp:proprity="debug"><xsl:value-of select="'Staring to Process AGL Requests'"/></xsl:message>
                        <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
                        <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
                        
                        <xsl:variable name="metaData"><xsl:value-of select="translate(dp:variable('var://context/local/sMeta'),$lowercase,$uppercase)"/></xsl:variable>
                        
                        <xsl:if test="contains($metaData,':P9=LOADED:')">
                            <dp:set-variable name="'var://context/local/CICSTAIAGLResponseReceivedOK'" value="'true'"/>
                            <dp:set-variable name="'var://context/local/RIHXResponseAGLSentOK'" value="'true'"/>                            
                        </xsl:if>
                        <xsl:variable name="policyNum">
                        <xsl:choose>
                            <xsl:when test="contains($metaData,':PN=')">
                                <xsl:value-of select="substring-before(substring-after($metaData,':P9='),':')"/>
                            </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'unknown'"/>
                                </xsl:otherwise>
                        </xsl:choose>
                        </xsl:variable>
                        <xsl:message dp:priority="debug"><xsl:value-of select="concat('Received: Policy#: ',$policyNum)"/></xsl:message>
                        
                        
                        <xsl:choose>
                            <xsl:when test="dp:variable('var://context/local/CICSTAIAGLResponseReceivedOK')= 'true'">
                                <xsl:message dp:priority="debug"><xsl:value-of select="'TAI AGL search response already received'"/></xsl:message>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message dp:priority="debug"><xsl:value-of select="'Map RequestBG to SearchAGLBG - Begin'"/></xsl:message>                                
                                <!-- Construct the Request Message to be placed to AGL -->
                                <xsl:variable name="inputAGLRequest">
                                <co:RIHXSearch_SUBMITS_REQUEST_RECORDBGElement 
                                    xmlns:re_1="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_SUBMITS_REQUEST_RECORD"
                                    xmlns:re="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_SUBMITS_REQUEST_RECORD"
                                    xmlns:p1_3="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_SUBMITS_REQUEST_RECORD_INP_POLICY_P1694391283"
                                    xmlns:p1_2="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_SUBMITS_REQUEST_RECORD_INP_DOB_P1448298169"
                                    xmlns:p1_1="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_SUBMITS_REQUEST_RECORD_NOA_INPUT_AREA_P1388548419"
                                    xmlns:p1="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_CICS_Header_P1188692626"
                                    xmlns:p0_3="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_OUT_GRAND_TOTALS_P0765910960"
                                    xmlns:p0_2="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_SUBMITS_REQUEST_RECORD_NOA_OUTPUT_AREA_P0394888532"
                                    xmlns:p0_1="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_SUBMITS_REQUEST_RECORDINP_TREATY_REQUEST_P0661453491"
                                    xmlns:p0="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_SUBMITS_REQUEST_RECORD_NOA_REINS_HIST_COMMAREA_P0145817027"
                                    xmlns:n1="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_SUBMITS_REQUEST_RECORD_INP_CLIENT_REQUEST_N1775846945"
                                    xmlns:n0_1="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_SUBMITS_REQUEST_RECORD_OUT_APPLIED_RETURN_N0672095616"
                                    xmlns:n0="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/RIHXSearch_SUBMITS_REQUEST_RECORD_SUBMITS_REQUEST_RECORD_INP_POLICY_REQUEST_N0830092794"
                                    xmlns:co_1="http://www.ibm.com/websphere/crossworlds/2002/BOSchema/WebsphereMQ_DynMO_Config"
                                    xmlns:co="http://com.ibm.wbit.wbiadapter/RIHXSearchAGLAConnector">                                    
                                    <changeSummary/>
                                    <verb><xsl:value-of select="'Create'"/></verb>
                                    <RIHXSearch_SUBMITS_REQUEST_RECORD>
                                        <re:ROOT>
                                            <re_1:CICS_Header>
                                                <p1:MQCIH_STRUCID><xsl:value-of select="'CIH'"/></p1:MQCIH_STRUCID>
                                                <p1:MQCIH_VERSION><xsl:value-of select="'2'"/></p1:MQCIH_VERSION>
                                                <p1:MQCIH_STRUCLENGTH><xsl:value-of select="'180'"/></p1:MQCIH_STRUCLENGTH>
                                                <p1:MQCIH_ENCODING><xsl:value-of select="'546'"/></p1:MQCIH_ENCODING>
                                                <p1:MQCIH_CODECHARSETID><xsl:value-of select="'500'"/></p1:MQCIH_CODECHARSETID>
                                                <p1:MQCIHFORMAT><xsl:value-of select="''"/></p1:MQCIHFORMAT>
                                                <p1:MQCIH_FLAGS><xsl:value-of select="'0'"/></p1:MQCIH_FLAGS>
                                                <p1:MQCIH_RETURNCODE><xsl:value-of select="'0'"/></p1:MQCIH_RETURNCODE>
                                                <p1:MQCIH_COMPCODE><xsl:value-of select="'0'"/></p1:MQCIH_COMPCODE>
                                                <p1:MQCIH_REASON><xsl:value-of select="'0'"/></p1:MQCIH_REASON>
                                                <p1:MQCIH_UOWCONTROL><xsl:value-of select="'273'"/></p1:MQCIH_UOWCONTROL>
                                                <p1:MQCIH_GETWAITINTERVAL><xsl:value-of select="'0'"/></p1:MQCIH_GETWAITINTERVAL>
                                                <p1:MQCIH_LINKTYPE><xsl:value-of select="'1'"/></p1:MQCIH_LINKTYPE>
                                                <p1:MQCIH_OUTPUTDATALENGTH><xsl:value-of select="'0'"/></p1:MQCIH_OUTPUTDATALENGTH>
                                                <p1:MQCIH_FACILITYKEEPTIME><xsl:value-of select="'0'"/></p1:MQCIH_FACILITYKEEPTIME>
                                                <p1:MQCIH_ADSDESCRIPTION><xsl:value-of select="'0'"/></p1:MQCIH_ADSDESCRIPTION>
                                                <p1:MQCIH_CONVERSATIONALTASK><xsl:value-of select="'0'"/></p1:MQCIH_CONVERSATIONALTASK>
                                                <p1:MQCIH_TASKENDSTATUS><xsl:value-of select="'0'"/></p1:MQCIH_TASKENDSTATUS>
                                                <p1:MQCIH_FACILITY><xsl:value-of select="''"/></p1:MQCIH_FACILITY>
                                                <p1:MQCIH_FUNCTION><xsl:value-of select="''"/></p1:MQCIH_FUNCTION>
                                                <p1:MQCIH_ABENDCODE><xsl:value-of select="''"/></p1:MQCIH_ABENDCODE>
                                                <p1:MQCIH_AUTHENTICATOR><xsl:value-of select="''"/></p1:MQCIH_AUTHENTICATOR>
                                                <p1:MQCIH_RESERVED1><xsl:value-of select="''"/></p1:MQCIH_RESERVED1>
                                                <p1:MQCIH_REPLYTOFORMAT><xsl:value-of select="''"/></p1:MQCIH_REPLYTOFORMAT>
                                                <p1:MQCIH_REMOTESYSID><xsl:value-of select="''"/></p1:MQCIH_REMOTESYSID>
                                                <p1:MQCIH_REMOTETRANSID><xsl:value-of select="''"/></p1:MQCIH_REMOTETRANSID>
                                                <p1:MQCIH_TRANSACTIONID><xsl:value-of select="''"/></p1:MQCIH_TRANSACTIONID>
                                                <p1:MQCIH_FACILITYLIKE><xsl:value-of select="''"/></p1:MQCIH_FACILITYLIKE>
                                                <p1:MQCIH_ATTENTIONID><xsl:value-of select="''"/></p1:MQCIH_ATTENTIONID>
                                                <p1:MQCIH_STARTCODE><xsl:value-of select="''"/></p1:MQCIH_STARTCODE>
                                                <p1:MQCIH_CANCELCODE><xsl:value-of select="''"/></p1:MQCIH_CANCELCODE>
                                                <p1:MQCIH_NEXTTRANSACTIONID><xsl:value-of select="''"/></p1:MQCIH_NEXTTRANSACTIONID>
                                                <p1:MQCIH_RESERVED2><xsl:value-of select="''"/></p1:MQCIH_RESERVED2>
                                                <p1:MQCIH_RESERVED3><xsl:value-of select="''"/></p1:MQCIH_RESERVED3>
                                                <p1:MQCIH_CURSORPOSITION><xsl:value-of select="'0'"/></p1:MQCIH_CURSORPOSITION>
                                                <p1:MQCIH_ERROROFFSET><xsl:value-of select="'0'"/></p1:MQCIH_ERROROFFSET>
                                                <p1:MQCIH_INPUTITEM><xsl:value-of select="'0'"/></p1:MQCIH_INPUTITEM>
                                                <p1:MQCIH_RESERVED4><xsl:value-of select="'0'"/></p1:MQCIH_RESERVED4>
                                                <p1:PROGRAM_NAME><xsl:value-of select="'PJ03C100'"/></p1:PROGRAM_NAME>
                                            </re_1:CICS_Header>                                        
                                        <re_1:NOA_REINS_HIST_COMMAREA>
                                            <p0:NOA_INPUT_AREA>
                                                <p1_1:INP_REQUEST_ID><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='PCRID'][1]"/></p1_1:INP_REQUEST_ID>
                                                <p1_1:INP_CLIENT_REQUEST>                                                 
                                                    <xsl:variable name="lastNameUcase">
                                                        <xsl:variable name="lastName">
                                                            <xsl:value-of select="translate(normalize-space(/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='ClientSearch'][1]/*[local-name()='LastName'][1]),$lowercase,$uppercase)"/>
                                                        </xsl:variable>
                                                        <xsl:choose>
                                                            <xsl:when test="string-length($lastName) > number(15)">
                                                                <xsl:value-of select="substring($lastName,1,15)"/>
                                                            </xsl:when>
                                                            <xsl:otherwise><xsl:value-of select="$lastName"/></xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:variable>
                                                <n1:INP_LAST_NAME><xsl:value-of select="$lastNameUcase"/></n1:INP_LAST_NAME>
                                                    <xsl:variable name="firstNameUcase">
                                                        <xsl:variable name="firstName">
                                                            <xsl:value-of select="translate(normalize-space(/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='ClientSearch'][1]/*[local-name()='FirstName'][1]),$lowercase,$uppercase)"/>
                                                        </xsl:variable>
                                                        <xsl:choose>
                                                            <xsl:when test="string-length($firstName) > number(15)">
                                                                <xsl:value-of select="substring($firstName,1,15)"/>
                                                            </xsl:when>
                                                            <xsl:otherwise><xsl:value-of select="$firstName"/></xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:variable>
                                                <n1:INP_FIRST_NAME><xsl:value-of select="$firstNameUcase"/></n1:INP_FIRST_NAME>
                                                    <xsl:variable name="gender">
                                                        <xsl:variable name="inputGender"><xsl:value-of select="normalize-space(/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='ClientSearch'][1]/*[local-name()='Gender'][1])"/></xsl:variable>
                                                        <xsl:choose>
                                                            <xsl:when test="$inputGender='0'">
                                                                <xsl:value-of select="'U'"/>
                                                            </xsl:when>
                                                            <xsl:when test="$inputGender='1'">
                                                                <xsl:value-of select="'M'"/>
                                                            </xsl:when>
                                                            <xsl:when test="$inputGender='2'">
                                                                <xsl:value-of select="'F'"/>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                    </xsl:variable>
                                                <n1:INP_GENDER><xsl:value-of select="$gender"/></n1:INP_GENDER>
                                                 <xsl:variable name="dateOfBirth">
                                                     <xsl:value-of select="normalize-space(/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='ClientSearch'][1]/*[local-name()='BirthDate'][1])"/>                                                     
                                                 </xsl:variable>
                                                 <xsl:choose>
                                                     <xsl:when test="string-length($dateOfBirth) > number(0)">
                                                         <xsl:variable name="inputMonth"><xsl:value-of select="substring-before($dateOfBirth,'-')"/></xsl:variable>
                                                         <xsl:variable name="inputDay"><xsl:value-of select="substring-before(substring-after($dateOfBirth,'-'),'-')"/></xsl:variable>
                                                         <xsl:variable name="inputYear"><xsl:value-of select="substring-after(substring-after($dateOfBirth,'-'),'-')"/></xsl:variable>
                                                         <dp:set-variable name="'var://context/local/inputMonth'" value="$inputMonth"/>
                                                         <dp:set-variable name="'var://context/local/inputDay'" value="$inputDay"/>
                                                         <dp:set-variable name="'var://context/local/inputYear'" value="$inputYear"/>
                                                     </xsl:when>
                                                     <xsl:otherwise>
                                                         <dp:set-variable name="'var://context/local/inputMonth'" value="''"/>
                                                         <dp:set-variable name="'var://context/local/inputDay'" value="''"/>
                                                         <dp:set-variable name="'var://context/local/inputYear'" value="''"/>
                                                     </xsl:otherwise>
                                                 </xsl:choose>   
                                                <n1:INP_DOB>
                                                    <p1_2:INP_MONTH><xsl:value-of select="dp:variable('var://context/local/inputMonth')"/></p1_2:INP_MONTH>
                                                    <p1_2:INP_DAY><xsl:value-of select="dp:variable('var://context/local/inputDay')"/></p1_2:INP_DAY>
                                                    <p1_2:INP_CCYY><xsl:value-of select="dp:variable('var://context/local/inputYear')"/></p1_2:INP_CCYY>                                                    
                                                </n1:INP_DOB>
                                                </p1_1:INP_CLIENT_REQUEST>
                                                <p1_1:INP_POLICY_REQUEST>
                                                    <n0:INP_POLICY>
                                                        <p1_3:INP_STAT_CO><xsl:value-of select="''"/></p1_3:INP_STAT_CO>
                                                        <p1_3:INP_ADM_CD><xsl:value-of select="''"/></p1_3:INP_ADM_CD>
                                                        <p1_3:INP_POLICY><xsl:value-of select="''"/></p1_3:INP_POLICY>
                                                    </n0:INP_POLICY>                                                    
                                                </p1_1:INP_POLICY_REQUEST>
                                                <p1_1:INP_TREATY_REQUEST>
                                                    <p0_1:INP_TRTY_AD_CO><xsl:value-of select="''"/></p0_1:INP_TRTY_AD_CO>
                                                    <p0_1:INP_TRTY_CD><xsl:value-of select="''"/></p0_1:INP_TRTY_CD>
                                                    <p0_1:INP_CLIENT_AGE><xsl:value-of select="''"/></p0_1:INP_CLIENT_AGE>
                                                    <p0_1:INP_PLAN_CODE><xsl:value-of select="''"/></p0_1:INP_PLAN_CODE>                                                    
                                                </p1_1:INP_TREATY_REQUEST>
                                            </p0:NOA_INPUT_AREA>
                                            <p0:NOA_OUTPUT_AREA>
                                                <p0_2:OUT_REQUEST_ID><xsl:value-of select="'0'"/></p0_2:OUT_REQUEST_ID>
                                                <p0_2:OUT_APPLIED_RETURN>
                                                    <n0_1:OUT_PLAN_CODE><xsl:value-of select="''"/></n0_1:OUT_PLAN_CODE>
                                                    <n0_1:OUT_PLAN_RETN_PCT><xsl:value-of select="'0'"/></n0_1:OUT_PLAN_RETN_PCT>
                                                    <n0_1:OUT_PLAN_BIND_LIMIT><xsl:value-of select="'0'"/></n0_1:OUT_PLAN_BIND_LIMIT>
                                                    <n0_1:OUT_PLAN_CORPRETN_LIMIT><xsl:value-of select="'0'"/></n0_1:OUT_PLAN_CORPRETN_LIMIT>                                                    
                                                </p0_2:OUT_APPLIED_RETURN>
                                                <p0_2:OUT_GRAND_TOTALS>
                                                    <p0_3:OUT_GRAND_FACE><xsl:value-of select="'0'"/></p0_3:OUT_GRAND_FACE>
                                                    <p0_3:OUT_GRAND_NAR><xsl:value-of select="'0'"/></p0_3:OUT_GRAND_NAR>
                                                    <p0_3:OUT_GRAND_RETAINED><xsl:value-of select="'0'"/></p0_3:OUT_GRAND_RETAINED>
                                                    <p0_3:OUT_GRAND_RETAINED_NAR><xsl:value-of select="'0'"/></p0_3:OUT_GRAND_RETAINED_NAR>
                                                    <p0_3:OUT_GRAND_CEDED><xsl:value-of select="'0'"/></p0_3:OUT_GRAND_CEDED>
                                                    <p0_3:OUT_GRAND_CEDED_NAR><xsl:value-of select="'0'"/></p0_3:OUT_GRAND_CEDED_NAR>                                                    
                                                </p0_2:OUT_GRAND_TOTALS>
                                            </p0:NOA_OUTPUT_AREA>
                                        </re_1:NOA_REINS_HIST_COMMAREA>
                                        </re:ROOT>
                                        <re:DynamicMO>
                                            <co_1:OutputQueue></co_1:OutputQueue>
                                            <co_1:ReplyToQueue></co_1:ReplyToQueue>
                                            <co_1:DataEncoding><xsl:value-of select="'binary'"/></co_1:DataEncoding>
                                            <co_1:InputFormat><xsl:value-of select="'MQCICS'"/></co_1:InputFormat>
                                            <co_1:OutputFormat><xsl:value-of select="'MQCICS'"/></co_1:OutputFormat>
                                            <co_1:ResponseTimeOut><xsl:value-of select="'27000'"/></co_1:ResponseTimeOut>
                                            <co_1:DeliveryMode><xsl:value-of select="'2'"/></co_1:DeliveryMode>
                                            <co_1:Priority><xsl:value-of select="'0'"/></co_1:Priority>
                                            <co_1:Expiration><xsl:value-of select="'3000'"/></co_1:Expiration>
                                            <co_1:CorrelationID><xsl:value-of select="'AMQ!NEW_SESSION_CORRELID'"/></co_1:CorrelationID>                                            
                                        </re:DynamicMO>
                                    </RIHXSearch_SUBMITS_REQUEST_RECORD>                                                                                                           
                                    </co:RIHXSearch_SUBMITS_REQUEST_RECORDBGElement>
                                </xsl:variable>
                                <xsl:message dp:priority="debug"><xsl:value-of select="'Map RequestBG to SearchAGLBG - End'"/></xsl:message>
                                
                                <!-- Placing the request to DataPower AGL Input Queue via url-open()-->
                                
                                <!-- ============================================================================================ -->
                                <!-- MQMD Settings                                                                                -->
                                <!-- ============================================================================================ --> 
                                <xsl:variable name="MQMD_AGL_HEADERS">
                                    <MQMD>
                                        <Format>MQSTR</Format>
                                        <ReplyToQ><xsl:value-of select="'DP.MW.RIHX_AGL_RES.AS'"/></ReplyToQ>
                                        <Priority><xsl:value-of select="6"/></Priority>
                                        <Persistence><xsl:value-of select="1"/></Persistence>            
                                        <UserIdentifier><xsl:value-of select="'mqm'"/></UserIdentifier>
                                        <Encoding><xsl:value-of select="546"/></Encoding>
                                        <CodedCharSetId><xsl:value-of select="819"/></CodedCharSetId>
                                        <MsgFlags>0</MsgFlags>               		
                                        <ApplIdentityData><xsl:value-of select="'DataPower'"/></ApplIdentityData>
                                    </MQMD>
                                </xsl:variable>
                                <xsl:variable name="MQMD_AGL_REQ_HEADERS">
                                    <dp:serialize select="$MQMD_AGL_HEADERS" omit-xml-decl="yes"/>
                                </xsl:variable>
                                
                                <dp:set-request-header name="'MQMD'" values="$MQMD_AGL_REQ_HEADERS"/>
                                
                                <!-- Invoke URL Open to place the data to Wait Queue -->
                                <xsl:variable name="mqPutAGL">
                                    <dp:url-open target="dpmq://MWMQ_DEV/?RequestQueue=MW.DP.RIHX_AGL.REQ.QL" response="responsecode-ignore" content-type="application/xml" http-method="'post'">
                                        <xsl:copy-of select="$inputAGLRequest"/>
                                    </dp:url-open>
                                </xsl:variable>                                        
                                <xsl:if test="$mqPutAGL/url-open/responsecode/text()!= '0'">
                                    <!-- Alert Notification -->
                                    <xsl:message dp:priority="alert">DataPower detected Error while placing RIHX Health Queue MW.DP.RIHX_AGL.REQ.QL</xsl:message>
                                    <dp:set-variable name="'var://context/local/bFaultAGL'" value="'true'"/>
                                    <dp:set-variable name="'var://context/local/bCriticalTAI'" value="'true'"/>
                                    <!-- <dp:reject></dp:reject> -->
                                </xsl:if>
                                <!--  fetching the responseCode  -->
                                <xsl:variable name="responseCode" select="$mqPutAGL//*[local-name()='responsecode']"/>
                                <xsl:choose>
                                    <xsl:when test="$responseCode='0'">
                                        <xsl:variable name="aglResult"><xsl:value-of select="$mqPutAGL//*[local-name()='RIHXSearch_SUBMITS_REQUEST_RECORD']"/></xsl:variable>
                                    </xsl:when>
                                </xsl:choose>
                                
                                <!-- Handling the response -->                                
                                <xsl:choose>
                                    <xsl:when test="dp:variable('var://context/local/bFaultAGL') != 'true'">
                                        
                                        <xsl:message dp:priority="debug"><xsl:value-of select="'BAD, No, or Too Many Responses AGL? - Begin'"/></xsl:message>
                                        <!-- Check if the Error Exists in the Response from TAI -->                                        
                                        <dp:set-variable name="'var://context/local/bNonBlank'" value="'false'"/>
                                        <dp:set-variable name="'var://context/local/bKnown'" value="'true'"/>
                                        <dp:set-variable name="'var://context/local/bReturnAGL'" value="'false'"/>
                                        
                                        
                                        <xsl:for-each select="$mqPutAGL//OUT_ERROR_RETURN">
                                            <xsl:choose>
                                                <xsl:when test="normalize-space(./OUT_ERROR_CODE) = ''">
                                                    <dp:set-variable name="'var://context/local/CICSTAIALGResponseReceivedOK'" value="'true'"/>
                                                    <dp:set-variable name="'var://context/local/bNonBlank'" value="'true'"/>
                                                    <dp:set-variable name="'var://context/local/bKnown'" value="'false'"/>
                                                    <xsl:choose>
                                                        <xsl:when test="./OUT_ERROR_CODE = '00' or ./OUT_ERROR_CODE = '03' or ./OUT_ERROR_CODE = '04' or ./OUT_ERROR_CODE = '07'">                                                            
                                                            <dp:set-variable name="'var://context/local/bReturnAGL'" value="'false'"/>
                                                            <dp:set-variable name="'var://context/local/bKnown'" value="'true'"/>
                                                        </xsl:when>
                                                        <xsl:when test="./OUT_ERROR_CODE = '01'">
                                                            <dp:set-variable name="'var://context/local/bReturnAGL'" value="'true'"/>
                                                            <dp:set-variable name="'var://context/local/bKnown'" value="'true'"/>
                                                        </xsl:when>
                                                        <xsl:when test="./OUT_ERROR_CODE = '02'">
                                                            <dp:set-variable name="'var://context/local/CommSizeExceeded'" value="'true'"/>
                                                            <dp:set-variable name="'var://context/local/bReturnAGL'" value="'true'"/>
                                                            <dp:set-variable name="'var://context/local/bKnown'" value="'true'"/>
                                                        </xsl:when>
                                                        <xsl:when test="./OUT_ERROR_CODE = '13'">
                                                            <dp:set-variable name="'var://context/local/bFile13'" value="'true'"/>
                                                            <dp:set-variable name="'var://context/local/bCriticalTAI'" value="'true'"/>
                                                            <dp:set-variable name="'var://context/local/bReturnAGL'" value="'true'"/>
                                                            <dp:set-variable name="'var://context/local/bKnown'" value="'true'"/>
                                                        </xsl:when>
                                                        <xsl:when test="./OUT_ERROR_CODE = '99'">
                                                            <dp:set-variable name="'var://context/local/bCriticalTAI'" value="'true'"/>
                                                            <dp:set-variable name="'var://context/local/bReturnAGL'" value="'true'"/>
                                                            <dp:set-variable name="'var://context/local/bKnown'" value="'true'"/>                
                                                        </xsl:when>
                                                    </xsl:choose>                                                    
                                                </xsl:when>                                                
                                            </xsl:choose>
                                        </xsl:for-each>
                                        <xsl:choose>
                                            <xsl:when test="not(dp:variable('var://context/local/bKnown'))">
                                                <dp:set-variable name="'var://context/local/bCriticalTAI'" value="'true'"/>
                                                <dp:set-variable name="'var://context/local/CICSTAIALGResponseReceivedOK'" value="'false'"/>
                                                <dp:set-variable name="'var://context/local/bReturnAGL'" value="'true'"/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- Filtering the TAI AGL Response -->
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:when>
            <!-- When first Request is not true -->
            <xsl:otherwise>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
</xsl:stylesheet>