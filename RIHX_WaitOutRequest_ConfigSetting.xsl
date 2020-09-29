<?xml version="1.0" encoding="UTF-8"?>
<!-- *********************************************************************************************** -->
<!-- File:    RIHX_WaitOutRequest_ConfigSetting.xsl                                                  -->
<!--                                                                                                 -->
<!-- Purpose: Used to maintain the Configuration Information for MQ                                  -->
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
    
    <!-- Building the MQ URL To Invoke -->
    <xsl:variable name="RIHX_SEARCHQUEUE_URL">dpmq://MWMQ_DEV/?RequestQueue=IATB.MW.RIHXSEARCH.REQ.TSTC.QL;PMO=2</xsl:variable>
    
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
    
    <xsl:variable name="MQMDRIHXREQ_HEADERS">
        <header name="MQMD">
            <xsl:value-of select="$MQMD_RIHX_REQ_HEADERS"/>
        </header>
    </xsl:variable>
    
    
</xsl:stylesheet>