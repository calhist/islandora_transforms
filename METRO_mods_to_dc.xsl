<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" indent="yes"/>
  <xsl:variable name="upper_case">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
  <xsl:variable name="lower_case">abcdefghijklmnopqrstuvwxyz</xsl:variable>

  <xsl:template match="/">
    <oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
      <xsl:apply-templates select="mods:mods"/>
    </oai_dc:dc>
  </xsl:template>

  <!-- Title -->
  <xsl:template match="mods:mods/mods:titleInfo">
    <dc:title>
      <xsl:value-of select="mods:title"/>
    </dc:title>
  </xsl:template>

  <!-- Creator and Contributor -->
  <xsl:template match="mods:mods/mods:name">
    <xsl:variable name="text" select="translate(mods:role/mods:roleTerm, $upper_case, $lower_case)"/>
    <xsl:choose>
      <xsl:when test="$text = 'creator' or $text = 'author' or $text = 'photographer' or not(mods:role/mods:roleTerm)">
        <dc:creator>
          <xsl:value-of select="mods:namePart"/>
        </dc:creator>
      </xsl:when>
      <xsl:otherwise>
        <dc:contributor>
          <xsl:value-of select="mods:namePart"/>
        </dc:contributor>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Type -->
  <xsl:template match="mods:mods/mods:genre | mods:mods/mods:typeOfResource">
    <dc:type>
      <xsl:value-of select="."/>
    </dc:type>
  </xsl:template>

  <!-- Publisher and Date -->
  <xsl:template match="mods:mods/mods:originInfo">
  <xsl:if test="mods:publisher | mods:place/mods:placeTerm">
    <dc:publisher>
      <xsl:if test="mods:place/mods:placeTerm">
        <xsl:value-of select="mods:place/mods:placeTerm"/>
        <xsl:if test="mods:publisher">
          <xsl:text>: </xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:value-of select="mods:publisher"/>
    </dc:publisher>
  </xsl:if>

    <xsl:for-each select="mods:dateIssued | mods:dateCreated">
      <dc:date>
        <xsl:value-of select="."/>
      </dc:date>
    </xsl:for-each>
  </xsl:template>

  <!-- Publisher -->
  <xsl:template match="mods:mods/mods:note[@type='publishinginfo']">
    <dc:publisher>
      <xsl:value-of select="."/>
    </dc:publisher>
  </xsl:template>

  <!-- Language -->
  <xsl:template match="mods:mods/mods:language/mods:languageTerm">
    <dc:language>
      <xsl:value-of select="."/>
    </dc:language>
  </xsl:template>

  <!-- Format -->
  <xsl:template match="mods:mods/mods:physicalDescription/mods:form | mods:mods/mods:physicalDescription/mods:extent | mods:mods/mods:physicalDescription/mods:internetMediaType">
    <dc:format>
      <xsl:value-of select="."/>
    </dc:format>
  </xsl:template>


  <!-- Description -->
  <xsl:template match="mods:mods/mods:subject/mods:cartographics/mods:scale | mods:mods/mods:note[@displayLabel='Content Note'] | mods:mods/mods:abstract">
    <dc:description>
      <xsl:value-of select="."/>
    </dc:description>
  </xsl:template>


  <!-- Coverage -->
  <xsl:template match="mods:mods/mods:subject/mods:geographic | mods:mods/mods:subject/mods:hierarchicalGeographic/mods:citySection | mods:mods/mods:subject/mods:cartographics/mods:coordinates | mods:mods/mods:note[@displayLabel='Business Address']">
    <dc:coverage>
      <xsl:value-of select="."/>
    </dc:coverage>
  </xsl:template>

  <!-- Subject -->
  <xsl:template match="mods:mods/mods:subject/mods:topic | mods:mods/mods:subject/mods:name/mods:namePart">
    <dc:subject>
      <xsl:value-of select="."/>
    </dc:subject>
  </xsl:template>

  <!-- Relation -->
  <xsl:template match="mods:mods/mods:relatedItem[@type='host']/mods:titleInfo/mods:title">
    <dc:relation>
      <xsl:value-of select="."/>
    </dc:relation>
  </xsl:template>

  <!-- Source -->
  <xsl:template match="mods:mods/mods:location/mods:physicalLocation">
    <dc:source>
      <xsl:value-of select="."/>
    </dc:source>
  </xsl:template>

  <!-- Rights -->
  <xsl:template match="mods:mods/mods:accessCondition[@type='use and reproduction']">
    <dc:rights>
      <xsl:value-of select="."/>
    </dc:rights>
  </xsl:template>

  <xsl:template match="text()"/>

</xsl:stylesheet>