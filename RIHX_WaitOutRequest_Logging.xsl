<?xml version="1.0" encoding="UTF-8"?>
<!-- *********************************************************************************************** -->
<!-- File:    RIHX_WaitOutRequest_Logging.xsl                                                        -->
<!--                                                                                                 -->
<!-- Purpose: To log the Input Request to AIG LogService.                                            -->
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
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:variable name="status">
            <xsl:value-of select="dp:variable('var://context/request/status')"/>
        </xsl:variable>
    <xsl:variable name="Log">
        <xsl:variable name="MessageType">BUSINESS</xsl:variable>
        <xsl:variable name="MessageSeverity">INFO</xsl:variable>
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
            <soapenv:Header/>
            <soapenv:Body>
                <aig:log>
                    <in>
                        <RequestMetaData>
                            <TransRefGUID><xsl:value-of select="//*[local-name()='TransRefGUID']"/></TransRefGUID>
                            <TransExecDate><xsl:value-of select="date:date()"/></TransExecDate>
                            <TransExecTime><xsl:value-of select="date:time()"/></TransExecTime>
                            <RequestingApplication><xsl:value-of select="'ALIP or DX'"/></RequestingApplication>
                            <Credentials><xsl:value-of select="'UserLoginName'"/></Credentials>
                        </RequestMetaData>
                        <ApplicationRequestTxn>
                            <AIGLogData>
                                <MessageSender>ALIP or DX</MessageSender>
                                <MessageType><xsl:value-of select="$MessageType"/></MessageType>
                                <MessageSeverity><xsl:value-of select="$MessageSeverity"/></MessageSeverity>
                                <MessageCode>Re-Insurance History Service</MessageCode>
                                <MessageDescription>
                                    <xsl:choose>
                                        <xsl:when test="($status = 'SUCCESS')">SUCCESS</xsl:when>
                                        <xsl:otherwise>Request Received</xsl:otherwise>
                                    </xsl:choose>
                                </MessageDescription>
                                <AuditableIndicator>Y</AuditableIndicator>
                                <PolicyNumber><xsl:value-of select="//*[local-name()='Policy']/text()"/></PolicyNumber>
                                <DestinationSystemName><xsl:value-of select="'UW Database'"/></DestinationSystemName>
                                <CallingServiceOperation><xsl:value-of select="''"/></CallingServiceOperation>
                            </AIGLogData>
                        </ApplicationRequestTxn>
                    </in>
                </aig:log>
            </soapenv:Body>            
        </soapenv:Envelope>
    </xsl:variable>
    <xsl:copy-of select="$Log"/>    
    </xsl:template>
    
</xsl:stylesheet>