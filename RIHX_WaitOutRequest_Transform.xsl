<?xml version="1.0" encoding="UTF-8"?>
<!-- *********************************************************************************************** -->
<!-- File:    RIHX_WaitOutRequest_Transform.xsl                                                      -->
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
    <!-- Imorting the config file to fetech the values -->
    <xsl:import href="local:///ReinsuranceHistory_MPG/RIHX_WaitOutRequest_ConfigSetting.xsl"/>
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        
        <!-- Storing the Request for further processing -->
        <xsl:variable name="inputRequest"><xsl:copy-of select="."/></xsl:variable>
        
        <!-- Setting First Request to True -->
        <dp:set-variable name="'var://context/local/FirstRequest'" value="'true'"/>
        <xsl:choose>
            <xsl:when test="string-length($inputRequest) = 0">
                <xsl:message dp:priority="alert"><xsl:value-of select="'Input Wait Out Request is Empty/null '"/></xsl:message>
            </xsl:when>
            <xsl:otherwise>
             <!-- Transform the RIHX request as expected to be placed in Wait-out Queue -->   
             <xsl:variable name="rihxWaitOutReq">
                 <RIHXRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="RIHXRequest_._type">                     
                     <PCRID><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='PCRID'][1]"/></PCRID>
                        <iHealth><xsl:value-of select="/RIHXRequest_RIHXRequest/RIHXRequest_RIHXRequest[1]/*[local-name()='ROOT'][1]/*[local-name()='iHealth'][1]"/></iHealth>
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
                <!-- <xsl:copy-of select="$rihxWaitOutReq"/> -->
                <!-- Invoke URL Open to place the data to Wait Queue -->
                <xsl:variable name="mqPut">
                <dp:url-open target="$RIHX_SEARCHQUEUE_URL" response="xml" http-headers="$MQMDRIHXREQ_HEADERS" content-type="text/xml;charset=UTF-8" ssl-proxy="''" timeout="120" http-method="'post'">
                    <xsl:copy-of select="$rihxWaitOutReq"/>
                </dp:url-open>
                </xsl:variable>                
                <xsl:choose>
                    <xsl:when test="$mqPut/url-open/responsecode/text()!= '0'">
                        <!-- Alert Notification -->
                        <xsl:message dp:priority="alert">DataPower detected Error while placing RIHX WaitOutRequest Queue using URL "<xsl:value-of select="$RIHX_SEARCHQUEUE_URL"/>".</xsl:message>
                    </xsl:when>
                    <xsl:otherwise>
                        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    
</xsl:stylesheet>   
