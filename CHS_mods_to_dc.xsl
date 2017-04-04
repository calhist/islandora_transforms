<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:srw_dc="info:srw/schema/1/dc-schema"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- 
	2017-03-29		Customizations for CHS by Bill Levay:
					Added section headers as comments
					Added condition for alternative title
					Removed mods:subject/mods:hierarchicalGeographic since we're not using that
					Added condition for preferredCitation note

	2017-02-23		Customizations for CHS by Bill Levay:
					Updated to XSLT 2.0
					Changed identifier rules to only include local identifiers
					Fixed mods date range so that hyphen only appears if there is an end date
					Fixed mods:form to suppress duplicate values in DC
					Specified that cartographics/coordinates should be dc:coverage, but cartographics/scale should be dc:description, instead of dumping all cartographics into coverage element
	
	Version 1.4		2015-01-30 schema location change: 
    				http://www.loc.gov/standards/sru/recordSchemas/dc-schema.xsd

	Version 1.3		2013-12-09 tmee@loc.gov
	Fixed date transformation for dates without start/end points
	
	Version 1.2		2012-08-12 WS 
	Upgraded to MODS 3.4
	
	Revision 1.1	2007-05-18 tmee@loc.gov
	Added modsCollection conversion to DC SRU
	Updated introductory documentation
	
	Version 1.0		2007-05-04 tmee@loc.gov
	
	This stylesheet transforms MODS version 3.4 records and collections of records to simple Dublin Core (DC) records, 
	based on the Library of Congress' MODS to simple DC mapping <http://www.loc.gov/standards/mods/mods-dcsimple.html> 
			
	The stylesheet will transform a collection of MODS 3.4 records into simple Dublin Core (DC)
	as expressed by the SRU DC schema <http://www.loc.gov/standards/sru/dc-schema.xsd>
	
	The stylesheet will transform a single MODS 3.4 record into simple Dublin Core (DC)
	as expressed by the OAI DC schema <http://www.openarchives.org/OAI/2.0/oai_dc.xsd>
			
	Because MODS is more granular than DC, transforming a given MODS element or subelement to a DC element frequently results in less precise tagging, 
	and local customizations of the stylesheet may be necessary to achieve desired results. 
	
	This stylesheet makes the following decisions in its interpretation of the MODS to simple DC mapping: 
		
	When the roleTerm value associated with a name is creator, then name maps to dc:creator
	When there is no roleTerm value associated with name, or the roleTerm value associated with name is a value other than creator, then name maps to dc:contributor
	Start and end dates are presented as span dates in dc:date and in dc:coverage
	When the first subelement in a subject wrapper is topic, subject subelements are strung together in dc:subject with hyphens separating them
	Some subject subelements, i.e., geographic, temporal, hierarchicalGeographic, and cartographics, are also parsed into dc:coverage
	The subject subelement geographicCode is dropped in the transform

-->

	<xsl:output method="xml" indent="yes"/>
	
	<xsl:template match="/">
		<xsl:choose>
		<xsl:when test="//mods:modsCollection">			
			<srw_dc:dcCollection xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/recordSchemas/dc-schema.xsd">
				<xsl:apply-templates/>
			<xsl:for-each select="mods:modsCollection/mods:mods">			
				<srw_dc:dc xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/recordSchemas/dc-schema.xsd">
				<xsl:apply-templates/>
			</srw_dc:dc>
			</xsl:for-each>
			</srw_dc:dcCollection>
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="mods:mods">
			<oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
				<xsl:apply-templates/>
			</oai_dc:dc>
			</xsl:for-each>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Title -->
	<xsl:template match="mods:titleInfo">
		<dc:title>
			<xsl:if test="@type='alternative'">
				<xsl:text>Alternative Title: </xsl:text>
			<xsl:value-of select="mods:nonSort"/>
			</xsl:if>
			<xsl:if test="mods:nonSort">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:value-of select="mods:title"/>
			<xsl:if test="mods:subTitle">
				<xsl:text>: </xsl:text>
				<xsl:value-of select="mods:subTitle"/>
			</xsl:if>
			<xsl:if test="mods:partNumber">
				<xsl:text>. </xsl:text>
				<xsl:value-of select="mods:partNumber"/>
			</xsl:if>
			<xsl:if test="mods:partName">
				<xsl:text>. </xsl:text>
				<xsl:value-of select="mods:partName"/>
			</xsl:if>
		</dc:title>
	</xsl:template>

	<!-- Creator and Contributor -->
	<xsl:template match="mods:name">
		<xsl:choose>
			<xsl:when test="mods:role/mods:roleTerm[@type='text']='Creator' or mods:role/mods:roleTerm[@type='code']='cre' ">
				<dc:creator>
					<xsl:call-template name="name"/>
				</dc:creator>
			</xsl:when>
			<xsl:otherwise>
				<dc:contributor>
					<xsl:call-template name="name"/>
				</dc:contributor>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Identifiers -->
	<xsl:template match="mods:classification">
		<dc:identifier>
			<xsl:value-of select="."/>
		</dc:identifier>
	</xsl:template>

	<xsl:template match="mods:location/mods:shelfLocator | mods:identifier[@type='local']">
		<dc:identifier>
			<xsl:text>local: </xsl:text>
			<xsl:value-of select="."/>
		</dc:identifier>
	</xsl:template>
	
	<xsl:template match="mods:location">
		<xsl:for-each select="mods:url">
			<dc:identifier>	
				<xsl:value-of select="."/>
			</dc:identifier>
		</xsl:for-each>
	</xsl:template>

	<!-- Subjects -->
	<xsl:template match="mods:subject[mods:topic | mods:name | mods:occupation | mods:geographic | mods:cartographics | mods:temporal] ">
		<dc:subject>
			<xsl:for-each select="mods:topic | mods:occupation">
				<xsl:value-of select="."/>
				<xsl:if test="position()!=last()">--</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="mods:name">
				<xsl:call-template name="name"/>
			</xsl:for-each>
		</dc:subject>

		<xsl:for-each select="mods:geographic">
			<dc:coverage>
				<xsl:value-of select="."/>
			</dc:coverage>
		</xsl:for-each>

		<xsl:for-each select="mods:cartographics/mods:coordinates">
			<dc:coverage>
				<xsl:value-of select="."/>
			</dc:coverage>
		</xsl:for-each>

		<xsl:for-each select="mods:cartographics/mods:scale">
			<dc:description>
				<xsl:value-of select="."/>
			</dc:description>
		</xsl:for-each>

		<xsl:if test="mods:temporal">
			<dc:coverage>
				<xsl:for-each select="mods:temporal">
					<xsl:value-of select="."/>
					<xsl:if test="position()!=last()">-</xsl:if>
				</xsl:for-each>
			</dc:coverage>
		</xsl:if>
	</xsl:template>

	<!-- Notes -->
	<xsl:template match="mods:abstract | mods:tableOfContents | mods:note">
		<dc:description>
			<xsl:if test="@type='preferredCitation'">
				<xsl:text>Preferred Citation: </xsl:text>
			</xsl:if>
			<xsl:value-of select="."/>
		</dc:description>
	</xsl:template>

	<!-- Dates & Publisher -->
	<xsl:template match="mods:originInfo">
		<xsl:apply-templates select="*[not(@point)]"/> 
		<xsl:for-each select="mods:publisher">
			<dc:publisher>
				<xsl:value-of select="."/>
			</dc:publisher>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="mods:dateIssued | mods:dateCreated">
		<dc:date>
			<xsl:if test="not(@*)">
				<xsl:value-of select="."/>
			</xsl:if>
		</dc:date>
	</xsl:template>

	<!-- Type/Genre -->
	<xsl:template match="mods:genre">
		<xsl:choose>
			<xsl:when test="@authority='dct'">
				<dc:type>
					<xsl:value-of select="."/>
				</dc:type>
			</xsl:when>
			<xsl:otherwise>
				<dc:type>
					<xsl:value-of select="."/>
				</dc:type>
				<xsl:apply-templates select="mods:typeOfResource"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:typeOfResource">
		<xsl:if test="@collection='yes'">
			<dc:type>Collection</dc:type>
		</xsl:if>
		<xsl:if test=". ='software' and ../mods:genre='database'">
			<dc:type>Dataset</dc:type>
		</xsl:if>
		<xsl:if test=".='software' and ../mods:genre='online system or service'">
			<dc:type>Service</dc:type>
		</xsl:if>
		<xsl:if test=".='software'">
			<dc:type>Software</dc:type>
		</xsl:if>
		<xsl:if test=".='cartographic material'">
			<dc:type>Image</dc:type>
		</xsl:if>
		<xsl:if test=".='multimedia'">
			<dc:type>InteractiveResource</dc:type>
		</xsl:if>
		<xsl:if test=".='moving image'">
			<dc:type>MovingImage</dc:type>
		</xsl:if>
		<xsl:if test=".='three dimensional object'">
			<dc:type>PhysicalObject</dc:type>
		</xsl:if>
		<xsl:if test="starts-with(.,'sound recording')">
			<dc:type>Sound</dc:type>
		</xsl:if>
		<xsl:if test=".='still image'">
			<dc:type>StillImage</dc:type>
		</xsl:if>
		<xsl:if test=". ='text'">
			<dc:type>Text</dc:type>
		</xsl:if>
		<xsl:if test=".='notated music'">
			<dc:type>Text</dc:type>
		</xsl:if>
	</xsl:template>

	<!-- Form, Format, Extent -->
	<xsl:template match="mods:physicalDescription">
		<xsl:for-each select="mods:extent | mods:internetMediaType">
			<dc:format>
				<xsl:value-of select="."/>
			</dc:format>
		</xsl:for-each>
		<xsl:for-each-group select="mods:form" group-by="text()">
			<dc:format>
				<xsl:value-of select="."/>
			</dc:format>
		</xsl:for-each-group>
	</xsl:template>

	<!-- Language -->
	<xsl:template match="mods:language">
		<dc:language>
			<xsl:value-of select="child::*"/>
		</dc:language>
	</xsl:template>

	<!-- Related Item, Parent Collection -->
	<xsl:template match="mods:relatedItem[mods:titleInfo | mods:name | mods:identifier | mods:location]">
		<xsl:choose>
			<xsl:when test="@type='original'">
				<dc:source>
					<xsl:for-each
						select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:physicalLocation">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">, </xsl:if>
						</xsl:if>
					</xsl:for-each>
				</dc:source>
			</xsl:when>
			<xsl:when test="@type='series'"/>
			<xsl:otherwise>
				<dc:relation>
					<xsl:for-each
						select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:physicalLocation">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">, </xsl:if>
						</xsl:if>
					</xsl:for-each>
				</dc:relation>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Rights -->
	<xsl:template match="mods:accessCondition">
		<dc:rights>
			<xsl:value-of select="."/>
		</dc:rights>
	</xsl:template>

	<!-- Name Template -->
	<xsl:template name="name">
		<xsl:variable name="name">
			<xsl:for-each select="mods:namePart[not(@type)]">
				<xsl:value-of select="."/>
			</xsl:for-each>
			<xsl:value-of select="mods:namePart[@type='family']"/>
			<xsl:if test="mods:namePart[@type='given']">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="mods:namePart[@type='given']"/>
			</xsl:if>
			<xsl:if test="mods:namePart[@type='date']">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="mods:namePart[@type='date']"/>
				<xsl:text/>
			</xsl:if>
			<xsl:if test="mods:displayForm">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="mods:displayForm"/>
				<xsl:text>) </xsl:text>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select="normalize-space($name)"/>
	</xsl:template>

	<!-- suppress all else:-->
	<xsl:template match="*"/>
		
</xsl:stylesheet>
